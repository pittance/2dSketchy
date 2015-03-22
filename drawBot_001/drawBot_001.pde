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

//int myWidth = 800;                         //set required screen width here
//int myHeight = int((myWidth*210)/279.4);   //height calculated
boolean screenOnly = true;

void setup() {
  size(screenWide,screenHigh);
  smooth();
//  noLoop();
  selectInput("Select a file to process:", "fileSelected");
  
    
//    println(Serial.list());
//    println("things");

  
  while(!readerOK) {
    if(!svg.equals("")) {
      reader = new SVGReader(this, svg, drawWide, drawHigh);
      readerOK = true;
      //parse the file, store the shapes in a linear array that can be plotted
      reader.parse();
    }
  }
  
  //start plotter
//  plotter = new PlotDrawbot(parent);
//  plotter.penUp();
  
}

void draw() {
  
  background(200);
  noStroke();
  fill(255);
  rect(screenPad,screenPad,drawWide,drawHigh);
  
  pushMatrix();
  try {
    translate(screenPad,screenPad);
    scale(reader.scaler);
    reader.plotSVG();
  } catch(NullPointerException np) {
//    println("probably the SVG reader wasn't created");
  }
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
