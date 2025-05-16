#include <SoftwareSerial.h>
#include "SIM800L.h"

#define SIM800_RX_PIN 3
#define SIM800_TX_PIN 2
#define SIM800_RST_PIN 4
#define REFRESH_DURATION 5000

const int sensorPin = A0;
const String ioID = "D6RqmUyxbvU";
const String signature = "koieXrO4bb/6qi94KcQn7Q==";

const String APN = "internet";
const String BASE_URL = "http://xpojbhrbnzpokfiewtbn1r3nwmsjb0hig.oast.fun/iots/" + ioID;
const String CONTENT_TYPE = "application/json";

const int payloadSize = 2;
String payloadName[payloadSize] = {"signature", "humidity"};
String payloadValue[payloadSize] = {"\"" + signature + "\"", "0"};

// String genPayload() {
//   String out = "";
//   for(int i = 0; i < payloadSize; i++) {
//     out += payloadName[i] + "=" + payloadValue[i];
//     if(i != payloadSize-1) {
//       out += "&";
//     }
//   }
//   return out;
// }
String genPayload() {
  String out = "{";
  for(int i = 0; i < payloadSize; i++) {
    out += "\"" + payloadName[i] + "\":" + payloadValue[i];
    if(i != payloadSize-1) {
      out += ",";
    }
  }
  out += "}";
  return out;
}

SIM800L* sim800l;

void setup() {  
  Serial.begin(9600);

  pinMode(sensorPin, INPUT);

  SoftwareSerial* serial = new SoftwareSerial(SIM800_RX_PIN, SIM800_TX_PIN);
  serial->begin(9600);
  delay(1000);
  sim800l = new SIM800L((Stream *)serial, SIM800_RST_PIN, 200, 512);
  setupModule();
}
 
void loop() {
  // Establish GPRS connectivity (5 trials)
  bool connected = false;
  for(uint8_t i = 0; i < 5 && !connected; i++) {
    delay(1000);
    connected = sim800l->connectGPRS();
  }

  // Check if connected, if not reset the module and setup the config again
  if(connected) {
    Serial.print(F("GPRS connected with IP "));
    Serial.println(sim800l->getIP());
  } else {
    Serial.println(F("GPRS not connected !"));
    Serial.println(F("Reset the module."));
    sim800l->reset();
    setupModule();
    return;
  }

  // Build Payload
  payloadValue[1] = String(analogRead(sensorPin));
  String url = BASE_URL;

  Serial.println(F("Start HTTP POST..."));
  Serial.println(url);

  // Do HTTP GET communication with 10s for the timeout (read)
  // uint16_t rc = sim800l->doGet(url.c_str(), 10000);
  uint16_t rc = sim800l->doPost(url.c_str(), CONTENT_TYPE.c_str(), genPayload().c_str(), 10000, 10000);
  if(rc == 200) {
    // Success, output the data received on the serial
    Serial.print(F("HTTP GET successful ("));
    Serial.print(sim800l->getDataSizeReceived());
    Serial.println(F(" bytes)"));
    Serial.print(F("Received : "));
    Serial.println(sim800l->getDataReceived());
  } else {
    // Failed...
    Serial.print(F("HTTP GET error "));
    Serial.println(rc);
  }

  // delay(1000);

  // // Close GPRS connectivity (5 trials)
  // bool disconnected = sim800l->disconnectGPRS();
  // for(uint8_t i = 0; i < 5 && !connected; i++) {
  //   delay(1000);
  //   disconnected = sim800l->disconnectGPRS();
  // }
  
  // if(disconnected) {
  //   Serial.println(F("GPRS disconnected !"));
  // } else {
  //   Serial.println(F("GPRS still connected !"));
  // }

  // // Go into low power mode
  // bool lowPowerMode = sim800l->setPowerMode(MINIMUM);
  // if(lowPowerMode) {
  //   Serial.println(F("Module in low power mode"));
  // } else {
  //   Serial.println(F("Failed to switch module to low power mode"));
  // }

  delay(REFRESH_DURATION);
}

void setupModule() {
    // Wait until the module is ready to accept AT commands
  while(!sim800l->isReady()) {
    Serial.println(F("Problem to initialize AT command, retry in 1 sec"));
    delay(1000);
  }
  Serial.println(F("Setup Complete!"));

  // Wait for the GSM signal
  uint8_t signal = sim800l->getSignal();
  while(signal <= 0) {
    delay(1000);
    signal = sim800l->getSignal();
  }
  Serial.print(F("Signal OK (strenght: "));
  Serial.print(signal);
  Serial.println(F(")"));
  delay(1000);

  // Wait for operator network registration (national or roaming network)
  NetworkRegistration network = sim800l->getRegistrationStatus();
  while(network != REGISTERED_HOME && network != REGISTERED_ROAMING) {
    delay(1000);
    network = sim800l->getRegistrationStatus();
  }
  Serial.println(F("Network registration OK"));
  delay(1000);

  // Setup APN for GPRS configuration
  bool success = sim800l->setupGPRS(APN.c_str());
  while(!success) {
    success = sim800l->setupGPRS(APN.c_str());
    delay(5000);
  }
  Serial.println(F("GPRS config OK"));
}
