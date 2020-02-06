// Created by Sander Takkenberg & Robin Breedveld for the minor Smart Materials for Behavioural changes

// 1 installation for server: 1
// 1 installation for backdata (client): 3

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

// installations corresponding to the number that is written on the physical crane
int installation1 = 10;
int installation3 = 11;
int potInstallation1 = 0;
int potInstallation3 = 2;
int potThreshAdjust = 3;

boolean beenAbove = false;

void setup() {
  size(512, 200);
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
  // activates backdata crane
  activateBackDataSystem();
  
  // sets the state of the system and based on that, it activates the server crane
  state_machine_run();
  println("uberState: " + uberState);
}

public void state_machine_run() {
  float threshold = map(getPotValue(potThreshAdjust), 0, 1023, 0.005, 0.05);
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
 
  // set an uberState, based on the state
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
    
    // lets the system be able to show the volume
    stayOnSamePositionServer(potValue, average, 0.0008, 0.1, 25, 490);
  } else if (uberState == uberStates.UNOISE) {
    if(prevUberState != uberState) {
      timeIn = millis();
      prevUberState = uberState; 
    }
    
    currentTime = millis();
    
    // check, based on the amount of time a user makes noise (uberState noise)
    if (currentTime - timeIn < 2000) {
      int potValue = getPotValue(potInstallation1);
      float average = getAverage();
      
      // lets the system be able to show the volume
      stayOnSamePositionServer(potValue, average, 0.0008, 0.1, 25, 490);
    } else if(currentTime - timeIn >= 2000) { 
      int potValue = getPotValue(potInstallation1);
      int potThreshAdjustValue = getPotValue(potThreshAdjust);
      float rawMappedAverage = map(potThreshAdjustValue, 0, 1023, 25, 490);
      // cheatway to make the two cranes almost having the same level
      float mappedAverage = rawMappedAverage + 30;
      
      // making the crane 'wiggling' to show that people are talking too loudly for too long - should be improved
      if (potValue > 485 && beenAbove == false) { 
        beenAbove = true;
        arduino.digitalWrite(installation1, Arduino.LOW);
      } else if (potValue < mappedAverage) {
        beenAbove = false;
        arduino.digitalWrite(installation1, 3);
      } else if (potValue >= mappedAverage && potValue <= 485 && beenAbove == true) {
        arduino.digitalWrite(installation1, 3);      
      } else if(potValue > 485 && beenAbove == true) { 
        arduino.digitalWrite(installation1, Arduino.LOW);
      }
    }
  }    
  beenAbove = false;
}

public void activateBackDataSystem() {
  int potValue = getPotValue(potInstallation3);
  int potThreshAdjustValue = getPotValue(potThreshAdjust);

  // lets the system be able to stay in one place
  stayOnSamePositionBackData(potValue, potThreshAdjustValue, 0, 1023, 25, 490);
}

public void stayOnSamePositionServer(int potValue, float source, float lowerInput, float upperInput, int lowerOutput, int upperOutput) {
  float mappedAverage = map(source, lowerInput, upperInput, lowerOutput, upperOutput);
  
  if(potValue > mappedAverage) {
    arduino.digitalWrite(installation1, Arduino.LOW);
  } else {
    arduino.digitalWrite(installation1, 3);
  }   
}

public void stayOnSamePositionBackData(int potValue, float source, float lowerInput, float upperInput, int lowerOutput, int upperOutput) {
  float mappedAverage = map(source, lowerInput, upperInput, lowerOutput, upperOutput);
  
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
    dataQueue.add(sensorValue);
  } 
  
  if (dataQueue.size() == arrayLength) {  
    float sum = sum(dataQueue);
    
    average = sum/arrayLength;
    dataQueue.remove();
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
