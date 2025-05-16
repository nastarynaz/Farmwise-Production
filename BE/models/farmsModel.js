const mongoose = require("mongoose");

const farmsSchema = new mongoose.Schema({
    fID: { type: Number, immutable: true, unique: true, required: true },
    uID: { type: String, immutable: true, required: true },
    ioID: { type: String },
    location: { type: [Number], length: 2, required: true },
    type: { type: String, required: true },
    name: { type: String, required: true },
});

module.exports = { farmsModel: mongoose.model("farms", farmsSchema) };
