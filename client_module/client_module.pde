
import processing.net.*;
Client client;
String data ="t";

void setup() {
  size(400, 200);
  client = new Client(this, "145.137.19.92", 68);
}

void draw() {
  sendData();
  delay(100);
}

void sendData(){
  //println(data);
    client.write(data); // When the user hits enter, the String typed is sent to the Server.
}
