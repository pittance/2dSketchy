import processing.serial.*;
import geomerative.*;

//Use Procxessing 2.1.2(32bit)
//connect lh motor to motor 1
//connect rh motor to motor 2
//servo goes on B1, brown to outside

SVGReader reader;
String svg="";
boolean readerOK = false;

int a3width = 420;
int a3height  = 297;

int screenWide = 760;
//int screenPad = 50;
//int drawWide = screenWide - (2*screenPad);

//int drawHigh = int(float(drawWide)*(float(A3height)/float(A3width)));
int screenHigh = 574;

boolean screenOnly = true;
boolean drawing = false;

String outConsole;
Serial myPort;  // Create object from Serial class

void setup() {
  size(screenWide,screenHigh);
  smooth();
  selectInput("Select a file to process:", "fileSelected");
  
  //list ports
  println(Serial.list());
  // variables for serial connection to EiBotBoard
  
  // setup serial port
  try {
    String portName = Serial.list()[0];
    println(Serial.list());
    myPort = new Serial(this, portName, 9600);
    //serial device found
    println("found: " + portName);
  } catch (ArrayIndexOutOfBoundsException e) {
    //no serial device found
    println("didn't find eggbot");
//    exit();
    //writeToConsole = true;
  }
    
  while(!readerOK) {
    if(!svg.equals("")) {
      reader = new SVGReader(this, svg, a3width, a3height);
      readerOK = true;
      //parse the file, store the shapes in a linear array that can be plotted
      reader.parse();
    }
  }
  
  //test movement code
  
}

void draw() {
//  rect(screenPad,screenPad,drawWide,drawHigh);
  background(226);
  pushMatrix();
    translate(0,0);  //remove these, scaling & translation in the draw method
    scale(1);
    reader.plotSVG();
  popMatrix();
  
  if (drawing) {
    reader.plotLinNext();
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel");
    svg = "";
    exit();
  } else {
    println("User selected " + selection.getAbsolutePath());
    svg = selection.getAbsolutePath();
  }
}

void keyPressed() {
  if (key == 'x') reader.plot.shutDown();
  if (key == 'a') reader.plot.penUp();
  if (key == 'z') reader.plot.penDown();
//  if (key == 'p') reader.plot();
//  //if (key == 'l') reader.plotLin();
//  if (key == 't') reader.plot.travTo(380,500);
//  if (key == 'g') reader.plot.travTo(380,575);
//  
//  //test rectangle
//  if (key == 'y') reader.plot.travTo(330,475);
//  if (key == 'u') reader.plot.travTo(430,475);
//  if (key == 'j') reader.plot.travTo(430,525);
//  if (key == 'h') reader.plot.travTo(330,525);
  
  if (key == 's') {
    println("writing to eggbot now");
    drawing = true;
  }
}
