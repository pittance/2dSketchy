class SVGReader {
  //shapes and points for the SVG storage
  RShape rs;
  
  RShape[] lin;
  
  PApplet parent;
  
  float targetWidth = 420;
  float targetHeight = 297;
  
  float scaler;
  float screenScale = 1;  //leave at 1.0, the scaling is handled in draw()
  
  boolean plotToEggbot = true;
  
  //tweaking parameters
  float tscaleY = 1.00;
  float tshiftY = 0;
  
  int plotStep = 0;
  boolean ended = false;
  
  SVGReader(PApplet parent, String svgName, int drawWideTarget, int drawHighTarget) {
    this.parent = parent;
    //run setups for geomerative library
    RG.init(parent);
    RG.setPolygonizer(RG.ADAPTATIVE); 
    RG.setPolygonizerAngle(0.05);
    
    //load SVG into shape
    rs = RG.loadShape(svgName);
    println();
    println("STARTING SVGReader CLASS");
    println("Image width is: " + rs.width + " Image height is: " + rs.height);
    println("Image target width is: " + drawWideTarget + " Image target height is: " + drawHighTarget);
    float scaleW = drawWideTarget/rs.width;
    float scaleH = drawHighTarget/rs.height;
    println("Scale based on width:  " + scaleW);
    println("Scale based on height: " + scaleH);
    scaler = min(scaleW,scaleH);
    println("Using smaller scale:   " + scaler);
  }
  
  void plotScreen() {
    //initialise array of shapes
    lin = new RShape[0];
    drawAllToScreen(rs,true);
  }
  
  void parse() {
    //initialise array of shapes
    lin = new RShape[0];
    parseSVG(rs);
    println("lin contains: " + lin.length);
  }
  
  private void drawAllToScreen(RShape shp, boolean drawbotPlot) {
    //recursively traverse through the children of the shape
    
    //find number of children
    int childs = shp.children.length;  
    
    //loop through children
    for (int i=0;i<childs;i++) {
      if (shp.children[i].children == null) {
        //child has no children, found a shape, plot it
        RPoint[] pts = shp.children[i].getPoints();
        if(pts != null) {
          //add a child to lin
          lin = (RShape[])expand(lin,lin.length+1);
          lin[lin.length-1] = shp.children[i];
          //start to draw on screen
          stroke(0,200,0);
          noFill();
          beginShape();
          for(int j=0; j<pts.length-1; j++) {
            //loop through points
            vertex(pts[j].x, pts[j].y);
          }
          vertex(pts[pts.length-1].x, pts[pts.length-1].y);
          endShape(); 
        }
      } else {
        //child has children, call plotCurves again on it
        drawAllToScreen(shp.children[i],true);
      }
    }
  }
  
  private void parseSVG(RShape shp) {
    //recursively traverse through the children of the shape
    
    //find number of children
    int childs = shp.children.length;  
    
    //loop through children
    for (int i=0;i<childs;i++) {
      if (shp.children[i].children == null) {
        //child has no children, found a shape, plot it
        RPoint[] pts = shp.children[i].getPoints();
        if(pts != null) {
          //add a child to lin
          lin = (RShape[])expand(lin,lin.length+1);
          lin[lin.length-1] = shp.children[i];
        }
      } else {
        //child has children, call parseSVG again on it
        parseSVG(shp.children[i]);
      }
    }
  }
  
  void plotSVG() {
    int numInLin = lin.length;
    for (int i=0;i<numInLin;i++) {
      RPoint[] pts = lin[i].getPoints();
      stroke(0,200,0);
      noFill();
      beginShape();
      for(int j=0; j<pts.length-1; j++) {
        //loop through points
        vertex(pts[j].x, pts[j].y);
      }
      vertex(pts[pts.length-1].x, pts[pts.length-1].y);
      endShape(); 
    }
  }
  
  class Plotter {
    Plotter() {
    }
  }
  
//  private void plotCurvesLinearStep(int index) {
//    RPoint[] pts = lin[index].getPoints();
//    if(pts != null){
//      if (plotToEggbot) {
//        plotter.penUp();
//        plotter.traversePC(scaler*pts[0].x,tscaleY*scaler*pts[0].y+tshiftY);
//        plotter.penDown();
//        stroke(200,50,0);
//        noFill();
//        beginShape();
//      } else {
//        //start to draw on screen
//        stroke(0,200,0);
//        noFill();
//        beginShape();
//      }
//      for(int j=0; j<pts.length-1; j++) {
//        //loop through points
//        if (plotToEggbot) {
//          plotter.plotPC(scaler*pts[j].x,tscaleY*scaler*pts[j].y+tshiftY,scaler*pts[j+1].x,tscaleY*scaler*pts[j+1].y+tshiftY);
//          vertex(screenScale*pts[j].x, screenScale*pts[j].y);
//        } else {
//          vertex(screenScale*pts[j].x, screenScale*pts[j].y);
//        }
//      }
//      if (plotToEggbot) {
//        plotter.penUp();
//        endShape(); 
//      } else {
//        vertex(screenScale*pts[pts.length-1].x, screenScale*pts[pts.length-1].y);
//        endShape(); 
//      }      
//    }
//  }
//  
//  private void plotCurvesLinear() {
//    //plots a linear array of curves in shp, found by recursively running over the input SVG in plotCurves
//    for (int i=0;i<lin.length;i++) {
//      plotCurvesLinearStep(i);
//    }
//  }
//    
//  private void plotCurves(RShape shp) {
//    //recursively traverse through the children of the shape
//    int childs = shp.children.length;
//    for (int i=0;i<childs;i++) {
//      //println("child count: " + i);
//      if (shp.children[i].children == null) {
//        //child has no children, found a shape, plot it
//        //println("plotting shape...");
//        RPoint[] pts = shp.children[i].getPoints();
//        //plotting on the machine
//        //traverse out to start point
//        if(pts != null) {
//          if (plotToEggbot) {
//            plotter.penUp();
//            plotter.traversePC(scaler*pts[0].x,tscaleY*scaler*pts[0].y+tshiftY);
//            plotter.penDown();
//          } else {
//            //add a child to lin
//            lin = (RShape[])expand(lin,lin.length+1);
//            lin[lin.length-1] = shp.children[i];
//            //start to draw on screen
//            stroke(0,200,0);
//            noFill();
//            beginShape();
//          }
//          for(int j=0; j<pts.length-1; j++) {
//            //loop through points
//            if (plotToEggbot) {
//              plotter.plotPC(scaler*pts[j].x,tscaleY*scaler*pts[j].y+tshiftY,scaler*pts[j+1].x,tscaleY*scaler*pts[j+1].y+tshiftY);
//            } else {
//              vertex(screenScale*pts[j].x, screenScale*pts[j].y);
//            }
//          }
//          if (plotToEggbot) {
//            plotter.penUp();
//          } else {
//            vertex(screenScale*pts[pts.length-1].x, screenScale*pts[pts.length-1].y);
//            endShape(); 
//          }      
//        }
//      } else {
//        //child has children, call plotCurves again on it
//        plotCurves(shp.children[i]);
//      }
//    }
//  }
//  void plot() {
//    plotToEggbot = true;
//    plotter.penUp();
//    plotCurves(rs);
//    plotter.goHome();
//    //can't shut down plotter here - it always stops before the final move home
//  }
//  
//  void plotLin() {
//    plotToEggbot = true;
//    plotter.penUp();
//    plotCurvesLinear();
//    plotter.goHome();
//    //can't shut down plotter here - it always stops before the final move home
//  }
//  
//  void plotLinNext() {
//    if (plotStep == 0) {
//      println("start writing to eggbot");
//      plotToEggbot = true;
//      plotter.penUp();
//    }
//    //println("step: " + plotStep);
//    if (plotStep > lin.length-1) {
//      //plotting ended, go home
//      if (!ended) plotter.goHome();
//      ended = true;
//    } else {
//      plotCurvesLinearStep(plotStep);
//      plotStep++;
//    }
//  }
  
}
