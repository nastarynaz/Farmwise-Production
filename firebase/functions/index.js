require("dotenv").config();
const axios = require("axios");
const mongoose = require("mongoose");
const { createHash } = require("crypto");
const { notificationsModel } = require("./models/notificationsModel.js");
const { farmsModel } = require("./models/farmsModel.js");
const { tokensModel } = require("./models/tokensModel.js");
const { getCounter } = require("./lib/counter.js");
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { HumanMessage, SystemMessage } = require("@langchain/core/messages");
const { geminiModelSettings, geminiGeneralSystemTemplates, geminiGeneralHumanMessages } = require("./lib/variable");
const { logger } = require("firebase-functions");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { getMessaging } = require("firebase-admin/messaging");
const { onRequest } = require("firebase-functions/https");
const { iotsModel } = require("./models/iotsModel.js");
const { filterQuery } = require("./lib/filterQuery.js");

const model = new ChatGoogleGenerativeAI(geminiModelSettings);
const weatherAxios = axios.create({
    baseURL: process.env.WEATHER_BASE_URL,
    params: {
        key: process.env.WEATHER_API_KEY,
    },
});
let messages = [];
let tokens = {};

admin.initializeApp({
    credential: admin.credential.applicationDefault(),
});

function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

function getFCM(notification) {
    const nowtoken = tokens[notification.uID];
    if (!nowtoken) {
        return [];
    }
    const out = [];
    for (let i = 0; i < nowtoken.length; i++) {
        out.push({
            notification: { title: notification.content.title, body: notification.content.title },
            token: nowtoken[i],
        });
    }
    return out;
}

async function addNotifications(notification) {
    messages.push(...getFCM(notification));
    if (messages.length >= parseInt(process.env.NOTIFICATION_BATCH_LIMIT)) {
        await sendNotifications();
    }
}

async function sendNotifications() {
    if (messages.length > 0) {
        const resp = await getMessaging().sendEach(messages);
        logger.info(`NOTIFICATION SENT (${new Date().toLocaleString()}\nSuccess: ${resp.successCount}\nFailed: ${resp.failureCount}`);
    }
    messages = [];
}

async function getAlert(farm) {
    const resp = await weatherAxios.get("/alerts.json", {
        params: {
            q: farm.location.join(","),
        },
    });
    return resp.data.alerts.alert;
}

async function checkAlertExists(alert, fID, uID) {
    const hash = createHash("sha256").update(JSON.stringify(alert)).digest("base64");
    const notification = await notificationsModel.findOne({ hash: hash, fID: fID, uID: uID });
    return notification != null;
}

async function genAlert(alert, fID, uID) {
    const doc = new notificationsModel({
        nID: await getCounter("notifications"),
        fID: fID,
        uID: uID,
        hash: createHash("sha256").update(JSON.stringify(alert)).digest("base64"),
        content: {
            type: "alert",
            title: `${alert.event} for ${alert.areas}`,
            body: `${alert.urgency} ${alert.severity} ${alert.headline}. ${alert.instruction}.`,
        },
    });
    await doc.save();
    return doc;
}

async function genGeneral(farm) {
    const systemContent = [];
    const humanContent = [];
    let context = null;
    context = JSON.stringify(
        (
            await weatherAxios.get("/forecast.json", {
                params: { q: farm.location.join(","), alerts: "yes" },
            })
        ).data
    );
    if (farm.ioID) {
        const iot = filterQuery(await iotsModel.findOne({ ioID: farm.ioID }));
        iot.ioID = undefined;
        delete iot.ioID;
        context.iot = iot;
    }
    systemContent.push({
        type: "text",
        text: geminiGeneralSystemTemplates.replace("{type}", farm.type).replace("{context}", context),
    });
    humanContent.push({ type: "text", text: geminiGeneralHumanMessages });

    const messages = [
        new SystemMessage({
            content: systemContent,
        }),
        new HumanMessage({
            content: humanContent,
        }),
    ];
    const answer = (await model.invoke(messages)).content;
    const doc = new notificationsModel({
        nID: await getCounter("notifications"),
        fID: farm.fID,
        uID: farm.uID,
        hash: "NO_HASH",
        content: {
            type: "general",
            title: `Weekly reccomendation for ${farm.type} farm -- ${farm.name}`,
            body: answer,
        },
    });
    await doc.save();
    return doc;
}

async function populateToken() {
    const tokenArr = await tokensModel.find();
    for (let i = 0; i < tokenArr.length; i++) {
        const uID = tokenArr[i].uID;
        const tID = tokenArr[i].tID;

        if (!tokens[uID]) {
            tokens[uID] = [tID];
        } else {
            tokens[uID].push(tID);
        }
    }
}

async function checkAlertNotifications() {
    await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
    await populateToken();

    const farms = await farmsModel.find();
    for (let i = 0; i < farms.length; i++) {
        const alerts = await getAlert(farms[i]);
        for (let j = 0; j < alerts.length; j++) {
            if (!(await checkAlertExists(alerts[j], farms[i].fID, farms[i].uID))) {
                await addNotifications(await genAlert(alerts[j], farms[i].fID, farms[i].uID));
            }
        }
    }

    await sendNotifications();
    await mongoose.disconnect();
}

async function giveGeneralNotification() {
    await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
    await populateToken();
    const farms = await farmsModel.find();
    for (let i = 0; i < farms.length; i++) {
        await addNotifications(await genGeneral(farms[i]));
        await sleep(parseInt(process.env.NOTIFICATION_SLEEP_TIME));
    }

    await sendNotifications();
    await mongoose.disconnect();
}

async function _checkAlertNotifications(req, res) {
    await checkAlertNotifications();
    res.status(200).json("Success");
}

async function _giveGeneralNotification(req, res) {
    await giveGeneralNotification();
    res.status(200).json("Success");
}

module.exports.checkAlertNotifications = onSchedule(process.env.NOTIFICATION_ALERT_SCHEDULE, checkAlertNotifications);
module.exports.giveGeneralNotification = onSchedule(process.env.NOTIFICATION_GENERAL_SCHEDULE, giveGeneralNotification);
module.exports.TESTcheckAlertNotifications = onRequest(_checkAlertNotifications);
module.exports.TESTgiveGeneralNotification = onRequest(_giveGeneralNotification);
