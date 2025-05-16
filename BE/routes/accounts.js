const { GETRoot, PUTRoot, POSTRoot } = require("../controllers/accounts.js");
const userId = require("./middlewares/userId.js");

const router = require("express").Router();

router.get("/", userId, GETRoot);
router.put("/", userId, PUTRoot);
router.post("/", POSTRoot);

module.exports = router;
