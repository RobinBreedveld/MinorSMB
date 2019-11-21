enum State_enum {SIL, PROBSIL, PROBNOISE, NOISE};

void state_machine_run(int sensorinfo);

uint8_t state = SIL;
uint8_t prevState = PROBSIL;

unsigned long timeIn;
unsigned long currentTime;

int setTime = 500;

void setup() {
  Serial.begin(9600);
}

void loop() {
  state_machine_run(read_Sensor());
  Serial.println((String)"State = " + state);
  delay(100);
}

void state_machine_run(int sensorInfo)
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
      } else {        
        //STILL COUNTING, WAITING FOR THE TIME LIMIT
      }
      break;

    case PROBSIL:
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
          state = PROBNOISE;
        } else {
          state = SIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      } else {
        //STILL COUNTING, WAITING FOR THE TIME LIMIT
      }
      break;

    case PROBNOISE:
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
          state = NOISE;
        } else {
          state = PROBSIL;
        }

        sumOfData = 0;
        counter = 0;
        average = 0;
      } else {
        //STILL COUNTING, WAITING FOR THE TIME LIMIT
      }
      break;

    case NOISE:
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
          state = PROBNOISE;
        } else {
          timeIn = millis();
        }
        
        sumOfData = 0;
        counter = 0;
        average = 0;
      } else {
        //STILL COUNTING, WAITING FOR THE TIME LIMIT
      }
      break;
  }
}

int read_Sensor() {
  int sensorValue = analogRead(A0);
  Serial.println((String)"sensorValue = " + sensorValue);
  return sensorValue;
}
