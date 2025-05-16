const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const mongoose = require("mongoose");
const axios = require("axios");
const { notificationsModel } = require("../models/notificationsModel");
const { countersModel } = require("../models/countersModel");
const { getCounter } = require("../controllers/lib/counter");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/notifications endpoint", () => {
    beforeAll(async () => {
        await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
        await notificationsModel.deleteMany();
        await countersModel.deleteOne({ name: "notifications" });
        await new notificationsModel({
            nID: await getCounter("notifications"),
            fID: 1,
            hash: "NO_HASH",
            content: { body: "Body", title: "Title", type: "general" },
            uID: "1",
            lastRead: new Date(),
        }).save();
        await new notificationsModel({
            nID: await getCounter("notifications"),
            fID: 1,
            hash: "NO_HASH",
            content: { body: "Body", title: "Title", type: "general" },
            uID: "1",
        }).save();
        await mongoose.disconnect();
    });

    it("Get notifications", async () => {
        const resp = await myaxios.get("/notifications");
        expect(resp.data).toBeTruthy();
    });

    it("Get notifications, unread", async () => {
        const resp = await myaxios.get("/notifications?unreadOnly=true");
        expect(resp.data[0].lastRead).toBeFalsy();
    });

    it("Get specific notification", async () => {
        const resp = await myaxios.get("/notifications/" + 1);
        expect(resp.data).toBeTruthy();
    });

    it("Read Notification", async () => {
        const resp = await myaxios.put("/notifications/read", {
            nID: [1, 2],
        });
        expect(resp.data).toBeTruthy();
        const resp2 = await myaxios.get("/notifications/" + 2);
        expect(resp2.data.lastRead).toBeTruthy();
    });

    it("Register token", async () => {
        const resp = await myaxios.post("/notifications/register", {
            token: "mytoken",
        });
        expect(resp.data).toBeTruthy();
    });

    it("Unregister token", async () => {
        const resp = await myaxios.post("/notifications/unregister", {
            token: "mytoken",
        });
        expect(resp.data).toEqual("Success");
    });
});
