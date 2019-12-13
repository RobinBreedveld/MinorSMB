import processing.serial.*;
import processing.sound.*;
import processing.net.*;

Client client;
AudioIn input;
Amplitude analyzer;

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

void setup() {
  size(512, 200);
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
  client = new Client(this, "145.137.19.1", 68);
}

void draw() {
  state_machine_run(read_Sensor());
  println(uberState);
  sendData();
  delay(100);
}

void state_machine_run(float sensorInfo)
{
  println(sensorInfo);
  
  float threshold = 0.18;

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
}

float read_Sensor() {
  float volume = analyzer.analyze();
  return volume;
}

void sendData(){
    client.write(uberState);
}
