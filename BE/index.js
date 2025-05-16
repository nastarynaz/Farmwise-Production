require("dotenv").config();
const { initializeApp } = require("firebase-admin/app");
initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID,
    serviceAccountId: process.env.FIREBASE_SERVICE_ACCOUNT_ID,
});
const express = require("express");
const app = express();
const mongoose = require("mongoose");
const router = require("./routes/router.js");

mongoose.connect(process.env.MONGO_DB_CONNECTION_URL).then(() => {
    console.log("MongoDB Connected!");
});

app.use("/", router);

app.listen(process.env.PORT || 3000, () => {
    console.log("Server running on port " + (process.env.PORT || 3000));
});
