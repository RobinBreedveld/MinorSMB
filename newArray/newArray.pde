import processing.serial.*;
import processing.sound.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;

AudioIn input;
Amplitude analyzer;

int setTimeSilence = 1500;
int setTimeNoise = 300;
int timeIn;
int currentTime;

float sumOfData;
int counter;
float average;

final Queue<Float> dataQueue = new ArrayDeque(20);

void setup() {
  size(512, 200);

  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
}

void draw() {
  state_machine_run(read_Sensor());
  println(dataQueue);
  delay(100);
}

void state_machine_run(float sensorInfo)
{
  println(sensorInfo);
  
  if(dataQueue.size() < 11) {
    dataQueue.add(sensorInfo);
  } else if (dataQueue.size() == 11) {
    println("Size voor berekenen van average: " + dataQueue.size());
    float sum = sum(dataQueue);
    float average = sum/11;
    println("average: " + average);

    dataQueue.remove();
    println("Size na berekenen van average: " + dataQueue.size());
  }
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

float read_Sensor() {
  float volume = analyzer.analyze();
  return volume;
}
