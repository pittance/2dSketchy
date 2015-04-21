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
    float x1, y1, x, y, x2, y2;
    float a1, a2, a3, d, s, r;
    float aeff;       //effective length of RH arm incl extension
    float sigma,phi;  //another angle in the lower RH arm (between aeff and a3)
    float offx;       //offset of LHS in x
    float offy;       //offset of LHS in y
    float xo,yo;
    float xprime,yprime;
    float x1_2, y1_2, x2_2, y2_2;
    float xchange, ychange;
    float ang1, ang2, ang3, ang4;
    float xlength, ylength, hyp;
    float cosC, sinA;
    
    float poffx, poffy, pwide, phigh;
    
    //current positions
    float alph;             //exact angle of alpha
    float beta;             //exact angle of beta
    float appAlph;          //approximate (stepped) alpha
    float appBeta;          //approximate (stepped) beta
    //target positions
    float alphT;
    float betaT;
    
    float anglePerStep;     //degrees per step, set in constructor
    float gearRatio = 40/9;
    float stepsPerRev = 200;
    float microStep = 8;
    
    
    int aSteps=0;           //step counter
    int bSteps=0;           //step counter
    
    float xHome,yHome;      //home point coordinates
    
    // pen settings
    int penPause = 250;
    int penUpVal = 12000;  //28000
    int penDownVal = 14000;  //22000
    String outConsole;
    
    //speed settings
    int maxStepsPerSecond = 500;
//    Implement speed control by rotational speed at shoulder, not at pen
//    (max stepper speed is the only thing we care about and pen speed
//    is only tangentially related to this) so we check for each motor
//    move what is the limiting stepper (normally the one moving farthest)
//    and move that at the fastest speed we define and then the other will
//    move slower. This should mean that the plotter always moves as fast
//    as it can (unless we want to slow it down for some reason)
    
    Plotter() {
      //degrees per step (~0.05 for 8x microstep and 40/9 ratio)
      anglePerStep = 360/(gearRatio * stepsPerRev * microStep);
      
      //initialisation of plotter - (0,0) is top left of board
      offx = 281;        //offset of LHS in x
      offy = 32;         //offset of LHS in y
      a1 = 220;          //arm length - upper
      a2 = 398;          //arm length - lower
      a3 = 33;           //arm length - pen extension
      aeff = a2+a3;      //effective lower arm length incl extension
      d = 201;           //separation of shoulders
      
      //initialisation of page - (0,0) is top left of board
      poffx = 172.5;
      poffy = 150;
      pwide = 420;
      phigh = 297;
      
      //TEMPORARY - TO BE REPLACED WITH HOMING
      //set home position
      xHome = 380;
      yHome = 575;
      float[] temp = alphabeta(xHome,yHome);
      alph = temp[0];
      beta = temp[1];
      
      //assume start position is a whole step + exact
      appAlph = alph;
      appBeta = beta;
      aSteps = 0;
      bSteps = 0;
      
//      
//        alpha and beta are the angles of the arms:
//              0deg                0deg
//              |                   |  
//              |                   | 
//              |                   | 
//      90deg---o [alpha]   [beta]  o---90deg
//              |                   | 
//              |                   |                        
//              |                   |  
//            180deg              180deg 
//      
//      
//        coordinate system:
//              <offx><---d---->
//              ^     o        o
//            offy
//              x--------------------|
//              |                    |
//              |         A3         |
//              |                    |
//              |                    |
//              |____________________|
//      
      
      outConsole = ("SC,4," + penDownVal + "\r");  //17000? SC,4,<servo_min> - sets the minimum value for the servo (1 to 65535)
      myPort.write(outConsole);
      outConsole = ("SC,11,300\r");  //SC,10,<servo_rate> - sets the rate of change of the servo (when going up/down)
      myPort.write(outConsole);
      outConsole = ("SC,12,500\r");  //SC,10,<servo_rate> - sets the rate of change of the servo (when going up/down)
      myPort.write(outConsole);
    }
    
    float[] alphabeta(float x, float y) {
      //inverse kinematic calculation - calculate alpha and beta for input x,y
            
      //RH arm (incl extension)
      //aeff is calculate once in setup
      xlength = x - (offx + d);
      ylength = y - offy;
      hyp = dist((offx + d), offy, x, y);
      cosC = (sq(a1)+sq(hyp)-sq(aeff))/(2*a1*hyp);
      ang1 = degrees(acos(cosC));
      sinA = (a1*sin(radians(ang1)))/aeff;
      ang4 = degrees(asin(sinA));
      ang2 = (degrees(asin(xlength / hyp))) - ang4;
      ang3 = 90 - ang2;
      xchange = aeff*sin(radians((ang2)));
      ychange = -aeff*sin(radians((ang3)));
      x2_2 = x - xchange;
      y2_2 = y + ychange;
      beta = 90 + (degrees(atan2((y2_2-offy), (x2_2-(d+offx)))));
      phi = 180-(degrees(atan2((y-y2_2),(x2_2-x))));
      xo=cos(radians(phi))*a3;
      yo=sin(radians(phi))*a3;
      
      xprime = x-xo;
      yprime = y-yo;
      
      xlength = xprime - offx;
      ylength = yprime - offy;
      hyp = dist(offx, offy, xprime, yprime);
      cosC = (sq(a1)+sq(hyp)-sq(a2))/(2*a1*hyp);
      ang1 = degrees(acos(cosC));
      sinA = (a1*sin(radians(ang1)))/a2;
      ang4 = degrees(asin(sinA));
      ang2 = (degrees(asin(xlength / hyp))) + ang4;
      ang3 = 90 - ang2;
      xchange = -a2*sin(radians((ang2)));
      ychange = -a2*sin(radians((ang3)));
      x1_2 = xprime + xchange;
      y1_2 = yprime + ychange;
      
      alph = (degrees(atan2((y1_2-offy), (x1_2-offx))));
      if (alph < 0){
        alph = (90 + alph) * -1;
      } 
      else {
        alph = 270 - alph;
      }
      float[] out =  {alph,beta};
      return out;
    }
  
    float[] xy(float alphaAng, float betaAng) {
      //forward kinematic calculation - calculate x,y for input alpha and beta
      //predicts x and y from alpha and beta (check of IK calc)
      float xa,ya,xb,yb;  //positions of the elbows
      xa = offx-a1*cos(radians(alphaAng-90));
      ya = offy+a1*sin(radians(alphaAng-90));
      xb = offx+d+a1*cos(radians(betaAng-90));
      yb = offy+a1*sin(radians(betaAng-90));
      float sep = dist(xa,ya,xb,yb);
      float ange = acos((sep/2)/a2);
      float angh = atan2((yb-ya),(xb-xa));
      float newX = xb-(aeff*cos(ange-angh));
      float newY = yb+(aeff*sin(ange-angh));
      float[] out =  {newX,newY};
      return out;
    }
  
    void drawTo(float x, float y) {
    }
    
    void travTo(float x, float y) {
      //traverse move (faster, no intermediate points)
      //move - new exact target values
      float[] newAng = alphabeta(x,y);
      alphT = newAng[0];
      betaT = newAng[1];
      //find angle deltas from current stepped position to target exact
      float deltaAT = alphT-appAlph;
      float deltaBT = betaT-appBeta;
      //find step deltas
      int deltaStepAT = int(deltaAT/anglePerStep);
      int deltaStepBT = int(deltaBT/anglePerStep);
      //find step time
      float moveTime = max((float(deltaStepAT)/maxStepsPerSecond),(float(deltaStepBT)/maxStepsPerSecond));
      
      if (!((deltaStepAT==0) && (deltaStepBT==0))) {
        //don't write zero length moves to serial
        String outConsole = ("SM," + moveTime + "," + deltaStepAT + "," + deltaStepBT + "\r");
        myPort.write(outConsole);
      }
      
      //re-set current
      alph = alphT;
      beta = betaT;
      appAlph = alph + (deltaStepAT*anglePerStep);
      appBeta = beta + (deltaStepBT*anglePerStep);
    }
    
    void penDown() {
      //pen down
      String outConsole = ("SP,1," + penPause + "\r"); //SP,<value>,<duration> : <value> is 0 (for up) or 1 (for down)
      myPort.write(outConsole);
    }
    
    void penUp() {
      //pen up
      String outConsole = ("SP,0," + penPause + "\r"); //SP,<value>,<duration> : <value> is 0 (for up) or 1 (for down)
      myPort.write(outConsole);
    }
  }
  
}
