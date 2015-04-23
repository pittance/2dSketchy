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
  
  Plotter plot;
  
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
    
    //initialise Plotter
    plot = new Plotter();
    plot.initialise();
  }
  
  //run constructor
  //
  //run parse
  //  initialises lin
  //  calls parseSVG
  //
  //run plotSVG
  //  draws contents of lin to screen
  
  void parse() {
    //initialise array of shapes
    lin = new RShape[0];
    parseSVG(rs);
    println("lin contains: " + lin.length);
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
  
  void plotScreen() {
    //initialise array of shapes
    lin = new RShape[0];
    drawAllToScreen(rs,true);
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
  
  void plotSVG() {
    int numInLin = lin.length;
    for (int i=0;i<numInLin;i++) {
      RPoint[] pts = lin[i].getPoints();
      stroke(0,200,0);
      noFill();
      beginShape();
      for(int j=0; j<pts.length; j++) {
        //loop through points
        vertex(pts[j].x, pts[j].y);
      }
      endShape(); 
    }
  }
  
  void drawSVG() {
    int numInLin = lin.length;
    for (int i=0;i<numInLin;i++) {
      RPoint[] pts = lin[i].getPoints();
      if (i==0) {
        //first shape, traverse out to first point
        //pen up
        plot.travTo(pts[0].x, pts[0].y);
      }
      //pen down
      for(int j=0; j<pts.length; j++) {
        //loop through points
        plot.travTo(pts[j].x, pts[j].y);
      }
      //pen up
    }
  }
  
  private void drawSVGstep(int index) {
    RPoint[] pts = lin[index].getPoints();
    if(pts != null){
      //traverse to first point
//      plot.penUp();
      plot.travTo(pts[0].x,pts[0].y);
      println("traverse move - x: " + pts[0].x + " y: " + pts[0].y);
//      plotter.penDown();

      for(int j=1; j<pts.length; j++) {
        //loop through points
        plot.travTo(pts[j].x,pts[j].y);
        println("draw move - x: " + pts[j].x + " y: " + pts[j].y);
      }
    }
  }
  
  void plotLinNext() {
    if (plotStep == 0) {
      println("start writing to eggbot");
//      plot.penUp();
    }
    //println("step: " + plotStep);
    if (plotStep > lin.length-1) {
      //plotting ended, go home
      if (!ended) plot.goHome();
      ended = true;
    } else {
      drawSVGstep(plotStep);
      plotStep++;
    }
  }
  
  
  
}
