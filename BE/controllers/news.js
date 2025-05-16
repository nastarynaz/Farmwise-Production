const axios = require("axios");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 */
async function GETRoot(req, res) {
    if (
        !req.query.page ||
        isNaN(parseInt(req.query.page)) ||
        parseInt(req.query.page) < 1
    ) {
        req.query.page = 1;
    }

    try {
        const resp = await axios.get(
            process.env.NEWS_BASE_URL + "/everything?",
            {
                params: {
                    q: process.env.NEWS_QUERY,
                    sortBy: "publishedAt",
                    pageSize: parseInt(process.env.NEWS_PAGE_SIZE),
                    page: req.query.page,
                    apiKey: process.env.NEWS_API_KEY,
                },
            },
        );

        res.status(200).json(resp.data.articles);
    } catch (err) {
        res.status(500).json("Server Down");
    }
}

module.exports = { GETRoot };
