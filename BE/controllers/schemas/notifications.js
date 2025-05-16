const z = require("zod");

const notificationsPutS = z
    .object({
        nID: z.array(z.number()),
    })
    .required()
    .strict();

const notificationsPostS = z
    .object({
        token: z.string(),
    })
    .required()
    .strict();

module.exports = { notificationsPutS, notificationsPostS };
