const mongoose = require("mongoose");

const chatsSchema = new mongoose.Schema({
    cID: { type: Number, immutable: true, unique: true, required: true },
    uID: { type: String, immutable: true, required: true },
    fID: { type: Number, immutable: true },
    prompt: {
        type: {
            text: { type: String, immutable: true },
            image: { type: String, immutable: true },
        },
        immutable: true,
        required: true,
    },
    answer: { type: String, immutable: true, required: true },
    date: { type: Date, default: Date.now(), immutable: true, required: true },
});

module.exports = { chatsModel: mongoose.model("chats", chatsSchema) };
