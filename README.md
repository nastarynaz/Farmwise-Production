# FarmWise

FarmWise is an app about agricultural modern solution with built-in AI scan and chat to detect anomalies in plant. It also has a personalization create farm whereas we can check the weather details current and forecast

## Table of Contents

- [Features](#features)
- [Stack](#stack)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

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
- Where your farm is located  
- Sensor data like temperature, humidity, and soil moisture
- Weather forecast

### • Farmy - Farm AI powered by Gemini  
Got a question? Ask away!  
Our smart chatbot is ready to help with:
- Tips on farming and pest control  
- Decision making reccomendation
- Suggestions tailored to your farm's weather

### • FarmNews  
Stay in the loop with the latest updates:  
- Recent news actual and factual  
- News about farming programs and support  
- Cool tech and smart farming trends

### • Scan Vegetations  
Use your camera to scan your plants!  
- Instantly spot unhealthy leaves or pest problems  
- Get quick suggestions on what to do next  
- It’s like having a plant doctor in your pocket

### • Notifications  
Never miss a thing:  
- Get weekly alerts for weather conditiona ahead
- Reccomends for farms 
- Updates from the chatbot or new farming news

## Stack

### FE

- Flutter
- Gmaps

### BE

- LangChain
- Express
- MongoDB (+ mongoose)
- Gemini
- weatherapi.com

### Firebase

- Cloud Functions
- Firebase Messaging
- Firebase Auth

### IoT

- Arduino Nano
- SIM800L (using GPRS for more mobile deployment)
- Resistive Soil Moisture Sensor (more sensor is to be added)

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

- **Anas** for his role as the Hustler — driving the vision and keeping us focused.
- **Kevin** as the Hipster — crafting the user experience with creativity and design.
- **Nasta** as Hacker 1 — solving technical challenges with persistence.
- **Atila** as Hacker 2 — ensuring the backend runs smoothly and efficiently.

We deeply appreciate the support and knowledge from the wider developer community, especially:

- **Stack Overflow**
- **Arduino Forum**
- **StackExchange**

And last but not least, a heartfelt thank-you to **anime** — for keeping our spirits high during long coding nights.
