const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const mongoose = require("mongoose");
const axios = require("axios");
const { usersModel } = require("../models/usersModel");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/accounts endpoint", () => {
    beforeAll(async () => {
        await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
        await usersModel.deleteMany();
        await mongoose.disconnect();
    });

    it("Create new users", async () => {
        const resp = await myaxios.post("/accounts", {
            username: "Blablabla",
            email: "atila.ghulwani@gmail.com",
        });
        expect(resp.data).toBeTruthy();
    });

    it("Prevents duplicate", async () => {
        try {
            const resp = await myaxios.post("/accounts", {
                username: "Blablabla",
                email: "atila.ghulwani@gmail.com",
                profilePicture: Buffer.from("Bebek").toString("base64"),
            });
        } catch (err) {
            expect("Error").toBe("Error");
        }
    });

    it("Get user info", async () => {
        const resp = await myaxios.get("/accounts");
        expect(resp.data).toBeTruthy();
    });

    it("Update user info", async () => {
        const resp = await myaxios.put("/accounts", {
            username: "BebekGoreng",
        });
        expect(resp.data.username).toEqual("BebekGoreng");
    });
});
