const { GETRoot, GETId, PUTId, GETForecast, GETCurrent, GETLocCurrent, GETAlert, POSTRoot, DELETEId } = require("../controllers/farms.js");
const farmId = require("./middlewares/farmId.js");

const router = require("express").Router();

router.get("/", GETRoot);
router.post("/", POSTRoot);
router.get("/:fID", farmId, GETId);
router.put("/:fID", farmId, PUTId);
router.delete("/:fID", farmId, DELETEId);
router.get("/:fID/weather/forecast", farmId, GETForecast);
router.get("/:fID/weather/current", farmId, GETCurrent);
router.get("/:fID/weather/alert", farmId, GETAlert);
router.get("/weather/current", GETLocCurrent);

module.exports = router;
