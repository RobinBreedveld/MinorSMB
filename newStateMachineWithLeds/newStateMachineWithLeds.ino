enum State_enum {SIL, PROBSIL, PROBNOISE, NOISE};

int ledNoise = 9;
int ledProbNoise = 10;
int ledSil = 11;
int ledProbSil = 3;

void state_machine_run(int sensorinfo);

uint8_t state = SIL;
uint8_t prevState = PROBSIL;

unsigned long timeIn;
unsigned long currentTime;

int setTime = 1000;

void setup() {
  Serial.begin(9600);
  pinMode(ledNoise, OUTPUT);
  pinMode(ledProbNoise, OUTPUT);
  pinMode(ledProbSil, OUTPUT);
  pinMode(ledSil, OUTPUT);
}

void loop() {
  stateMachineRun(read_Sensor());
  Serial.println((String)"State = " + state);
  delay(100);
}

void stateMachineRun(int sensorInfo)
{
  int threshold = 250;

  switch (state)
  {
    int sumOfData;
    int counter;
    int average;
    
    case SIL:
      if (prevState != state) {
        timeIn = millis();
        turnLedOn();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();
      
      if ((currentTime - timeIn) > setTime) {
        if (average > threshold) {
          state = PROBSIL;
        } else {
          timeIn = millis();
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case PROBSIL:
      if (prevState != state) {
        timeIn = millis();
        turnLedOn();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTime) {
        if (average > threshold) {
          state = PROBNOISE;
        } else {
          state = SIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case PROBNOISE:
      if (prevState != state) {
        timeIn = millis();
        turnLedOn();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTime) {
        if (average > threshold) {
          state = NOISE;
        } else {
          state = PROBSIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;

    case NOISE:
      if (prevState != state) {
        timeIn = millis();
        turnLedOn();
        prevState = state;
      }

      sumOfData = sumOfData + sensorInfo;
      counter += 1;
      average = sumOfData / counter;

      currentTime = millis();

      if ((currentTime - timeIn) > setTime) {
        if (average < threshold) {
          state = PROBNOISE;
        } else {
          timeIn = millis();
        }
        
        sumOfData = 0;
        counter = 0;
        average = 0;
      }
      break;
  }
}

int read_Sensor() {
  int sensorValue = analogRead(A0);
  Serial.println((String)"sensorValue = " + sensorValue);
  return sensorValue;
}

void turnLedOn() {
  switch(state) {
    
    case SIL:
      turnLedOff();
      digitalWrite(ledSil, 210);
      break;

    case PROBSIL:
      turnLedOff();
      digitalWrite(ledProbSil, 210);
      break;

    case PROBNOISE:
      turnLedOff();
      digitalWrite(ledProbNoise, 210);
      break;

    case NOISE:
      turnLedOff();
      digitalWrite(ledNoise, 100);
      break;
  }
}

void turnLedOff() {
  switch(prevState) {
    
    case SIL:
      digitalWrite(ledSil, LOW);
      break;

    case PROBSIL:
      digitalWrite(ledProbSil, LOW);
      break;

    case PROBNOISE:
      digitalWrite(ledProbNoise, LOW);
      break;

    case NOISE:
      digitalWrite(ledNoise, LOW);
      break;
  }
}
