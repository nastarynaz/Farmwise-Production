const { usersModel } = require("../models/usersModel");
const { filterQuery } = require("./lib/filterQuery");
const { accountsPutS, accountsPostS } = require("./schemas/accounts");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETRoot(req, res) {
    try {
        res.status(200).json(filterQuery(req.user));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function PUTRoot(req, res) {
    try {
        req.body = accountsPutS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        const result = await usersModel.findOneAndUpdate({ uID: req.uID }, req.body, { new: true });
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
        req.body = accountsPostS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        if (await usersModel.findOne({ uID: req.uID })) {
            res.status(403).json("Email Already Exist");
            return;
        }

        if (!req.body.username) {
            req.body.username = "User #" + req.uID;
        }

        if (!req.body.profilePicture) {
            req.body.profilePicture = process.env.USER_DEFAULT_PROFILE_PICTURE;
        }

        // Give default value if NULL
        const user = new usersModel({
            uID: req.uID,
            ...req.body,
        });
        await user.save();
        res.status(200).json(filterQuery(user));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = { GETRoot, PUTRoot, POSTRoot };
