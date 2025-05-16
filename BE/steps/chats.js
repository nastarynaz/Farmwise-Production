const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const mongoose = require("mongoose");
const axios = require("axios");
const { chatsModel } = require("../models/chatsModel");
const { countersModel } = require("../models/countersModel");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/chats endpoint", () => {
    beforeAll(async () => {
        await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
        await chatsModel.deleteMany();
        await countersModel.deleteOne({ name: "chats" });
        await mongoose.disconnect();
    });

    it("Text prompt", async () => {
        const resp = await myaxios.post("/chats", {
            text: "Output ONLY the number 1!",
        });
        expect(resp.data).toBeTruthy();
    });

    it("Image prompt", async () => {
        const resp = await myaxios.post("/chats", {
            image: process.env.USER_DEFAULT_PROFILE_PICTURE,
        });
        expect(resp.data).toBeTruthy();
    });

    it("Hybrid Prompt", async () => {
        const resp = await myaxios.post("/chats", {
            text: "Tell what are the dominant color of this picture?",
            image: process.env.USER_DEFAULT_PROFILE_PICTURE,
        });
        expect(resp.data).toBeTruthy();
    });

    it("Reference farm", async () => {
        const resp = await myaxios.post("/chats", {
            fID: 1,
            text: "What are the weather in this location? Are there any alerts?",
        });
        expect(resp.data).toBeTruthy();
    });

    it("Get chats", async () => {
        const resp = await myaxios.get("/chats");
        expect(resp.data.length).toEqual(3);
    });

    it("Get chats with pagination", async () => {
        const resp = await myaxios.get("/chats?page=1");
        const resp2 = await myaxios.get("/chats?page=2");

        expect(resp).not.toEqual(resp2);
    });
});
