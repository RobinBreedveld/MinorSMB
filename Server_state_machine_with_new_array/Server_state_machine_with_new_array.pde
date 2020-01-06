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
int prevState = states.PROBSIL;
int uberState = uberStates.USILENCE;

final Queue<Float> dataQueue = new ArrayDeque(20);
int arrayLength = 75;

int ledServerNoise = 9;
int ledServerSilence = 10;
int ledClientSilence = 5;
int ledClientNoise = 6;

int incomingData = 0;

void setup() {
  size(512, 200);
  server = new Server(this, 68);

  //arduino = new Arduino(this, "COM3", 57600);
  
  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  //arduino.pinMode(ledServerSilence, Arduino.OUTPUT);
  //arduino.pinMode(ledServerNoise, Arduino.OUTPUT);
  //arduino.pinMode(ledClientNoise, Arduino.OUTPUT);
  //arduino.pinMode(ledClientNoise, Arduino.OUTPUT);
}

void draw() {
  getDataFromClient();
  state_machine_run();
  println(uberState);
}

void state_machine_run()
{
  float threshold = 0.015;
  float currentAverage;

  switch (state) {
    case states.SIL:      
      if (prevState != state) {
        prevState = state;
      }

      currentAverage = getAverage();
      println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.PROBSIL;
      } 
      break;

    case states.PROBSIL:     
      if (prevState != state) {
        prevState = state;
      }

      currentAverage = getAverage();
      println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.PROBNOISE;
      } else {
        state = states.SIL;
      }
      break;

    case states.PROBNOISE:
      if (prevState != state) {
        prevState = state;
      }

      currentAverage = getAverage();
      println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.NOISE;
      } else {
        state = states.PROBSIL;
      }
      break;

    case states.NOISE:
      if (prevState != state) {
        prevState = state;
      }

      currentAverage = getAverage();
      println("currenAverage" + currentAverage);

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
  
  //if (uberState == uberStates.USILENCE) {
  //  arduino.digitalWrite(ledServerSilence, Arduino.HIGH);
  //  arduino.digitalWrite(ledServerNoise, Arduino.LOW);
  //} else {
  //  arduino.digitalWrite(ledServerNoise, Arduino.HIGH);    
  //  arduino.digitalWrite(ledServerSilence, Arduino.LOW);
  //}
}

float getAverage() {
  float average = 0;
  
  while(dataQueue.size() < arrayLength) {
    float sensorValue = readSensor();
    
    println("sensorValue: " + sensorValue);

    dataQueue.add(sensorValue);
  } 
  
  println("dataqueue voor: " + dataQueue);

  if (dataQueue.size() == arrayLength) {
    println("Size voor berekenen van average: " + dataQueue.size());
    
    float sum = sum(dataQueue);
    average = sum/arrayLength;
    println("average: " + average);

    dataQueue.remove();
    println("Size na berekenen van average: " + dataQueue.size());
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

float readSensor() {
  float volume = analyzer.analyze();
  return volume;
}

void getDataFromClient(){
  Client client = server.available();
  if (client != null) {
    incomingData = client.read(); 
    println("Client says: " + incomingData);

    //if (incomingData == 0) {
    //  arduino.digitalWrite(ledClientSilence, Arduino.HIGH);
    //  arduino.digitalWrite(ledClientNoise, Arduino.LOW);
    //} 
    //else if (incomingData == 1){
    //  arduino.digitalWrite(ledClientNoise, Arduino.HIGH);
    //  arduino.digitalWrite(ledClientSilence, Arduino.LOW);   
    //}
  }
}
