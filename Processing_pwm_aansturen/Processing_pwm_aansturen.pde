import processing.serial.*;
import cc.arduino.*;
import processing.sound.*;

AudioIn input;
Amplitude analyzer;
Arduino arduino;

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

int sumOfData;
int counter;
int average;

Serial myPort;

void setup() {
  size(512, 200);

  arduino = new Arduino(this, "COM3", 57600);
  
  myPort = new Serial(this, "COM3", 9600);

  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
}

void draw() {
  state_machine_run(read_Sensor());
  delay(100);
}

void state_machine_run(int sensorInfo)
{
  myPort.write(sensorInfo);

  int threshold = 250;

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
}

int read_Sensor() {
  float volume = analyzer.analyze();
  int sensorValue = int(volume);
  return sensorValue;
}
