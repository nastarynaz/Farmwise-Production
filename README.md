# FarmWise

FarmWise is an app about agricultural modern solution with built-in AI scan and chat to detect anomalies in plant. It also has a personalization create farm whereas we can check the weather details current and forecast

## Table of Contents

-   [Features](#features)
-   [Stack](#stack)
-   [Requirements](#requirements)
-   [Installation](#installation)
-   [Usage](#usage)
-   [Contributing](#contributing)
-   [License](#license)
-   [Contact](#contact)
-   [API](#api)

```
├── .vscode/          # VSCode editor configuration (optional)
├── BE/               # Backend (server-side logic & API)
│   ├── controllers/  # Business logic for handling requests
│   ├── models/       # Data schemas (possibly using Mongoose)
│   ├── routes/       # API endpoints
│   ├── steps/        # IoT/automation step definitions
│   ├── _genIoT.js    # Generator for IoT configuration (specific to FarmWise)
│   ├── index.js      # Server entry point
│   ├── index.test.js # Backend testing
│   ├── jest.config.js # Jest configuration for testing
│   ├── package.json  # Project configuration
│   └── vercel.json   # Deployment configuration for Vercel
├── FE/               # Application frontend (Flutter UI)
│   ├── android/      # Android configuration
│   ├── ios/          # iOS configuration
│   ├── linux, macos, windows/ # Desktop platforms
│   ├── web/          # Flutter Web support
│   ├── lib/          # Main Dart code folder
│   │   └── (screens, services, models, etc.)
│   ├── assets/       # Images/icons/fonts
│   ├── pubspec.yaml  # Dependencies and configuration
│   └── test/         # Unit testing
├── firebase/         # Firebase configuration and functions
├── misc/             # Additional files (drafts, assets, documents, etc.)
├── .gitignore        # Files/folders ignored by Git
└── jsconfig.json     # JavaScript project configuration (if used)
```

## Features

### • Farm Details

All your farm info in one place!  
You can check:

-   Where your farm is located
-   Sensor data like temperature, humidity, and soil moisture
-   Weather forecast

### • Farmy - Farm AI powered by Gemini

Got a question? Ask away!  
Our smart chatbot is ready to help with:

-   Tips on farming and pest control
-   Decision making reccomendation
-   Suggestions tailored to your farm's weather

### • FarmNews

Stay in the loop with the latest updates:

-   Recent news actual and factual
-   News about farming programs and support
-   Cool tech and smart farming trends

### • Scan Vegetations

Use your camera to scan your plants!

-   Instantly spot unhealthy leaves or pest problems
-   Get quick suggestions on what to do next
-   It’s like having a plant doctor in your pocket

### • Notifications

Never miss a thing:

-   Get weekly alerts for weather conditiona ahead
-   Reccomends for farms
-   Updates from the chatbot or new farming news

## Stack

### FE

-   Flutter
-   Gmaps

### BE

-   LangChain
-   Express
-   MongoDB (+ mongoose)
-   Gemini
-   weatherapi.com

### Firebase

-   Cloud Functions
-   Firebase Messaging
-   Firebase Auth

### IoT

-   Arduino Nano
-   SIM800L (using GPRS for more mobile deployment)
-   Resistive Soil Moisture Sensor (more sensor is to be added)

## Requirements

Before starting, make sure you have met the following prerequisites:

API
on BE and Firebase

```bash
MONGO_DB_CONNECTION_URL=YOUR_MONGO_DB_CONNECTION_URL
NEWS_API_KEY=YOUR_NEWS_API_KEY
NEWS_BASE_URL=YOUR_NEWS_BASE_URL
NEWS_QUERY=YOUR_NEWS_QUERY
NEWS_PAGE_SIZE=YOUR_NEWS_PAGE_SIZE
USER_DEFAULT_PROFILE_PICTURE=YOUR_USER_DEFAULT_PROFILE_PICTURE
WEATHER_BASE_URL=YOUR_WEATHER_BASE_URL
CHATS_PAGINATION_LIMIT=YOUR_CHATS_PAGINATION_LIMIT
GOOGLE_API_KEY=YOUR_GOOGLE_API_KEY
GOOGLE_APPLICATION_CREDENTIALS=YOUR_GOOGLE_APPLICATION_CREDENTIALS
NOTIFICATION_SLEEP_TIME=YOUR_NOTIFICATION_SLEEP_TIME
NOTIFICATION_BATCH_LIMIT=YOUR_NOTIFICATION_BATCH_LIMIT
NOTIFICATION_ALERT_SCHEDULE=YOUR_NOTIFICATION_ALERT_SCHEDULE
NOTIFICATION_GENERAL_SCHEDULE=YOUR_NOTIFICATION_GENERAL_SCHEDULE
CRYPTO_CIPHER_KEY=YOUR_CRYPTO_CIPHER_KEY
CRYPTO_CIPHER_IV=YOUR_CRYPTO_CIPHER_IV
IS_TESTING=YOUR_IS_TESTING
FIREBASE_PROJECT_ID=YOUR_FIREBASE_PROJECT_ID
FIREBASE_SERVICE_ACCOUNT_ID=YOUR_FIREBASE_SERVICE_ACCOUNT_ID

```

on FE

```bash
GOOGLE_MAP_API_KEY=YOUR_GOOGLE_MAP_API_KEY
API_BASE_URL=YOUR_API_BASE_URL
```

**For Auth**
Download firebase/functions/service-account-key.json
Download FE/android/app/google-services.json
FE/android/app/src/main/AndroidManifest.xml --> Set GEO_API_KEY
FE/ios/Flutter/GoogleService-Info.plist --> Set GEO_API_KEY

## Installation

Step-by-step guide to install and set up the project.

1. Clone this repository:

```bash
git clone https://github.com/username/project-name.git
```

2. Navigate to the project directory:

```bash
cd project-name
```

3. Install dependencies:
   on BE

```bash
cd BE
npm install
```

on FE

```bash
cd FE
flutter run
```

## Usage

Example of how to use this project.

```javascript
npm run start
```

## Contributing

Fork this repository.

Create a new branch for the feature/fix:

```bash
git checkout -b new-feature
```

Commit your changes:

```bash
git commit -m "Add new feature"
```

Push to the created branch:

```bash
git push origin new-feature
```

Create a Pull Request to the main branch of this repository.

## License

This project is licensed under the MIT License.

## Contact

Email: [khoirunasmuhammad@gmail.com](mailto:khoirunasmuhammad@gmail.com), [atila.ghulwani@gmail.com](mailto:atila.ghulwani@gmail.com)

## Acknowledgements

First and foremost, we would like to thank God for the strength and inspiration to complete this project.

Special thanks to **GDGoC UGM** for the platform and opportunity that brought this team together.

We are also grateful to each member of our team:

-   **Anas** for his role as the Hustler — driving the vision and keeping us focused.
-   **Kevin** as the Hipster — crafting the user experience with creativity and design.
-   **Nasta** as Hacker 1 — solving technical challenges with persistence.
-   **Atila** as Hacker 2 — ensuring the backend runs smoothly and efficiently.

We deeply appreciate the support and knowledge from the wider developer community, especially:

-   **Stack Overflow**
-   **Arduino Forum**
-   **StackExchange**

And last but not least, a heartfelt thank-you to **anime** — for keeping our spirits high during long coding nights.

## API

**ENUM**\
NOTIFICATION_TYPE = ```{ "alert", "general" }```

**SCHEMA**\
*def* = Has default value or system-given\
*im* = Immutable\
*un* = Unique\
*prim* = Primary-key = (def,im,un)\
*?* = Nullable (although nullable, should be explicitly specified)

**User**
```
{
  uID: String (prim),
  username: String (def),
  email: String,
  profilePicture: Base64String | URL (def)
}
```

**Farm**
```
{
  fID: Int (prim),
  uID: String (im,def),  // this is the owner
  ioID: String?,
  location: [Float, Float],
  type: String,
  name: String
}
```

**Token**
```
{
  tID: String (im,un),
  uID: String (im)
}
```

**Iot**
```
{
  ioID: String (im,def,un)
  humidity: Int // Resistiveness LOW == wet
}
```

**Notification**
```
{
  nID: String (prim),
  fID: Int (def,im),
  uID: String (def,im),
  hash: String (def,im), // Can be "NO_HASH" if NotificationType is general
  time: String(Date) (def,im) // ISO Format,
  lastRead?: String(Date) (def) // ISO Format,
  content: NotificationContent (def,im)
}
```

**NotificationContent**
```
{
  type: NOTIFICATION_TYPE (def,im),
  title: String (def,im),
  body: String (def,im)
}
```

**Chat**
```
{
  cID: Int (prim),
  uID: String (def,im),
  fID?: Int (im), // References what farm
  prompt: Prompt (im),
  answer: String (def,im)
  date: String(Date) (def,im) // ISO Format
}
```

**Prompt**
```
{
  text?: String (im),
  image?: Base64String (im)
}
```

**News**
```
{
  source: {
    id?: String,
    name: String
  },
  author?: String,
  title: String,
  description?: String,
  url: String,
  urlToImage?: String,
  publishedAt: String(Date), // ISO Format
  content: String
}
```

**WeatherCondition**
```
{
  text: String,
  icon: String, // url to icon
  code: Int
}
```

**WeatherCurrent**
```
{
  last_updated_epoch: Int(Date), // Epoch (s)
  temp_c: Float,
  condition: WeatherCondition,
  wind_kph: Float,
  precip_mm: Float,
  humidity: Int,
  uv: Float
}
```

**WeatherLocation**
```
{
  name: String,  
  region: String,  
  country: String,  
  lat: Float,  
  lon: Float,  
  tz_id: String,  
  localtime_epoch: Int(Date), // Epoch (s)
  localtime: String
}
```

**WeatherForecastDay**
```
{
  maxtemp_c: Float,
  mintemp_c: Float,
  totalprecip_mm: Float,
  avghumidity: Int,
  daily_chance_of_rain: Int,
  daily_chance_of_snow: Int,
  condition: WeatherCondition,
  uv: Float
}
```

**WeatherForecastAstro**
```
{
  sunrise: String,
  sunset: String,
  moon_phase: String
}
```

**WeatherForecastHour**
```
{
  time_epoch: Int(Date), // Epoch (s)
  temp_c: Float,
  condition: WeatherCondition,
  wind_kph: Float,
  precip_mm: Float,
  chance_of_rain: Int
}
```

**WeatherForecast**
```
{
  date_epoch: Int(Date), // Epoch (s)
  day: WeatherForecastDay,
  astro: WeatherForecastAstro,
  hour: [WeatherForecastHour\]
}
```

**WeatherAlert**
```
{
  headline: String,
  msgtype: String,
  severity: String,
  urgency: String,
  areas: String,
  category: String,
  certainty: String,
  event: String,
  note: String,
  effective: String(Date), // ISO Format
  expires: String(Date), // ISO Format
  desc: String,
  instruction: String
}
```

**WeatherResponseForecast**
```
{
  location: WeatherLocation,
  current: WeatherCurrent,
  forecast: {
    forecastday: [WeatherForecast]
  }
}
```

**WeatherResponseCurrent**
```
{
  location: WeatherLocation,
  current: WeatherCurrent
}
```

**WeatherResponseAlert**
```
{
  location: WeatherLocation,
  alerts: {
    alert: [WeatherAlert]
  }
}
```


**API Server**\
User session is sent via Authorization Header

All the API below will return:

-   **(403) Invalid Session Token**\
    If session is invalid

-   **(403) Account Not Registered**\
    If account is used but not registered

-   **(400) Bad Request**\
    When POST or PUT request body does not match schema

All **(404) "Not Found"** errors will also happen if the user doesn't have access to the resource.

**GET /accounts**\
Get your account information\
ret: (200) User

**PUT /accounts**\
Update account details, return newly created user data\
ret: (200) User

```
{
  username?: String,
  email?: String,
  profilePicture?: Base64String
}
```

**POST /accounts**\
Create new user\
ret: (200) User\
err: (403) "Email Already Exist"

```
{
  username?: String,
  email: String,
  profilePicture?: Base64String
}
```

**GET /news?page=Int**\
Get latest news\
ret: (200) \[News\]

**GET /farms**\
Get a list of your farms\
ret: (200) \[Farm\]

**POST /farms**\
Create a new farm\
ret: (200) Farm\
err: (404) "IoT Not Found"

```
{
  location: [Float, Float],
  type: String,
  name: String,
  ioID?: String
}
```

**GET /farms/:fID**\
Get farm specific information\
ret: (200) Farm\
err: (404) "Not Found"

**PUT /farms/:fID**\
Update farm information, null means don't update the property\
ret: (200) Farm\
err: (404) "Not Found" || (404) "IoT Not Found"

```
{
  location?: [Int, Int],
  type?: String,
  name?: String
  ioID?: String
}
```

**DELETE /farms/:fID**\
Delete farm\
ret: (200) Farm\
err: (404) "Not Found"

**GET /farms/:fID/weather/forecast**\
Get farm forecast weather\
ret: (200) WeatherResponseForecast\
err: (404) "Not Found"

**GET /farms/:fID/weather/current**\
Get farm current weather\
ret: (200) WeatherResponseCurrent\
err: (200) "Not Found"

**GET /farms/:fID/weather/alert**\
Get farm current farm alert\
ret: (200) WeatherResponseAlert\
err: (404) "Not Found"

**GET /farms/weather/current?q=float,float**\
Get the current weather based on the location (q)\
ret: (200) WeatherResponseCurrent\
err: (400) "Invalid Location"

**GET /notifications?unreadOnly=Bool**\
Get all notification or unread only depending on the query\
ret: (200) \[Notification\]

**PUT /notifications/read**\
Read multiple or single notifications, return the notification which is being read.\
ret: (200) \[Notification\]\
err: (404) "Not Found"\
(when the supplied nID does not match any)

```
{
  nID: [String]
}
```

**GET /notifications/:nID**\
Get notification specific detail\
ret: (200) Notification\
err: (404) "Not Found"

**POST /notifications/register**\
Register to notifications\
ret: (200) Token

```
{
  token: String
}
```

**POST /notifications/unregister**\
Unregister to notifications\
ret: (200) "Success"

```
{
  token: String
}
```

**GET /chats?page=Int**\
Get chat history\
ret: (200) \[Chat\]

**POST /chats**\
Create a prompt\
ret: (200) Chat\
err: (404) "Not found" // happens when fID invalid

```
{
  // text || image == true, can't be both null
  text?: String,
  image?: String,
  fID?: Int
}
```

**GET /iots/:ioID**\
Get the IoT data\
ret: (200) Iot\
err: (404) "Not Found"

**POST /iots/:ioID**\
Post IoT data (this endpoint is for IoT device ONLY)\
ret: (200) Success\
err: (403) "Invalid Signature" | (404) "Not Found"

```
{
  signature: Base64String
  humidity: Int
}
```
