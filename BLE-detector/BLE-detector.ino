/*
   Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleScan.cpp
   Ported to Arduino ESP32 by Evandro Copercini
*/
#include <sstream>
#include "report_helper.h"

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

#if defined(ESP32)
  #include <WiFi.h>
#endif

// Insert your network credentials
#define WIFI_SSID "Lior"
#define WIFI_PASSWORD "N7JDWeey"
// #define WIFI_SSID "ICST"
// #define WIFI_PASSWORD "arduino123"
// #define WIFI_SSID "EhabAzz"
// #define WIFI_PASSWORD "15011501"

// Insert Firebase project API Key
#define API_KEY "AIzaSyDz7nN8n9THIGGiV0gd20oPsLGvcyf5w5o"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://adhd-helper-bdfeb-default-rtdb.firebaseio.com/" 

FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

/*  Duration of BLE scan

    ==============                  ==============                   ==============
    =   WINDOW   =  ===INTERVAL===  =   WINDOW   =  ===INTERVAL===   =   WINDOW   =
    ==============                  ==============                   ==============
    ===============================================================================
    =                                  SCAN TIME                                  =
    ===============================================================================
*/
#define SCAN_TIME       1  // seconds
#define INTERVAL_TIME   200   // (mSecs)
#define WINDOW_TIME     100   // less or equal setInterval value

BLEScan* pBLEScan;

String deviceName;
String deviceAddress;
int16_t deviceRSSI;
uint16_t countDevice;


boolean check;
int count_stable = 0; 

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
      /* unComment when you want to see devices found */
//      Serial.printf("Found device: %s \n", advertisedDevice.toString().c_str());
    }
};

void setup() {
  Serial.begin(115200);
  Serial.println("BLEDevice init...");

  //wifi initialization and connect.
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Firebase config and signup
  
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

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

    if (d.getName() == "Mi Smart Band 5") {
      check = true;
      count_stable =0;
       
      char deviceBuffer[100];
      deviceName = d.getName().c_str();
      deviceAddress = d.getAddress().toString().c_str();
      deviceRSSI = d.getRSSI();
        
      if (deviceAddress == "ed:9a:29:07:bd:69" && deviceRSSI > -45)  
      {
        Serial.println("+++++++++++++++++++++");        
        Serial.println("Detected!!!!");
        report(signupOK);
        Serial.println("+++++++++++++++++++++");
      }
      else
      {
        Serial.println("---------------");
        Serial.println("OFF");
        Serial.println("---------------");
      }
      //---------------------------------------------------------Check if not found Mi Band-------------------------------------
    }else if(i == count-1 && check == false){
      count_stable +=1;
      if(count_stable ==20){ // set limit to reset counter
        count_stable =0;
      }
      Serial.println(count_stable);
      if(count_stable == 4){ //set quantity of scan cycle for accept missing Mi Band
        Serial.println("Not Found");
      }
    }
      check = false;
      //---------------------------------------------------------------------------------------------------------------------------
  }
  pBLEScan->clearResults();
}
