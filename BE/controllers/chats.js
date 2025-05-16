const { chatsModel } = require("../models/chatsModel");
const { farmsModel } = require("../models/farmsModel");
const { chatsPostS } = require("./schemas/chats");
const { getCounter } = require("./lib/counter");
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { HumanMessage, SystemMessage } = require("@langchain/core/messages");
const { geminiModelSettings, geminiSystemMessages, geminiSystemTemplates } = require("./lib/variable");
const model = new ChatGoogleGenerativeAI(geminiModelSettings);
const axios = require("axios");
const { filterQuery } = require("./lib/filterQuery");
const { iotsModel } = require("../models/iotsModel");

const weatherAxios = axios.create({
    baseURL: process.env.WEATHER_BASE_URL,
    params: {
        key: process.env.WEATHER_API_KEY,
    },
});

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETRoot(req, res) {
    if (!req.query.page || isNaN(parseInt(req.query.page)) || parseInt(req.query.page) < 1) {
        req.query.page = 1;
    } else {
        req.query.page = parseInt(req.query.page);
    }

    try {
        const toSkip = (parseInt(req.query.page) - 1) * parseInt(process.env.CHATS_PAGINATION_LIMIT);
        const result = await chatsModel.find({ uID: req.uID }).sort({ cID: -1 }).skip(toSkip).limit(parseInt(process.env.CHATS_PAGINATION_LIMIT));

        res.status(200).json(filterQuery(result));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function POSTRoot(req, res) {
    try {
        req.body = chatsPostS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        const systemContent = [{ type: "text", text: geminiSystemMessages }];
        const humanContent = [];
        let context = null;
        if (req.body.fID) {
            const farm = await farmsModel.findOne({
                uID: req.uID,
                fID: req.body.fID,
            });
            if (!farm) {
                res.status(404).json("Not Found");
                return;
            }
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
                text: geminiSystemTemplates.replace("{type}", farm.type).replace("{context}", context),
            });
        }
        if (req.body.text) {
            humanContent.push({ type: "text", text: req.body.text });
        }
        if (req.body.image) {
            humanContent.push({
                type: "image_url",
                image_url: { url: `data:image/png;base64,${req.body.image}` },
            });
        }

        const messages = [
            new SystemMessage({
                content: systemContent,
            }),
            new HumanMessage({
                content: humanContent,
            }),
        ];
        const answer = (await model.invoke(messages)).content;

        // Do Prompt
        const chat = {
            cID: await getCounter("chats"),
            uID: req.uID,
            fID: req.body.fID || null,
            prompt: {
                text: req.body.text || null,
                image: req.body.image || null,
            },
            answer: answer,
        };
        const doc = new chatsModel(chat);
        await doc.save();
        res.status(200).json(filterQuery(doc));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = { GETRoot, POSTRoot };
