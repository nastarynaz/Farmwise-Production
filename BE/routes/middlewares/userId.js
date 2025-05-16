const { usersModel } = require("../../models/usersModel");

async function userId(req, res, next) {
    try {
        req.user = await usersModel.findOne({ uID: req.uID });
        if (!req.user) {
            res.status(403).json("Account Not Registered");
            return;
        }

        next();
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = userId;
