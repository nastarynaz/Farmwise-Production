const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });
const mongoose = require("mongoose");
const { notificationsModel } = require("./models/notificationsModel");
const { farmsModel } = require("./models/farmsModel");
const { chatsModel } = require("./models/chatsModel");
const { countersModel } = require("./models/countersModel");
const { tokensModel } = require("./models/tokensModel");
const { usersModel } = require("./models/usersModel");

async function reset() {
    await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
    await notificationsModel.deleteMany();
    await mongoose.disconnect();
}

(async function main() {
    await mongoose.connect(process.env.MONGO_DB_CONNECTION_URL);
    await chatsModel.deleteMany();
    await countersModel.deleteMany();
    await farmsModel.deleteMany();
    await notificationsModel.deleteMany();
    await tokensModel.deleteMany();
    await usersModel.deleteMany();

    // const uID = "yvuVXnfCOPfsAcsP4kCqNb0ucX63";
    // const notif = new notificationsModel({
    //     nID: await getCounter("notifications"),
    //     fID: 10,
    //     uID: uID,
    //     hash: "MYHASH" + Date.now(),
    //     content: {
    //         type: "general",
    //         body: "Ini notifikasi ku",
    //         title: "Ini judul general aku",
    //     },
    // });

    // const notif2 = new notificationsModel({
    //     nID: await getCounter("notifications"),
    //     fID: 10,
    //     uID: uID,
    //     hash: "MyHASH" + Date.now(),
    //     content: {
    //         type: "alert",
    //         body: "Ini notifikasi ku",
    //         title: "Ini judul general aku",
    //     },
    // });

    // const notif3 = new notificationsModel({
    //     nID: await getCounter("notifications"),
    //     fID: 10,
    //     uID: uID,
    //     hash: "MyHASh" + Date.now(),
    //     content: {
    //         type: "general",
    //         body: "Ini notifikasi ku",
    //         title: "Ini judul general aku",
    //     },
    //     lastRead: Date.now(),
    // });

    // await notif.save();
    // await notif2.save();
    // await notif3.save();
    // await farmsModel.deleteMany({ fID: { $lt: 14 } });
    // console.log(await farmsModel.find());

    await mongoose.disconnect();
    console.log("TEST ENDED");
})();
