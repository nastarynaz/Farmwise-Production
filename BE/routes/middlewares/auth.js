const { getAuth } = require("firebase-admin/auth");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
async function auth(req, res, next) {
    try {
        if (process.env.IS_TESTING == "true") {
            req.uID = "1";
            next();
            return;
        }
        req.uID = (await getAuth().verifyIdToken(req.headers.authorization.split("Bearer ")[1])).uid;
        next();
    } catch (err) {
        res.status(403).json("Invalid Session Token");
    }
}

module.exports = auth;
