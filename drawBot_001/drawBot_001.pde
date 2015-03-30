import processing.serial.*;
import geomerative.*;

//plot device
//PlotDrawbot plotter;

SVGReader reader;
String svg="";
boolean readerOK = false;

int A3width = 420;
int A3height  = 297;

int screenWide = 850;
int screenPad = 50;
int drawWide = screenWide - (2*screenPad);

int drawHigh = int(float(drawWide)*(float(A3height)/float(A3width)));
int screenHigh = drawHigh + (2*screenPad);

boolean screenOnly = true;

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
    exit();
    //writeToConsole = true;
  }
    
  while(!readerOK) {
    if(!svg.equals("")) {
      reader = new SVGReader(this, svg, drawWide, drawHigh);
      readerOK = true;
      //parse the file, store the shapes in a linear array that can be plotted
      reader.parse();
    }
  }
  
}

void draw() {
  background(200);
  noStroke();
  fill(255);
  rect(screenPad,screenPad,drawWide,drawHigh);
  
  pushMatrix();
    translate(screenPad,screenPad);
    scale(reader.scaler);
    reader.plotSVG();
  popMatrix();
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
