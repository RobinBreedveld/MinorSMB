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

int serverInstallation = 9;
int clientInstallation = 8;
int potSensor = 0;

float incomingData;


void setup() {
  size(512, 200);
  server = new Server(this, 4000);

  arduino = new Arduino(this, "COM3", 57600);
  
  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  arduino.pinMode(serverInstallation, Arduino.OUTPUT);
  arduino.pinMode(clientInstallation, Arduino.OUTPUT);
}

void draw() {
  getDataFromClient();
  activateBackData();
  state_machine_run();
  println("uberState: " + uberState);

}

public void state_machine_run()
{
  float threshold = 0.015;
  float currentAverage;

  switch (state) {
    case states.SIL:      
      currentAverage = getAverage();
      //println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.PROBSIL;
      } 
      break;

    case states.PROBSIL:     
      currentAverage = getAverage();
      //println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.PROBNOISE;
      } else {
        state = states.SIL;
      }
      break;

    case states.PROBNOISE:
      currentAverage = getAverage();
      //println("currenAverage" + currentAverage);

      if (currentAverage > threshold) {
        state = states.NOISE;
      } else {
        state = states.PROBSIL;
      }
      break;

    case states.NOISE:
      currentAverage = getAverage();
      //println("currenAverage" + currentAverage);

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
  
  activateSystem();
}

public void activateSystem() {
  if (uberState == uberStates.USILENCE) {
    arduino.digitalWrite(serverInstallation, Arduino.LOW);
    prevUberState = uberState;
} else if (uberState == uberStates.UNOISE) { 
    if(prevUberState != uberState) {
      timeIn = millis();
      prevUberState = uberState;
    }
    
    currentTime = millis();
    
    if (currentTime - timeIn < 5000) {
      println("NOT WIGGLING");
      arduino.digitalWrite(serverInstallation, 3);
    } else if(currentTime - timeIn >= 3000) { 
      println("WIGGLING");
      int potValue = getPotValue();
      
      if (potValue > 480) { 
        arduino.digitalWrite(serverInstallation, Arduino.LOW);
      } else if (potValue < 425) {
        arduino.digitalWrite(serverInstallation, 3);
      }
    }    
  }
}

public float getAverage() {
  float average = 0;
  
  while(dataQueue.size() < arrayLength) {
    float sensorValue = readSensor();
    
    println("sensorValue: " + sensorValue);

    dataQueue.add(sensorValue);
  } 
  
  //println("dataqueue voor: " + dataQueue);

  if (dataQueue.size() == arrayLength) {
    //println("Size voor berekenen van average: " + dataQueue.size());
    
    float sum = sum(dataQueue);
    average = sum/arrayLength;
    println("average: " + average);

    dataQueue.remove();
    //println("Size na berekenen van average: " + dataQueue.size());
  }
  
  return average;
}

public int getPotValue() {
  int potValue;
  potValue = arduino.analogRead(potSensor);
  println("potValue" + potValue); 
 
  return potValue;
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

void getDataFromClient(){
  Client client = server.available();
  if (client != null) {
    
    String incomingDataString;
    
    incomingDataString = client.readString();   
    incomingData = Float.parseFloat(incomingDataString);
    println("Client says: " + incomingData);
    }
}

public void activateBackData() {
  int read = getPotValue();

  //println("r " + read);

  float mappedData = map(incomingData, 0.001, 0.1, 15, 500);

   println("mappedData " + mappedData);
  
   if(read > mappedData){
     println("test");
      arduino.digitalWrite(clientInstallation, Arduino.LOW);
    } else {
      arduino.digitalWrite(clientInstallation, 3);
    }

   //if (incomingData < 0.015) {
   //   arduino.digitalWrite(clientInstallation, Arduino.LOW);
   // } 
   // else if (incomingData > 0.015){
   //   arduino.digitalWrite(clientInstallation, 3);
   // }   
}
