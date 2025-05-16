const { notificationsModel } = require("../models/notificationsModel");
const { tokensModel } = require("../models/tokensModel");
const { filterQuery } = require("./lib/filterQuery");
const { notificationsPutS, notificationsPostS } = require("./schemas/notifications");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETRoot(req, res) {
    try {
        let result;
        if (req.query.unreadOnly === "true") {
            result = await notificationsModel.find({
                uID: req.uID,
                lastRead: { $exists: false },
            });
        } else {
            result = await notificationsModel.find({
                uID: req.uID,
            });
        }
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
async function PUTRead(req, res) {
    try {
        req.body = notificationsPutS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        const docs = [];
        for (let i = 0; i < req.body.nID.length; i++) {
            const doc = await notificationsModel.findOne({
                nID: req.body.nID[i],
            });
            if (!doc) {
                res.status(404).json("Not Found");
                return;
            }

            docs.push(doc);
        }

        for (let i = 0; i < docs.length; i++) {
            const doc = docs[i];
            if (!doc.lastRead) {
                doc.lastRead = Date.now();
                await doc.save();
                docs[i] = doc;
            }
        }

        res.status(200).json(filterQuery(docs));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETId(req, res) {
    try {
        const result = await notificationsModel.findOne({
            nID: req.params.nID,
            uID: req.uID,
        });
        if (!result) {
            res.status(404).json("Not Found");
            return;
        }
        res.status(200).json(filterQuery(result));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function POSTRegister(req, res) {
    try {
        req.body = notificationsPostS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        let tokenDoc = await tokensModel.findOne({ tID: req.body.token });
        if (!tokenDoc) {
            tokenDoc = new tokensModel({
                tID: req.body.token,
                uID: req.uID,
            });
            await tokenDoc.save();
        }
        res.status(200).json(filterQuery(tokenDoc));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function POSTUnregister(req, res) {
    try {
        req.body = notificationsPostS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        await tokensModel.deleteOne({ tID: req.body.token });
        res.status(200).json("Success");
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = { GETRoot, PUTRead, GETId, POSTRegister, POSTUnregister };
