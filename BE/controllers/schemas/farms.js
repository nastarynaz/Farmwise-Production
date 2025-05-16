const z = require("zod");

const farmPostS = z
    .object({
        location: z.array(z.number()).length(2),
        type: z.string(),
        name: z.string(),
        ioID: z
            .string()
            .optional()
            .nullable()
            .transform((x) => x ?? undefined),
    })
    .required()
    .strict();

const farmsPutS = z
    .object({
        location: z
            .array(z.number())
            .length(2)
            .nullable()
            .transform((x) => x ?? undefined),
        ioID: z.string().nullable(),
        type: z
            .string()
            .nullable()
            .transform((x) => x ?? undefined),
        name: z
            .string()
            .nullable()
            .transform((x) => x ?? undefined),
    })
    .partial()
    .strict();

module.exports = { farmPostS, farmsPutS };
