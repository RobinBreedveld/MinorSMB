import cc.arduino.*;
import processing.serial.*;

Arduino arduino;

int pinCrane1 = 9;
int pinCrane2 = 11;
int pinCrane3 = 10;
int pinButton = 2;

int buttonState = 0;

void setup() {
  arduino = new Arduino(this, "COM3", 57600);
  
  arduino.pinMode(pinCrane1, Arduino.OUTPUT);
  arduino.pinMode(pinCrane2, Arduino.OUTPUT);
  arduino.pinMode(pinCrane3, Arduino.OUTPUT);
  arduino.pinMode(pinButton, Arduino.INPUT);
}

void draw() {
  buttonState = arduino.digitalRead(pinButton);
  if (buttonState == Arduino.HIGH) {
    arduino.digitalWrite(pinCrane1, 150);
    delay(1100);
    arduino.digitalWrite(pinCrane1, Arduino.LOW);
    arduino.digitalWrite(pinCrane2, 150);
    delay(1100);
    arduino.digitalWrite(pinCrane2, Arduino.LOW);
    arduino.digitalWrite(pinCrane3, 150);
    delay(1100);
    arduino.digitalWrite(pinCrane3, Arduino.LOW);
    delay(900);
    
    //arduino.digitalWrite(pinCrane1, Arduino.HIGH);
    //delay(1000);
    //arduino.digitalWrite(pinCrane3, Arduino.LOW);
    //delay(200);
    //arduino.digitalWrite(pinCrane2, Arduino.HIGH);
    //delay(1000);
    //arduino.digitalWrite(pinCrane1, Arduino.LOW);
    //delay(200);
    //arduino.digitalWrite(pinCrane3, Arduino.HIGH);
    //delay(1000);
    //arduino.digitalWrite(pinCrane2, Arduino.LOW);
    //delay(10000);
    //arduino.digitalWrite(pinCrane3, Arduino.LOW);
  } else {
    arduino.digitalWrite(pinCrane1, Arduino.LOW);    
    arduino.digitalWrite(pinCrane2, Arduino.LOW);
    arduino.digitalWrite(pinCrane3, Arduino.LOW);
  }
}
