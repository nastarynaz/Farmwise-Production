const mongoose = require("mongoose");

function deleteProperty(obj, keys) {
    for (let i = 0; i < keys.length; i++) {
        obj[keys[i]] = undefined;
        delete obj[keys[i]];
    }

    const objk = Object.keys(obj);
    for (let i = 0; i < objk.length; i++) {
        if (obj[objk[i]] instanceof Object) {
            obj[objk[i]] = deleteProperty(obj[objk[i]], keys);
        }
    }
    return obj;
}

function filterQuery(query) {
    if (query instanceof mongoose.Model) {
        query = query.toJSON();
    }
    if (query instanceof Array) {
        return query.map((obj) => {
            return filterQuery(obj);
        });
    }
    return deleteProperty(query, ["__v", "_id"]);
}

module.exports = { filterQuery };
