const z = require("zod");

const chatsPostS = z
    .object({
        text: z
            .string()
            .nullable()
            .transform((x) => x ?? undefined),
        image: z
            .string()
            .base64()
            .nullable()
            .transform((x) => x ?? undefined),
        fID: z
            .number()
            .nullable()
            .transform((x) => x ?? undefined),
    })
    .partial()
    .strict()
    .refine((data) => {
        return data.text || data.image;
    });

module.exports = { chatsPostS };
