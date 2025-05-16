const { GETRoot, POSTRoot } = require("../controllers/chats.js");
const router = require("express").Router();

router.get("/", GETRoot);
router.post("/", POSTRoot);

module.exports = router;
