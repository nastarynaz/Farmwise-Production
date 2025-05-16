const { countersModel } = require("../../models/countersModel");

async function getCounter(name) {
    let counter = await countersModel.findOne({ name: name });
    try {
        if (!counter) {
            counter = new countersModel({ name: name });
            await counter.save();
        }
    } catch (err) {}
    counter = await countersModel.findOneAndUpdate({ name: name }, { $inc: { value: 1 } });
    const out = counter.value;
    return out;
}

module.exports = { getCounter };
