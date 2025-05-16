const geminiModelSettings = {
  model: "gemini-2.0-flash",
  temperature: 0,
  apiKey: process.env.GOOGLE_API_KEY,
};

const geminiSystemMessages = "You are a virtual assistant for the user.";
const geminiSystemTemplates =
  "You are given the location and weather (and or IoT) data about the location in a JSON format:\n{context}";
const geminiGeneralSystemTemplates =
  "You are a farm assistant. Make a very short suggestion (1-3 small to moderate sentence) for the user {type} farm based on the farm location and weather (and or IoT) data (represented in JSON format):\n{context}";
const geminiGeneralHumanMessages = "What's is the reccomendatino for my farm?";

module.exports = {
  geminiModelSettings,
  geminiSystemMessages,
  geminiSystemTemplates,
  geminiGeneralSystemTemplates,
  geminiGeneralHumanMessages,
};
