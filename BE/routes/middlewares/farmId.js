const { farmsModel } = require("../../models/farmsModel");

async function farmId(req, res, next) {
    try {
        req.farm = await farmsModel.findOne({
            uID: req.uID,
            fID: req.params.fID,
        });
        if (!req.farm) {
            res.status(404).json("Not Found");
            return;
        }

        next();
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = farmId;
