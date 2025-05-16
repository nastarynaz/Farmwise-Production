require("dotenv").config();
const { encrypt } = require("./controllers/lib/mycrypto");
const { iotsModel } = require("./models/iotsModel");
const { randomBytes } = require("crypto");

(async function main() {
    const mongoose = require("mongoose");
    await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);

    const ioID = randomBytes(8).toString("base64url");
    const sig = encrypt(ioID).toString("base64");

    const doc = new iotsModel({ ioID: ioID });
    await doc.save();

    await mongoose.disconnect();
    console.log(`ioID: ${ioID}\nSignature: ${sig}\n`);
})();
