import processing.serial.*;
import processing.sound.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;

AudioIn input;
Amplitude analyzer;

final Queue<Float> dataQueue = new ArrayDeque(20);
int arrayLength = 3;

void setup() {
  size(512, 200);

  input = new AudioIn(this, 0);
  input.start();
  
  analyzer = new Amplitude(this);
  analyzer.input(input);
}

void draw() {
  getAverage();
  println("dataqueue na: " + dataQueue);
  delay(100);
}

float getAverage() {
  float average = 0.0;
  
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
