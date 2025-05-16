const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const mongoose = require("mongoose");
const axios = require("axios");
const { farmsModel } = require("../models/farmsModel");
const { countersModel } = require("../models/countersModel");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/farms endpoint", () => {
    beforeAll(async () => {
        await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
        await farmsModel.deleteMany();
        await countersModel.deleteOne({ name: "farms" });
        await mongoose.disconnect();
    });

    it("Create new farms", async () => {
        const resp = await myaxios.post("/farms", {
            location: [48.8567, 2.3508],
            type: "Kejagung",
            name: "Farm gw",
        });
        expect(resp.data).toBeTruthy();
    });

    it("Get all farms", async () => {
        const resp = await myaxios.post("/farms", {
            location: [48.8567, 2.3508],
            type: "Besi",
            name: "Farm #2",
        });
        expect(resp.data).toBeTruthy();

        const resp2 = await myaxios.get("/farms");
        expect(resp2.data.length).toEqual(2);
    });

    it("Update farms info", async () => {
        const resp = await myaxios.put("/farms/1", {
            name: "Sigmaboi",
        });
        expect(resp.data.name).toEqual("Sigmaboi");
    });

    it("Deletes farm", async () => {
        const resp = await myaxios.post("/farms", {
            location: [48.8567, 2.3508],
            type: "Besi",
            name: "Farm #3",
        });
        const resp2 = await myaxios.delete("/farms/" + resp.data.fID);
        expect(resp2.data).toBeTruthy();
    });

    it("Create new farms with IoT", async () => {
        const resp = await myaxios.post("/farms", {
            location: [48.8567, 2.3508],
            type: "IoT",
            name: "Farm gw",
            ioID: "TESTING",
        });
        expect(resp.data.ioID).toBeTruthy();

        const resp2 = await myaxios.put("/farms/1", {
            ioID: "TESTING",
        });
        expect(resp2.data.ioID).toBeTruthy();

        const resp3 = await myaxios.put("/farms/" + resp.data.fID, {
            ioID: null,
        });
        expect(resp3.data.ioID).toBeFalsy();

        const resp4 = await myaxios.put("/farms/1", {});
        expect(resp4.data.ioID).toBeTruthy();
    });

    it("Rejects invalid IoT", async () => {
        try {
            await myaxios.post("/farms", {
                location: [48.8567, 2.3508],
                type: "IoT",
                name: "Farm gw",
                ioID: "INVALIDIOID",
            });
        } catch (err) {
            expect(err.response).toBeTruthy();
            try {
                await myaxios.put("/farms/1", {
                    ioID: "INVALIDIOID",
                });
            } catch (err2) {
                expect(err2.response).toBeTruthy();
                return;
            }
        }
        expect("Response").toBe("Error");
    });

    it("Get forecasted weather", async () => {
        const resp = await myaxios.get("/farms/1/weather/forecast");
        expect(resp.data).toBeTruthy();
    });

    it("Get current weather", async () => {
        const resp = await myaxios.get("/farms/1/weather/current");
        expect(resp.data).toBeTruthy();
    });

    it("Get alert weather", async () => {
        const resp = await myaxios.get("/farms/1/weather/alert");
        expect(resp.data).toBeTruthy();
    });

    it("Get current weather based on location", async () => {
        const resp = await myaxios.get("/farms/weather/current?q=-7.7765367,110.3438727");
        expect(resp.data).toBeTruthy();
    });
});
