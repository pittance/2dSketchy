import processing.serial.*;
import geomerative.*;

//Use Processing 2.1.2(32bit); won't work on later versions due to geomerative library
//CONNECTIONS on EiBotBoard:
//  connect lh motor to motor 1
//  connect rh motor to motor 2
//  servo goes on B1, brown to outside

//create SVGreader object, will create Plotter class
SVGReader reader;
String svg="";            //storing svg file path
boolean readerOK = false;

//target drawing size
int a3width = 420;
int a3height  = 297;

//screen dimensions
int screenWide = 760;
int screenHigh = 574;

boolean screenOnly = true;
boolean drawing = false;

//serial communications
String outConsole;
Serial myPort;  // Create object from Serial class

//used to set if a full draw to screen is to be done
//for some large drawings full drawings will take a
//lot of time so we only draw everything once at the
//start, when we're drawing we over-draw with green
boolean fullDraw = true;  //true on first draw

void setup() {
  size(screenWide,screenHigh);
  smooth();
  selectInput("Select a file to process:", "fileSelected");
  
  //list ports
  println(Serial.list());
  
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
  }
    
  while(!readerOK) {
    if(!svg.equals("")) {
      println("launching SVGReader constructor");
      reader = new SVGReader(this, svg, a3width, a3height);
      readerOK = true;
      //parse the file, store the shapes in a linear array that can be plotted
      println("launching reader.parse()");
      reader.parse();
    }
  }
  
}

void draw() {

  if (fullDraw) {
    background(226);
    pushMatrix();
      translate(0,0);  //remove these, scaling & translation in the draw method
      scale(1);
      reader.plotSVG();  //this will draw arm reach circles and the drawing
    popMatrix();
  }
  fullDraw = false;
  
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

  //move to precise home position
  if (key == 'h') reader.plot.travTo(100,424,reader.plot.maxStepsPerSecond);
  
  //nudge by steps to correct home position
  if (key == 't') reader.plot.nudgeA(5);
  if (key == 'y') reader.plot.nudgeA(-5);
  if (key == 'i') reader.plot.nudgeB(5);
  if (key == 'o') reader.plot.nudgeB(-5);
  
  if (key == 's') {
    println("writing to eggbot now");
    drawing = true;
  }
}
