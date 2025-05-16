const { iotsModel } = require("../../models/iotsModel");

async function iotId(req, res, next) {
    try {
        req.iot = await iotsModel.findOne({
            ioID: req.params.ioID,
        });
        if (!req.iot) {
            res.status(404).json("Not Found");
            return;
        }

        next();
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = iotId;
