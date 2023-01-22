/**
 * Created by K. Suwatchai (Mobizt)
 *
 * Email: k_suwatchai@hotmail.com
 *
 * Github: https://github.com/mobizt/Firebase-ESP-Client
 *
 * Copyright (c) 2023 mobizt
 *
 */

// This example shows how to download file from Firebase Storage bucket.

// If SD Card used for storage, assign SD card type and FS used in src/FirebaseFS.h and
// change the config for that card interfaces in src/addons/SDHelper.h

//BLE defines
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

#define SCAN_TIME       1  // seconds
#define INTERVAL_TIME   200   // (mSecs)
#define WINDOW_TIME     100   // less or equal setInterval value


// Digital I/O used
#define SD_CS          5
#define SPI_MOSI      23    // SD Card
#define SPI_MISO      19
#define SPI_SCK       18

#define I2S_DOUT      25
#define I2S_BCLK      27    // I2S
#define I2S_LRC       26

// storage includs and vars
#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the SD card interfaces setting and mounting
#include <addons/SDHelper.h>

//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// playmp4fromSDOnI2s includs and vars
#include "Audio.h"
#include "SD.h"
#include "FS.h"

Audio audio;

/* 1. Define the WiFi credentials */
// #define WIFI_SSID "ICST"
// #define WIFI_PASSWORD "arduino123"
#define WIFI_SSID "Haviva539"
#define WIFI_PASSWORD "0542447787"

/* 2. Define the API Key */
#define API_KEY "AIzaSyDz7nN8n9THIGGiV0gd20oPsLGvcyf5w5o"

/* 3. Define the user Email and password that alreadey registerd or added in your project */
// #define USER_EMAIL "USER_EMAIL"
// #define USER_PASSWORD "USER_PASSWORD"

/* 4. Define the Firebase storage bucket ID e.g bucket-name.appspot.com */
// #define STORAGE_BUCKET_ID "BUCKET-NAME.appspot.com"
#define STORAGE_BUCKET_ID "adhd-helper-bdfeb.appspot.com" //todo fix gs?gs://
// // Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://adhd-helper-bdfeb-default-rtdb.firebaseio.com/" 

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

bool taskCompleted = false;
bool signupOK = false;

// //BLE vars
// unsigned long sendDataPrevMillis = 0;

// BLEScan* pBLEScan;

// String deviceName;
// String deviceAddress;
// int16_t deviceRSSI;
// uint16_t countDevice;


// boolean check;
// int count_stable = 0;

// class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
//     void onResult(BLEAdvertisedDevice advertisedDevice) {
//       /* unComment when you want to see devices found */
// //      Serial.printf("Found device: %s \n", advertisedDevice.toString().c_str());
//     }
// };

void setup()
{
  // //BLE setup
  // // BLT initialization
  // BLEDevice::init("");
  // pBLEScan = BLEDevice::getScan();
  // pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  // pBLEScan->setActiveScan(true); //active scan uses more power, but get results faster
  // pBLEScan->setInterval(INTERVAL_TIME); // Set the interval to scan (mSecs)
  // pBLEScan->setWindow(WINDOW_TIME);  // less or equal setInterval value

  //mp3 seup
    pinMode(SD_CS, OUTPUT);      
    digitalWrite(SD_CS, HIGH);
    SPI.begin(SPI_SCK, SPI_MISO, SPI_MOSI);
    Serial.begin(115200);
    if(!SD.begin(SD_CS))
    {
      Serial.println("Error talking to SD card!");
      while(true);  // end program
    }
    audio.setPinout(I2S_BCLK, I2S_LRC, I2S_DOUT);
    audio.setVolume(21); // 0...21
    //audio.connecttoFS(SD,"/parentsrecord/device1/16bitfloat10secrecord.mp4");
    audio.connecttoFS(SD,"/16bitfloat10secrecord.mp3");

  // storage setup
    Serial.begin(115200);
    Serial.println();
    Serial.println();

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
    }
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

    /* Assign the api key (required) */
    config.api_key = API_KEY;

    /* Assign the RTDB URL (required) */
    config.database_url = DATABASE_URL;

    /* Assign the user sign in credentials */
    // auth.user.email = USER_EMAIL;
    // auth.user.password = USER_PASSWORD;

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    /* Assign download buffer size in byte */
    // Data to be downloaded will read as multiple chunks with this size, to compromise between speed and memory used for buffering.
    // The memory from external SRAM/PSRAM will not use in the TCP client internal rx buffer.
    config.fcs.download_buffer_size = 2048;

    /* Sign up */
    if (Firebase.signUp(&config, &auth, "", "")){
      Serial.println("ok");
      signupOK = true;
    } //todo add if needed
    else{
      Serial.printf("%s\n", config.signer.signupError.message.c_str());
    }

    Firebase.begin(&config, &auth);

    Firebase.reconnectWiFi(true);

    // if use SD card, mount it.
    SD_Card_Mounting(); // See src/addons/SDHelper.h
}

// The Firebase Storage download callback function
void fcsDownloadCallback(FCS_DownloadStatusInfo info)
{
    if (info.status == fb_esp_fcs_download_status_init)
    {
        Serial.printf("Downloading file %s (%d) to %s\n", info.remoteFileName.c_str(), info.fileSize, info.localFileName.c_str());
    }
    else if (info.status == fb_esp_fcs_download_status_download)
    {
        Serial.printf("Downloaded %d%s, Elapsed time %d ms\n", (int)info.progress, "%", info.elapsedTime);
    }
    else if (info.status == fb_esp_fcs_download_status_complete)
    {
        Serial.println("Download completed\n");
    }
    else if (info.status == fb_esp_fcs_download_status_error)
    {
        Serial.printf("Download failed, %s\n", info.errorMsg.c_str());
    }
}

void read_audio_from_firebase() {
  // Firebase.ready() should be called repeatedly to handle authentication tasks.    
    if (Firebase.ready() && !taskCompleted)
    {
        taskCompleted = true;

        Serial.println("\nDownload file...\n");

        // The file systems for flash and SD/SDMMC can be changed in FirebaseFS.h.
        if (!Firebase.Storage.download(&fbdo, STORAGE_BUCKET_ID /* Firebase Storage bucket id */, "device1" /* path of remote file stored in the bucket */, "/16bitfloat10secrecord.mp3" /* path to local file */, mem_storage_type_sd /* memory storage type, mem_storage_type_flash and mem_storage_type_sd */, fcsDownloadCallback /* callback function */))
            Serial.println(fbdo.errorReason()); 
    }
}


void loop()
{
  read_audio_from_firebase();

  audio.loop(); 
  
  if (!audio.isRunning()) {
    // Serial.println("\nnot raning\n");
    audio.pauseResume();
  }

//   //BLE loop
//   BLEScanResults foundDevices = pBLEScan->start(SCAN_TIME);

//   int count = foundDevices.getCount();
//   for (int i = 0; i < count; i++)
//   {
//     BLEAdvertisedDevice d = foundDevices.getDevice(i);

//     if (d.getName() == "Mi Smart Band 5") {
//       check = true;
//       count_stable =0;
       
//       char deviceBuffer[100];
//       deviceName = d.getName().c_str();
//       deviceAddress = d.getAddress().toString().c_str();
//       deviceRSSI = d.getRSSI();
        
//       if (deviceAddress == "ed:9a:29:07:bd:69" && deviceRSSI > -45)  
//       {
//         Serial.println("+++++++++++++++++++++");        
//         Serial.println("Detected!!!!");
//         report(signupOK);
//         Serial.println("+++++++++++++++++++++");
//       }
//       else
//       {
//         Serial.println("---------------");
//         Serial.println("OFF");
//         Serial.println("---------------");
//       }
//       //---------------------------------------------------------Check if not found Mi Band-------------------------------------
//     }else if(i == count-1 && check == false){
//       count_stable +=1;
//       if(count_stable ==20){ // set limit to reset counter
//         count_stable =0;
//       }
//       Serial.println(count_stable);
//       if(count_stable == 4){ //set quantity of scan cycle for accept missing Mi Band
//         Serial.println("Not Found");
//       }
//     }
//       check = false;
//       //---------------------------------------------------------------------------------------------------------------------------
//   }
//   pBLEScan->clearResults();
// }

// void report(bool signupOK){
//   if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)){
//     sendDataPrevMillis = millis();

//     // Read the current progress
//     if (Firebase.RTDB.getInt(&fbdo, "device1/progress/")) {
//       if (fbdo.dataType() == "int") {
//         int currProgress = fbdo.intData();
//         Serial.println(currProgress);

//         // Write an Float number on the database path test/count/float
//         if (Firebase.RTDB.setFloat(&fbdo, "device1/progress/", currProgress +1)){
//           Serial.println("PASSED");
//           Serial.println("PATH: " + fbdo.dataPath());
//           Serial.println("TYPE: " + fbdo.dataType());
//         }
//         else {
//           Serial.println("FAILED");
//           Serial.println("REASON: " + fbdo.errorReason());
//         }
//       }
//     }
//     else {
//       Serial.println("FAILED");
//       Serial.println("REASON: " + fbdo.errorReason());
//     }
//   }
}