const express = require("express");
const router = express.Router();
const cors = require("cors");
const newsRouter = require("./news.js");
const accountsRouter = require("./accounts.js");
const farmsRouter = require("./farms.js");
const notificationsRouter = require("./notifications.js");
const chatsRouter = require("./chats.js");
const iotsRouter = require("./iots.js");
const userId = require("./middlewares/userId.js");
const auth = require("./middlewares/auth.js");

router.use(
    cors({
        origin: "*",
    })
);
router.get("/", (req, res) => {
    res.status(200).json("Running!");
});
router.use(
    express.json({
        limit: "50mb",
    })
);
router.use("/iots", iotsRouter);
router.use(auth);
router.use("/accounts", accountsRouter);
router.use("/news", userId, newsRouter);
router.use("/farms", userId, farmsRouter);
router.use("/notifications", userId, notificationsRouter);
router.use("/chats", userId, chatsRouter);

module.exports = router;
