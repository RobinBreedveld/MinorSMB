import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;
import java.lang.Math;

final Queue<Integer> dataQueue = new ArrayDeque(3);
int arrayLength = 3;

void setup() {
}

void draw() {
  getAverage();
  println("dataqueue na: " + dataQueue);
  delay(100);
}

int getAverage() {
  int average = 0;
  
  while(dataQueue.size() < arrayLength){
    int randomNumber = getRandomNumber();
    
    println("randomNumber: " + randomNumber);

    dataQueue.add(randomNumber);
  }
  
  println("dataqueue voor: " + dataQueue);

  if (dataQueue.size() == arrayLength) {
    println("Size voor berekenen van average: " + dataQueue.size());
        
    int sum = sum(dataQueue);
    average = sum/arrayLength;
    println("average: " + average);

    dataQueue.remove();
    println("Size na berekenen van average: " + dataQueue.size());
  }
  
  return average;
}

public static int sum(Queue<Integer> q) {
  int sum = 0;
  
  for (int i = 0; i < q.size(); i++) {
    int n = q.remove();
    sum += n;
    q.add(n);
  }
  return sum;
}

int getRandomNumber() {
  int randomNumber = (int) Math.floor(Math.random() * 101);
  return randomNumber;
}
