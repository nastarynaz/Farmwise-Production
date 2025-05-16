const { iotsModel } = require("../models/iotsModel");
const { filterQuery } = require("./lib/filterQuery");
const { checkSignature } = require("./lib/mycrypto");
const { iotsPostS } = require("./schemas/iots");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETId(req, res) {
    res.status(200).json(filterQuery(req.iot));
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function POSTId(req, res) {
    try {
        req.body = iotsPostS.parse(req.body);
    } catch (err) {
        // console.log(err);
        res.status(400).json("Bad Request");
        return;
    }

    try {
        // Check signature
        if (!checkSignature(req.iot.ioID, req.body.signature)) {
            res.status(403).json("Invalid Signature");
            return;
        }
    } catch (err) {
        res.status(403).json("Invalid Signature");
        return;
    }

    const query = req.body;
    query.signature = undefined;
    delete query.signature;

    try {
        req.iot.set(query);
        await req.iot.save();
    } catch (err) {
        res.status(500).json("Server Down");
        return;
    }

    res.status(200).json("Success");
}

module.exports = { GETId, POSTId };
