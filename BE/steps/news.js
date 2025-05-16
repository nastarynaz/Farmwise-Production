const axios = require("axios");
const myaxios = axios.create({
    baseURL: "http://localhost:3000",
});

describe("/news with pagination", () => {
    it("Returns a list of news", async () => {
        const resp = await myaxios.get("/news");
        expect(resp.data).toBeInstanceOf(Array);
    });

    it("Do pagination", async () => {
        const resp1 = await myaxios.get("/news?page=1");
        const resp2 = await myaxios.get("/news?page=2");

        expect(resp1).not.toEqual(resp2);
    });
});
