const mongoose = require("mongoose");

const tokensSchema = new mongoose.Schema({
    tID: { type: String, immutable: true, unique: true, required: true },
    uID: { type: String, immutable: true, required: true },
});

module.exports = { tokensModel: mongoose.model("tokens", tokensSchema) };
