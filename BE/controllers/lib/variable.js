const geminiModelSettings = {
    model: "gemini-2.0-flash",
    temperature: 0,
    apiKey: process.env.GOOGLE_API_KEY,
};

const geminiSystemMessages = "You are a farm virtual assistant for the user. Limit your scope to agriculturale topics.";
const geminiSystemTemplates = "You are given the location and weather (and or IoT) data about the {type} farm in a JSON format:\n{context}";

module.exports = {
    geminiModelSettings,
    geminiSystemMessages,
    geminiSystemTemplates,
};
