const axios = require("axios");
const { farmsModel } = require("../models/farmsModel");
const { farmsPutS, farmPostS } = require("./schemas/farms");
const { getCounter } = require("./lib/counter");
const { filterQuery } = require("./lib/filterQuery");
const { iotsModel } = require("../models/iotsModel");

async function checkIoID(ioID) {
    return (await iotsModel.findOne({ ioID: ioID })) !== null;
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETRoot(req, res) {
    try {
        const result = await farmsModel.find({ uID: req.uID });
        res.status(200).json(filterQuery(result));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function POSTRoot(req, res) {
    try {
        req.body = farmPostS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        if (req.body.ioID && !(await checkIoID(req.body.ioID))) {
            res.status(404).json("IoT Not Found");
            return;
        }
        const farm = new farmsModel({
            fID: await getCounter("farms"),
            uID: req.uID,
            ...req.body,
        });
        await farm.save();
        res.status(200).json(filterQuery(farm));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETId(req, res) {
    res.status(200).json(filterQuery(req.farm));
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function PUTId(req, res) {
    try {
        req.body = farmsPutS.parse(req.body);
    } catch (err) {
        res.status(400).json("Bad Request");
        return;
    }

    try {
        if (req.body.ioID && !(await checkIoID(req.body.ioID))) {
            res.status(404).json("IoT Not Found");
            return;
        }
        // Update if not undefined
        for (let [key, value] of Object.entries(req.body)) {
            if (value !== undefined) {
                req.farm[key] = value;
            }
        }
        await req.farm.save();
        res.status(200).json(filterQuery(req.farm));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function DELETEId(req, res) {
    try {
        await farmsModel.deleteOne({ fID: req.farm.fID });
        res.status(200).json(filterQuery(req.farm));
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

const weatherAxios = axios.create({
    baseURL: process.env.WEATHER_BASE_URL,
    params: {
        key: process.env.WEATHER_API_KEY,
    },
});

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETForecast(req, res) {
    try {
        const resp = await weatherAxios.get("/forecast.json", {
            params: {
                q: req.farm.location.join(","),
            },
        });
        res.status(200).json(resp.data);
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETCurrent(req, res) {
    try {
        const resp = await weatherAxios.get("/current.json", {
            params: {
                q: req.farm.location.join(","),
            },
        });
        res.status(200).json(resp.data);
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETAlert(req, res) {
    try {
        const resp = await weatherAxios.get("/alerts.json", {
            params: {
                q: req.farm.location.join(","),
            },
        });
        res.status(200).json(resp.data);
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETLocCurrent(req, res) {
    if (!req.query.q) {
        res.status(400).json("Invalid Location");
        return;
    }

    try {
        const resp = await weatherAxios.get("/current.json", {
            params: {
                q: req.query.q,
            },
        });
        res.status(200).json(resp.data);
    } catch (err) {
        if (err.response) {
            res.status(400).json("Invalid Location");
            return;
        }
        res.status(500).json("Server Down");
    }
}

module.exports = {
    GETRoot,
    POSTRoot,
    GETId,
    PUTId,
    DELETEId,
    GETForecast,
    GETCurrent,
    GETLocCurrent,
    GETAlert,
};
