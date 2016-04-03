class SVGReader {
  //shapes and points for the SVG storage
  RShape rs;        //the whole shape read from SVG
  RShape[] lin;     //linear array of shapes read recursively from the full shape
  
  PApplet parent;   //for reference to the parent class because Processing
  
  float targetWidth = 420;
  float targetHeight = 297;
  
  float scaler;
  float screenScale = 1;  //leave at 1.0, the scaling is handled in draw()
  
  boolean plotToEggbot = true;
  
  //tweaking parameters
  float tscaleY = 1.00;
  float tshiftY = 0;
  
  //class for low-level plotter settings and routines
  Plotter plot;
  
  //plotter counter, used to step through the linear plot array
  int plotStep = 0;
  boolean ended = false;
  
  SVGReader(PApplet parent, String svgName, int drawWideTarget, int drawHighTarget) {
    this.parent = parent;
    //run setups for geomerative library
    RG.init(parent);
    RG.setPolygonizer(RG.ADAPTATIVE); 
    RG.setPolygonizerAngle(radians(2));
    
    //load SVG into shape
    println("SVGReader: loading shape");
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
    println("parsing SVG...");
    parseSVG(rs);
    println("lin contains: " + lin.length);
  }
  
  private void parseSVG(RShape shp) {
    //recursively traverse through the children of the shape
    //store the shapes in the linear array of shapes, lin
    
    //find number of children
    int childs = shp.children.length; 
    println("children: " + childs); 
    
    //loop through children
    for (int i=0;i<childs;i++) {
      println("child " + i + " of " + childs);
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
    //draws the full drawing and the reach circles to the screen
    //called only once because this can be very slow
    
    //limit circles for drawing
    fill(50,50);
    noStroke();
    ellipse(plot.offx,plot.offy,2*(plot.a1+plot.a2),2*(plot.a1+plot.a2));
    ellipse(plot.offx+plot.d,plot.offy,2*(plot.a1+plot.a2),2*(plot.a1+plot.a2));
    fill(255,50);
    ellipse(plot.offx,plot.offy,2*(plot.a2-plot.a1),2*(plot.a2-plot.a1));
    ellipse(plot.offx+plot.d,plot.offy,2*(plot.a2-plot.a1),2*(plot.a2-plot.a1));
    
    //paper
    fill(255,50);
    rect(plot.poffx,plot.poffy,plot.pwide,plot.phigh);
    
    //draw all lines in black
    int numInLin = lin.length;
    
    for (int i=0;i<numInLin;i++) {
      RPoint[] pts = lin[i].getPoints();
      stroke(0);
      noFill();
      beginShape();
      for(int j=0; j<pts.length; j++) {
        //loop through points
        vertex(xformX(pts[j].x), xformY(pts[j].y));
      }
      endShape(); 
    }
  }
  
  private void drawSVGstep(int index) {
    //called each time the screen is re-drawn when drawing
    //writes shape data to plotter and then draws the
    //shape over the top of the full drawing with green
    //to show progress/position
    
    //this only draws one element of lin, based on the index argument
    
    RPoint[] pts = lin[index].getPoints();  //array of points, pulled from each lin
    
    if(pts != null){
      //sometimes we get null shapes, ignore these   
      
      //traverse to first point of this shape
      plot.penUp();
      plot.travTo(xformX(pts[0].x),xformY(pts[0].y),plot.maxStepsPerSecond);
      plot.penDown();
      
      //draw the shape
      for(int j=1; j<pts.length; j++) {
        //loop through points
        plot.drawTo(xformX(pts[j].x),xformY(pts[j].y));        
      }
      
      //now draw this single line in green to the screen
      stroke(39,152,29);
      noFill();
      beginShape();
      for(int j=0; j<pts.length; j++) {
        //loop through points
        vertex(xformX(pts[j].x), xformY(pts[j].y));
      }
      endShape(); 
    }
  }
  
  //transformation functions for x and y corrdinates
  private float xformX(float xin) {
    return ((xin*scaler)+plot.poffx);
  }
  
  private float xformY(float yin) {
    return ((yin*scaler)+plot.poffy);
  }
  
  //called repeatedly by the draw() routine, draws successive shapes from lin
  void plotLinNext() {
    if (plotStep == 0) {
      //first step
      println("start writing to eggbot");
      plot.penUp();
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
