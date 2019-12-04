import processing.net.*;

Server server;

int incomingMessage = 0;

void setup() {  
  server = new Server(this, 68);
}

void draw() {
  Client client = server.available();
  if (client != null) {
    incomingMessage = client.read(); 
    println("Client says: " + incomingMessage);
  }
}
