const z = require("zod");

const accountsPutS = z
    .object({
        username: z
            .string()
            .nullable()
            .transform((x) => x ?? undefined),
        email: z
            .string()
            .email()
            .nullable()
            .transform((x) => x ?? undefined),
        profilePicture: z
            .union([z.string().base64(), z.string().url()])
            .nullable()
            .transform((x) => x ?? undefined),
    })
    .partial()
    .strict();

const accountsPostS = z
    .object({
        username: z
            .string()
            .optional()
            .nullable()
            .transform((x) => x ?? undefined),
        email: z.string().email(),
        profilePicture: z
            .union([z.string().base64(), z.string().url()])
            .optional()
            .nullable()
            .transform((x) => x ?? undefined),
    })
    .strict();

module.exports = { accountsPutS, accountsPostS };
