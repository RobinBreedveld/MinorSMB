// Created by Sander Takkenberg & Robin Breedveld for the minor Smart Materials for Behavioural change

// 1 installation for server: 1
// 1 installation for backdata (client): 3

import processing.serial.*;
import processing.sound.*;
import processing.net.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;

Client client;
AudioIn input;
Amplitude analyzer;

final Queue<Float> dataQueue = new ArrayDeque(20);
int arrayLength = 1000;

float currentAverage;
int i = 0;

void setup() {
  size(512, 200);
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
  
  // change the ip address according to the ip address of the server
  client = new Client(this, "145.137.79.217", 4000);
}

void draw() {
  // first get the average of the noise level
  getAverage();
  println("sensorValue" + readSensor());
  // then send the data to the server
  sendData();
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

void sendData(){
  i++;
  
  // The variable "i" is instantiated, because the server got multiple values in one time. 
  // The server could not handle that, so by using the variable "i", there is kind of a delay created
  // It is needed to send the average as a string, as a float is not allowed to send to the server
  if(i > 50) {
    String currentAverageString = Float.toString(currentAverage);
    client.write(currentAverageString);
    i = 0;
  }
}
