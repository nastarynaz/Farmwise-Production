const { GETId, POSTId } = require("../controllers/iots.js");
const iotId = require("./middlewares/iotId.js");
const router = require("express").Router();

router.get("/:ioID", iotId, GETId);
router.post("/:ioID", iotId, POSTId);

module.exports = router;
