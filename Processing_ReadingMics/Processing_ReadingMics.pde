import processing.sound.*;

AudioIn input0;
AudioIn input1;
Amplitude analyzer0;
Amplitude analyzer1;

void setup() {
  size(400, 200);

  // Start listening to the microphone
  // Create an Audio input and grab the 1st channel
  input0 = new AudioIn(this, 0);
  input1 = new AudioIn(this, 1);

  // start the Audio Input
  input0.start();
  input1.start();

  // create a new Amplitude analyzer
  analyzer0 = new Amplitude(this);
  analyzer1 = new Amplitude(this);

  // Patch the input to an volume analyzer
  analyzer0.input(input0);
  analyzer1.input(input1);
}

void draw() {
  background(255);

  // Get the overall volume (between 0 and 1.0)
  float vol0 = analyzer0.analyze();
  fill(127);
  stroke(0);

  float vol1 = analyzer1.analyze();
  fill(127);
  stroke(0);
  
  // Draw an ellipse with size based on volume
  ellipse(width/1.5, height/2, 10+vol0*200, 10+vol0*200);
  ellipse(width/3, height/2, 10+vol1*200, 10+vol1*200);
}
