import processing.serial.*;
import cc.arduino.*;
import processing.sound.*;

AudioIn input;
Amplitude analyzer;
Arduino arduino;
Serial myPort;

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

int setTime = 500;
int timeIn;
int currentTime;

float sumOfData;
int counter;
float average;

int ledNoise = 9;
int ledSilence = 10;

void setup() {
  size(512, 200);

  arduino = new Arduino(this, "COM4", 57600);
  
  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  arduino.pinMode(ledSilence, Arduino.OUTPUT);
  arduino.pinMode(ledNoise, Arduino.OUTPUT);
}

void draw() {
  state_machine_run(read_Sensor());
  println(state);
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

      if ((currentTime - timeIn) > setTime) {
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

      if ((currentTime - timeIn) > setTime) {
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

      if ((currentTime - timeIn) > setTime) {
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

      if ((currentTime - timeIn) > setTime) {
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
    arduino.digitalWrite(ledSilence, Arduino.HIGH);
    arduino.digitalWrite(ledNoise, Arduino.LOW);
  } else {
    arduino.digitalWrite(ledNoise, Arduino.HIGH);    
    arduino.digitalWrite(ledSilence, Arduino.LOW);
  }
}

float read_Sensor() {
  float volume = analyzer.analyze();
  return volume;
}
