import processing.serial.*;
import cc.arduino.*;
import processing.sound.*;
import processing.net.*;

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

int setTimeSilence = 1000;
int setTimeNoise = 500;
int timeIn;
int currentTime;

float sumOfData;
int counter;
float average;

int ledServerNoise = 9;
int ledServerSilence = 10;
int ledClientSilence = 5;
int ledClientNoise = 6;

int incomingData = 0;

void setup() {
  size(512, 200);
  server = new Server(this, 68);

  arduino = new Arduino(this, "COM3", 57600);
  
  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  arduino.pinMode(ledServerSilence, Arduino.OUTPUT);
  arduino.pinMode(ledServerNoise, Arduino.OUTPUT);
  arduino.pinMode(ledClientNoise, Arduino.OUTPUT);
  arduino.pinMode(ledClientNoise, Arduino.OUTPUT);
}

void draw() {
  getData();
  state_machine_run(read_Sensor());
  println(uberState);
  delay(100);
}

void state_machine_run(float sensorInfo)
{
  println(sensorInfo);
  
  float threshold = 0.20;

  switch (state) {
    case states.SIL:      
      if (prevState != state) {
        timeIn = millis();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTimeSilence) {
        if (average > threshold) {
          state = states.PROBSIL;
        } else {
          timeIn = millis();
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case states.PROBSIL:     
      if (prevState != state) {
        timeIn = millis();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTimeSilence) {
        if (average > threshold) {
          state = states.PROBNOISE;
        } else {
          state = states.SIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case states.PROBNOISE:
      if (prevState != state) {
        timeIn = millis();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTimeNoise) {
        if (average > threshold) {
          state = states.NOISE;
        } else {
          state = states.PROBSIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case states.NOISE:
      if (prevState != state) {
        timeIn = millis();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTimeNoise) {
        if (average < threshold) {
          state = states.PROBNOISE;
        } else {
          timeIn = millis();
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;
  }
  
  if (state == states.SIL || state == states.PROBSIL) {
    uberState = uberStates.USILENCE;
  } else {
    uberState = uberStates.UNOISE;
  }
  
  if (uberState == uberStates.USILENCE) {
    arduino.digitalWrite(ledServerSilence, Arduino.HIGH);
    arduino.digitalWrite(ledServerNoise, Arduino.LOW);
  } else {
    arduino.digitalWrite(ledServerNoise, Arduino.HIGH);    
    arduino.digitalWrite(ledServerSilence, Arduino.LOW);
  }
}

float read_Sensor() {
  float volume = analyzer.analyze();
  return volume;
}

void getData(){
  Client client = server.available();
  if (client != null) {
    incomingData = client.read(); 
    println("Client says: " + incomingData);

    if (incomingData == 0) {
      arduino.digitalWrite(ledClientSilence, Arduino.HIGH);
      arduino.digitalWrite(ledClientNoise, Arduino.LOW);
    } 
    else if (incomingData == 1){
      arduino.digitalWrite(ledClientNoise, Arduino.HIGH);
      arduino.digitalWrite(ledClientSilence, Arduino.LOW);   
    }
  }
}
