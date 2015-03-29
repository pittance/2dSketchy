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
    
    float alph;             //exact angle of alpha
    float beta;             //exact angle of beta
    float appAlph;          //approximate (stepped) alpha
    float appBeta;          //approximate (stepped) beta
    
    float anglePerStep;     //degrees per step
    float gearRatio = 40/9;
    float stepsPerRev = 200;
    float microStep = 8;
    anglePerStep = 360/(gearRatio * stepsPerRev * microStep);
    
    int aSteps=0;           //step counter
    int bSteps=0;           //step counter
    
    float xHome,yHome;      //home point coordinates

    Plotter() {
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
      
      //set home position
      xHome = 380;
      yHome = 580;
      float[] temp = alphabeta(xHome,yHome);
      alph = temp[0];
      beta = temp[1];
      //assume start position is a whole step + exact
      appAlph = alph;
      appBeta = beta;
      aSteps = 0;
      bSteps = 0;
      
      /*
        alpha and beta are the angles of the arms:
              0deg                0deg
              |                   |  
              |                   | 
              |                   | 
      90deg---o [alpha]   [beta]  o---90deg
              |                   | 
              |                   |                        
              |                   |  
            180deg              180deg 
      */
      /*
        coordinate system:
              <offx><---d---->
              ^     o        o
            offy
              x--------------------|
              |                    |
              |         A3         |
              |                    |
              |                    |
              |____________________|
      */
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
    
  }
  
  float[] xy(float alphaAng, float betaAng) {
    //forward kinematic calculation - calculate x,y for input alpha and beta
    //predicts x and y from alpha and beta (check of IK calc)
    float xa,ya,xb,yb;  //positions of the elbows
    xa = offx-a1*cos(radians(alph-90));
    ya = offy+a1*sin(radians(alph-90));
    xb = offx+d+a1*cos(radians(beta-90));
    yb = offy+a1*sin(radians(beta-90));
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
