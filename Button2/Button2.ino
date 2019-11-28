

// constants won't change. They're used here to set pin numbers:
const int buttonPin = 2;     
const int sm1Pin =  9;     
const int sm2Pin =  10;     

// variables will change:
int buttonState = 0;        

void setup() {
  pinMode(sm1Pin, OUTPUT);
  pinMode(sm2Pin, OUTPUT);
  pinMode(buttonPin, INPUT);
}

void loop() {
  buttonState = digitalRead(buttonPin);
  if (buttonState == HIGH) {
    digitalWrite(sm1Pin, 50);
    digitalWrite(sm2Pin, 50);
  } else {
    digitalWrite(sm1Pin, 0);
    digitalWrite(sm2Pin, 0);
  }
}
