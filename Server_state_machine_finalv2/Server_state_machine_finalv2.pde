// 2 installations for server: 1 & 3
// 1 installation for backdata (client): 2

import processing.serial.*;
import cc.arduino.*;
import processing.sound.*;
import processing.net.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;

AudioIn input;
Amplitude analyzer;
Arduino arduino;
Serial myPort;
Server server;

interface states {int
                    SIL = 0,
                    PROBSIL = 1,
                    PROBNOISE = 2,
                    NOISE = 3;
                  }
                  
interface uberStates {int
                        USILENCE = 0,
                        UNOISE = 1;
                      }

int state = states.SIL;
int uberState = uberStates.USILENCE;
int prevUberState = uberStates.USILENCE;

int timeIn;
int currentTime;

final Queue<Float> dataQueue = new ArrayDeque(20);
int arrayLength = 75;

int installation1 = 10;
int installation3 = 11;
int potInstallation1 = 0;
int potInstallation3 = 2;
int potThreshAdjust = 3;

float incomingData;
boolean erbovenGeweest = false;

void setup() {
  size(512, 200);
  // sets server on certain port 
  server = new Server(this, 4000);
  
  // sets usb port where Arduino is connected
  arduino = new Arduino(this, "COM3", 57600);
  
  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  arduino.pinMode(installation1, Arduino.OUTPUT);
  arduino.pinMode(installation3, Arduino.OUTPUT);
}

void draw() {
  getDataFromClient();
  activateBackDataSystem();
  state_machine_run();
  println("uberState: " + uberState);
}

public void state_machine_run() {
  //float threshold = 0.015;
  float threshold = map(incomingData, 0.0008, 0.15, 0.005, 0.05);
  println("threshold: " + threshold);
  float currentAverage;

  switch (state) {
    case states.SIL:      
      currentAverage = getAverage();

      if (currentAverage > threshold) {
        state = states.PROBSIL;
      } 
      break;

    case states.PROBSIL:     
      currentAverage = getAverage();

      if (currentAverage > threshold) {
        state = states.PROBNOISE;
      } else {
        state = states.SIL;
      }
      break;

    case states.PROBNOISE:
      currentAverage = getAverage();

      if (currentAverage > threshold) {
        state = states.NOISE;
      } else {
        state = states.PROBSIL;
      }
      break;

    case states.NOISE:
      currentAverage = getAverage();

      if (currentAverage < threshold) {
        state = states.PROBNOISE;
      }
      break;
  }
 
  if (state == states.SIL || state == states.PROBSIL) {
    uberState = uberStates.USILENCE;
  } else {
    uberState = uberStates.UNOISE;
  }
  
  activateServerSystem();
}

public void activateServerSystem() {
  if (uberState == uberStates.USILENCE) {
    prevUberState = uberState;
    int potValue = getPotValue(potInstallation1);
    float average = getAverage();
    
    stayOnSamePositionServer(potValue, average, 0.0008, 0.1, 25, 490);
  } else if (uberState == uberStates.UNOISE) {
    if(prevUberState != uberState) {
      timeIn = millis();
      prevUberState = uberState; 
    }
    
    currentTime = millis();
    
    if (currentTime - timeIn < 2000) {
      println("NOT WIGGLING");
      int potValue = getPotValue(potInstallation1);
      float average = getAverage();
      stayOnSamePositionServer(potValue, average, 0.0008, 0.1, 25, 490);
    } else if(currentTime - timeIn >= 2000) { 
      println("WIGGLING");
      int potValue = getPotValue(potInstallation1);
      float rawMappedAverage = map(incomingData, 0.0008, 0.15, 25, 490);
      float mappedAverage = rawMappedAverage + 30;
      
      println("potValue: " + potValue);
      println("mappedValue: " + mappedAverage);
      println("erbovengeweest" + erbovenGeweest);
      
      if (potValue > 485 && erbovenGeweest == false) { 
        erbovenGeweest = true;
        println(" gaat naar beneden");
        arduino.digitalWrite(installation1, Arduino.LOW);
      } else if (potValue < mappedAverage) {
        erbovenGeweest = false;
        println(" rising");
        arduino.digitalWrite(installation1, 3);
      } else if (potValue >= mappedAverage && potValue <= 485 && erbovenGeweest == true) {
        println(" gaat opnieuw aan");
        arduino.digitalWrite(installation1, 3);      
      } else if(potValue > 485 && erbovenGeweest == true) { 
        println(" 500 + en gaat naar beneden");
        arduino.digitalWrite(installation1, Arduino.LOW);
      }
    }
  }    
  erbovenGeweest = false;
}

public void activateBackDataSystem() {
  int potValue = getPotValue(potInstallation3);

  stayOnSamePositionBackData(potValue, incomingData, 0.0008, 0.15, 25, 490);
}

public void stayOnSamePositionServer(int potValue, float source, float lowerInput, float upperInput, int lowerOutput, int upperOutput) {
  float mappedAverage = map(source, lowerInput, upperInput, lowerOutput, upperOutput);
  //println("Mapped average: " + mappedAverage);
  
  if(potValue > mappedAverage) {
    arduino.digitalWrite(installation1, Arduino.LOW);
  } else {
    arduino.digitalWrite(installation1, 3);
  }   
}

public void stayOnSamePositionBackData(int potValue, float source, float lowerInput, float upperInput, int lowerOutput, int upperOutput) {
  float mappedAverage = map(source, lowerInput, upperInput, lowerOutput, upperOutput);
  //println("Mapped average: " + mappedAverage);
  
  if(potValue > mappedAverage) {
    arduino.digitalWrite(installation3, Arduino.LOW);
  } else {
    arduino.digitalWrite(installation3, 3);
  }   
}

public int getPotValue(int sensor) {
  int potValue;
  potValue = arduino.analogRead(sensor); 
  return potValue;
}

public float getAverage() {
  float average = 0;
  
  while(dataQueue.size() < arrayLength) {
    float sensorValue = readSensor();
    
    //println("sensorValue: " + sensorValue);

    dataQueue.add(sensorValue);
  } 
  
  //println("dataqueue voor: " + dataQueue);

  if (dataQueue.size() == arrayLength) {
    //println("Size voor berekenen van average: " + dataQueue.size());
    
    float sum = sum(dataQueue);
    average = sum/arrayLength;
    //println("average: " + average);

    dataQueue.remove();
    //println("Size na berekenen van average: " + dataQueue.size());
  }
  
  return average;
}

public static float sum(Queue<Float> q) {
  float sum = 0;
  
  for (int i = 0; i < q.size(); i++) {
    float n = q.remove();
    sum += n;
    q.add(n);
  }
  
  return sum;
}

public float readSensor() {
  float volume = analyzer.analyze();
  return volume;
}

public void getDataFromClient(){
  Client client = server.available();
  if (client != null) {
    
    String incomingDataString;
    
    incomingDataString = client.readString();   
    incomingData = Float.parseFloat(incomingDataString);
    println("Client says: " + incomingData);
  }
}
