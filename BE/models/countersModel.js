const mongoose = require("mongoose");

const countersSchema = new mongoose.Schema({
    name: { type: String, required: true, immutable: true, unique: true },
    value: { type: Number, required: true, default: 1 },
});

module.exports = { countersModel: mongoose.model("counters", countersSchema) };
