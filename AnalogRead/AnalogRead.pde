import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
Serial myPort;

int sensor = 2;
int read;

void setup() {
  size(512, 200);
  arduino = new Arduino(this, "COM3", 57600);
  
  arduino.pinMode(sensor, Arduino.INPUT);//setup pins to be input (A0 =0?)
}

void draw() {
    // If the analog value is higher than 512
    read = arduino.analogRead(sensor);
    println(read);
}
