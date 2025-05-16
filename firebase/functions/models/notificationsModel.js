const mongoose = require("mongoose");

const notificationsSchema = new mongoose.Schema({
    nID: { type: Number, immutable: true, unique: true, required: true },
    uID: { type: String, immutable: true, required: true },
    fID: { type: Number, immutable: true, required: true },
    hash: { type: String, immutable: true, required: true },
    time: {
        type: Date,
        default: Date.now(),
        immutable: true,
        required: true,
    },
    lastRead: { type: Date },
    content: {
        type: {
            type: String,
            enum: ["alert", "general"],
            immutable: true,
            required: true,
        },
        title: { type: String, immutable: true, required: true },
        body: { type: String, immutable: true, required: true },
    },
});

module.exports = {
    notificationsModel: mongoose.model("notifications", notificationsSchema),
};
