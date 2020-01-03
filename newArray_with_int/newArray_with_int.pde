import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Iterator;
import java.lang.Math;

final Queue<Integer> dataQueue = new ArrayDeque(3);

void setup() {
}

void draw() {
  state_machine_run(getRandomNumber());
  println(dataQueue);
  delay(100);
}

void state_machine_run(int randomNumber)
{
  println("randomNumber: " + randomNumber);
  if(dataQueue.size() < 3) {
    dataQueue.add(randomNumber);
  } else if (dataQueue.size() == 3) {
    println("Size voor berekenen van average: " + dataQueue.size());
    int sum = sum(dataQueue);
    int average = sum/3;
    println("average: " + average);

    dataQueue.remove();
    println("Size na berekenen van average: " + dataQueue.size());
  }
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
