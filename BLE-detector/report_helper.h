#include <Firebase_ESP_Client.h>

#include <Arduino.h>
//#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

//Define Firebase Data object
FirebaseData fbdo1;

unsigned long sendDataPrevMillis = 0;

void report(bool signupOK){
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();

    // Read the current progress
    if (Firebase.RTDB.getInt(&fbdo1, "device1/progress/")) {
      Serial.println(fbdo1.intData());
      if (fbdo1.dataType() == "int") {
        int currProgress = fbdo1.intData();
        Serial.println(currProgress);

        // Write an Float number on the database path test/count/float
        if (Firebase.RTDB.setIntAsync(&fbdo1, "device1/progress/", currProgress +1)){
          Serial.println("PASSED");
          Serial.println("PATH: " + fbdo1.dataPath());
          Serial.println("TYPE: " + fbdo1.dataType());
        }
        else {
          Serial.println("FAILED");
          Serial.println("REASON: " + fbdo1.errorReason());
        }
      }
    }
    else {
      Serial.println("xxx");
      Serial.println("FAILED");
      Serial.println("REASON: " + fbdo1.errorReason());
    }
  }
}
