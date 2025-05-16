const mongoose = require("mongoose");

const iotsSchema = new mongoose.Schema({
    ioID: { type: String, immutable: true, unique: true, required: true },
    humidity: { type: Number, default: 0, required: true },
});

module.exports = { iotsModel: mongoose.model("iots", iotsSchema) };
