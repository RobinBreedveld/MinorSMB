

// constants won't change. They're used here to set pin numbers:
const int buttonPin = 2;     
const int wirePin =  9;     

// variables will change:
int buttonState = 0;        

void setup() {
  pinMode(wirePin, OUTPUT);
  pinMode(buttonPin, INPUT);
}

void loop() {
  buttonState = digitalRead(buttonPin);
  if (buttonState == HIGH) {
    digitalWrite(wirePin, 255);
  } else {
    digitalWrite(wirePin, 0);
  }
}
