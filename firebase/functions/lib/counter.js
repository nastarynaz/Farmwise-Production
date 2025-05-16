const { countersModel } = require("../models/countersModel");

async function getCounter(name) {
    let counter = await countersModel.findOne({ name: name });
    if (!counter) {
        counter = new countersModel({ name: name });
    }
    const out = counter.value++;
    await counter.save();
    return out;
}

module.exports = { getCounter };
