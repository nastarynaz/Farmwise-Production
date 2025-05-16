const mongoose = require("mongoose");

const usersSchema = new mongoose.Schema({
    uID: { type: String, immutable: true, unique: true, required: true },
    username: { type: String, required: true },
    email: { type: String, required: true },
    profilePicture: { type: String, required: true },
});

module.exports = { usersModel: mongoose.model("users", usersSchema) };
