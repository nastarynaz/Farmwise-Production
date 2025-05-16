const { GETRoot, GETId, PUTRead, POSTRegister, POSTUnregister } = require("../controllers/notifications.js");
const router = require("express").Router();

router.get("/", GETRoot);
router.put("/read", PUTRead);
router.get("/:nID", GETId);
router.post("/register", POSTRegister);
router.post("/unregister", POSTUnregister);

module.exports = router;
