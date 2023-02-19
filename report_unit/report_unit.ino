#define SCAN_TIME 1        // seconds
#define INTERVAL_TIME 200  // (mSecs)
#define WINDOW_TIME 100    // less or equal setInterval value
#include <WiFiManager.h>

// Digital I/O used
#define SD_CS 5
#define SPI_MOSI 23  // SD Card
#define SPI_MISO 19
#define SPI_SCK 18

#define I2S_DOUT 25
#define I2S_BCLK 27  // I2S
#define I2S_LRC 26

// storage includs and vars
#include <Arduino.h>
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

HardwareSerial Receiver(2); // Define a Serial port instance called 'Receiver' using serial port 2

#define Receiver_Txd_pin 17
#define Receiver_Rxd_pin 16

/* 2. Define the API Key */
#define API_KEY "AIzaSyDz7nN8n9THIGGiV0gd20oPsLGvcyf5w5o"

/* 3. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "adhd.helper11@gmail.com"
#define USER_PASSWORD "123456"

/* 4. Define the Firebase storage bucket ID e.g bucket-name.appspot.com */
// #define STORAGE_BUCKET_ID "BUCKET-NAME.appspot.com"
#define STORAGE_BUCKET_ID "adhd-helper-bdfeb.appspot.com"  //todo fix gs?gs://
// // Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://adhd-helper-bdfeb-default-rtdb.firebaseio.com/"


Audio audio;

// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;
bool is_in_task = false;

void setup() {
  Serial.begin(115200);
  // Define and start Receiver serial port
  Receiver.begin(115200, SERIAL_8N1, Receiver_Txd_pin, Receiver_Rxd_pin);

  //wifi setup
  WiFi.mode(WIFI_STA);
  WiFi.disconnect(1);
  WiFiManager wm;
  bool res = wm.autoConnect("ADHD Helper");
  if (!res) {
    Serial.println("Failed to connect");
    // ESP.restart();
  } else {
    //if you get here you have connected to the WiFi
    Serial.println("connected...yeey :)");
  }

  //sd setup
  pinMode(SD_CS, OUTPUT);
  digitalWrite(SD_CS, HIGH);
  SPI.begin(SPI_SCK, SPI_MISO, SPI_MOSI);
  while (!SD.begin(SD_CS, SPI)) {
    Serial.println("Error talking to SD card!");
     (true);  // end program
  }

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign download buffer size in byte */
  // Data to be downloaded will read as multiple chunks with this size, to compromise between speed and memory used for buffering.
  // The memory from external SRAM/PSRAM will not use in the TCP client internal rx buffer.
  config.fcs.download_buffer_size = 1024;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback;  // see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  //mp3 seup
  audio.setPinout(I2S_BCLK, I2S_LRC, I2S_DOUT);
  audio.setVolume(21);  // 0...21
}

// The Firebase Storage download callback function
void fcsDownloadCallback(FCS_DownloadStatusInfo info) {
  if (info.status == fb_esp_fcs_download_status_init) {
    Serial.printf("Downloading file %s (%d) to %s\n", info.remoteFileName.c_str(), info.fileSize, info.localFileName.c_str());
  } else if (info.status == fb_esp_fcs_download_status_download) {
    Serial.printf("Downloaded %d%s, Elapsed time %d ms\n", (int)info.progress, "%", info.elapsedTime);
  } else if (info.status == fb_esp_fcs_download_status_complete) {
    Serial.println("Download completed\n");
  } else if (info.status == fb_esp_fcs_download_status_error) {
    Serial.printf("Download failed, %s\n", info.errorMsg.c_str());
  }
}

void read_audio_from_firebase() {
  // Firebase.ready() should be called repeatedly to handle authentication tasks.
  if (Firebase.ready()) {
    Serial.println("\nDownload file...\n");

    // The file systems for flash and SD/SDMMC can be changed in FirebaseFS.h.
    if (!Firebase.Storage.download(&fbdo, STORAGE_BUCKET_ID , "device1", "/song.mp3" , mem_storage_type_sd ))
      Serial.println(fbdo.errorReason());

    delay(10000);
  }
}

void play_audio() {
  // if (is_in_task) return;
  is_in_task = true;
  Serial.println("play audio");
  audio.connecttoSD("/song.mp3");
  uint play_time = millis();
  while (millis() - play_time < 10000) {
    audio.loop();
  }
  audio.stopSong();
  Serial.println("end audio");
  is_in_task = false;
}

uint run_time = 0;

void loop() {
  // if the Receiver sent new characters  
  if (Receiver.available()) {
    // Display the Receivers characters
    float received_temperature = Receiver.parseFloat();
    Serial.println(received_temperature); 
    play_audio();
  }
  else if (millis() - run_time > 60000 && !is_in_task) {
    is_in_task = true;
    run_time = millis();
    read_audio_from_firebase();
    is_in_task = false;
  } 
}