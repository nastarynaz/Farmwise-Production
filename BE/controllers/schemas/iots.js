const z = require("zod");

const iotsPostS = z
    .object({
        signature: z.string().base64(),
        humidity: z.number().int(),
    })
    .required()
    .strict();

module.exports = { iotsPostS };
