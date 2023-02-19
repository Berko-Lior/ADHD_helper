void setup() {
  pinMode(32, OUTPUT);
  Serial.begin(115200);
}

bool send_sig = true;

void loop() {
  if (send_sig) {
    Serial.println("HIGH");
    digitalWrite(32, HIGH);
    delay(5000);
  }
  else {
    Serial.println("LOW");
    digitalWrite(32, LOW);
    delay(30000);
  }
  send_sig = !send_sig;

}
