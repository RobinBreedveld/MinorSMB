import cc.arduino.*;
import processing.serial.*;

Arduino arduino;

int pinCrane1 = 9;
int pinCrane2 = 10;
int pinButton1 = 2;
int pinButton2 = 3;

int button1State = 0;
int button2State = 0;

void setup() {
  arduino = new Arduino(this, "COM3", 57600);
  
  arduino.pinMode(pinCrane1, Arduino.OUTPUT);
  arduino.pinMode(pinCrane2, Arduino.OUTPUT);
  arduino.pinMode(pinButton1, Arduino.INPUT);
  arduino.pinMode(pinButton2, Arduino.INPUT);
}

void draw() {
  button1State = arduino.digitalRead(pinButton1);
  if (button1State == Arduino.HIGH) {
    arduino.digitalWrite(pinCrane1, 20);
  } else if (button1State == Arduino.LOW) {
    arduino.digitalWrite(pinCrane1, Arduino.LOW);    
  }
  
  button2State = arduino.digitalRead(pinButton2);
  if (button2State == Arduino.HIGH) {
    arduino.digitalWrite(pinCrane2, 20);
  } else if (button2State == Arduino.LOW) {
    arduino.digitalWrite(pinCrane2, Arduino.LOW);
  }
}
