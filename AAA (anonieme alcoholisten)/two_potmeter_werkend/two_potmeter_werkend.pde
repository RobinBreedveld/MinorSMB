import cc.arduino.*;
import processing.serial.*;

Arduino arduino;
Serial myPort;

//int serverInstallation = 10;
int sensor = 0;
int potmeter = 1;
int read;
int dingus;


int pinCrane1 = 9;
int pinCrane2 = 10;
//int pinButton1 = 2;
//int pinButton2 = 3;

//int button1State = 0;
//int button2State = 0;

void setup() {
  arduino = new Arduino(this, "COM3", 57600);
  
  arduino.pinMode(pinCrane1, Arduino.OUTPUT);
  arduino.pinMode(pinCrane2, Arduino.OUTPUT);
  //arduino.pinMode(pinButton1, Arduino.INPUT);
  //arduino.pinMode(pinButton2, Arduino.INPUT);
  arduino.pinMode(sensor, Arduino.INPUT);//setup pins to be input (A0 =0?)
    arduino.pinMode(potmeter, Arduino.INPUT);//setup pins to be input (A0 =0?)

}

void draw() {

    read = arduino.analogRead(sensor);
    println("r " + read);
    dingus = arduino.analogRead(potmeter);
    
    float m = map(dingus, 0, 1023, 400, 800);

    println("m " + m);
    //println("dingus  " + dingus);
    
    if(read > m){
    arduino.digitalWrite(pinCrane1, Arduino.LOW);    
    } else {
    arduino.digitalWrite(pinCrane1, 3);
        arduino.digitalWrite(pinCrane1, 3);
    }
    
  //button1State = arduino.digitalRead(pinButton1);
  //if (button1State == Arduino.HIGH) {
  //  arduino.digitalWrite(pinCrane1, 3);
  //} else if (button1State == Arduino.LOW) {
  //  arduino.digitalWrite(pinCrane1, Arduino.LOW);    
  //}
  
  
}
