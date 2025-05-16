const crypto = require("crypto");

const algorithm = "aes-256-cbc";
const key = Buffer.from(process.env.CRYPTO_CIPHER_KEY, "base64");
const iv = Buffer.from(process.env.CRYPTO_CIPHER_IV, "base64");

function encrypt(text) {
    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return encrypted;
}

function decrypt(encrypted) {
    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encrypted);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted;
}

function checkSignature(ioID, signature) {
    return decrypt(Buffer.from(signature, "base64")).toString("ascii") === ioID;
}

module.exports = { checkSignature, encrypt, decrypt };
