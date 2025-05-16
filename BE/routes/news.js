const { GETRoot } = require("../controllers/news.js");
const router = require("express").Router();

router.get("/", GETRoot);

module.exports = router;
