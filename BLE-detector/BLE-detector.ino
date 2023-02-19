#include <sstream>
#include "report_helper.h"

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

#include <WiFiManager.h>

HardwareSerial Sender(1);   // Define a Serial port instance called 'Sender' using serial port 1
#define Sender_Txd_pin 17
#define Sender_Rxd_pin 16


// Insert Firebase project API Key
#define API_KEY "AIzaSyDz7nN8n9THIGGiV0gd20oPsLGvcyf5w5o"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://adhd-helper-bdfeb-default-rtdb.firebaseio.com/" 

FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;

#define SCAN_TIME       1  // seconds
#define INTERVAL_TIME   200   // (mSecs)
#define WINDOW_TIME     100   // less or equal setInterval value

#define USER_EMAIL "adhd.helper11@gmail.com"
#define USER_PASSWORD "123456"

BLEScan* pBLEScan;
String deviceName;
String deviceAddress;
int16_t deviceRSSI;
uint16_t countDevice;

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
      /* unComment when you want to see devices found */
//      Serial.printf("Found device: %s \n", advertisedDevice.toString().c_str());
    }
};

void setup() {
  Serial.begin(115200);
  // Define and start Sender serial port
  Sender.begin(115200, SERIAL_8N1, Sender_Txd_pin, Sender_Rxd_pin);
  Serial.println("BLEDevice init...");

  //wifi setup
  // WiFi.useStaticBuffers(true);
  WiFi.mode(WIFI_STA);
  // WiFi.disconnect(1);
  WiFiManager wm;
  bool res = wm.autoConnect("ADHD Helper");
  if (!res) {
    Serial.println("Failed to connect");
    // ESP.restart();
  } else {
    //if you get here you have connected to the WiFi
    Serial.println("connected...yeey :)");
  }

  // Firebase config and signup
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);


  // BLT initialization
  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true); //active scan uses more power, but get results faster
  pBLEScan->setInterval(INTERVAL_TIME); // Set the interval to scan (mSecs)
  pBLEScan->setWindow(WINDOW_TIME);  // less or equal setInterval value
}

void loop() {
  BLEScanResults foundDevices = pBLEScan->start(SCAN_TIME);

  int count = foundDevices.getCount();
  for (int i = 0; i < count; i++)
  {
    BLEAdvertisedDevice d = foundDevices.getDevice(i);

    if (d.getName() == "Mi Smart Band 5") 
    {
      char deviceBuffer[100];
      deviceName = d.getName().c_str();
      deviceAddress = d.getAddress().toString().c_str();
      deviceRSSI = d.getRSSI();
        
      if (deviceAddress == "ed:9a:29:07:bd:69" && deviceRSSI > -45)  
      {
        Serial.println("+++++++++++++++++++++");        
        Serial.println("Detected!!!!");                              // Set an example value
        Sender.print(42.42);
        report(signupOK);
        delay(10000);
        Serial.println("----------------------");
      }
    }
  }
  pBLEScan->clearResults();
}
