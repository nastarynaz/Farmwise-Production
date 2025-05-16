const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const mongoose = require("mongoose");
const axios = require("axios");
const { iotsModel } = require("../models/iotsModel");
const { encrypt } = require("../controllers/lib/mycrypto");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/iots endpoint", () => {
    beforeAll(async () => {
        await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
        await iotsModel.deleteOne({ ioID: "TESTING" });
        await new iotsModel({ ioID: "TESTING" }).save();
        await mongoose.disconnect();
    });

    it("Get IoT information", async () => {
        const resp = await myaxios.get("/iots/TESTING");
        expect(resp.data).toBeTruthy();
    });

    it("Post IoT data", async () => {
        const resp = await myaxios.post("/iots/TESTING", {
            signature: encrypt("TESTING").toString("base64"),
            humidity: 331,
        });
        expect(resp.data).toEqual("Success");
        const resp2 = await myaxios.get("/iots/TESTING");
        expect(resp2.data.humidity).toEqual(331);
    });

    it("Rejects unknown ID", async () => {
        try {
            await myaxios.get("/iots/GAADA");
        } catch (err) {
            expect(err.response).toBeTruthy();
            return;
        }
        expect("Response").toBe("Error");
    });

    it("Rejects invalid signature", async () => {
        try {
            await myaxios.post("/iots/TESTING", {
                signature: Buffer.from("NGASAL").toString("base64"),
                humidity: 347,
            });
        } catch (err) {
            expect(err.response).toBeTruthy();
            return;
        }
        expect("Response").toBe("Error");
    });
});
