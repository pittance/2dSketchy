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
  
  //page positions and dimensions
  float poffx, poffy, pwide, phigh;
  
  //current positions
  float alph;             //exact current angle of alpha
  float beta;             //exact current angle of beta
  float appAlph;          //approximate (stepped) alpha
  float appBeta;          //approximate (stepped) beta
  //target positions
  float alphT;
  float betaT;
  
  float anglePerStep;     //degrees per step, set in constructor
  float gearRatio = 4.5;  
  float stepsPerRev = 200;
  float microStep = 16;
  
  //used for reversing directions of motors
  int rev1 = -1;  
  int rev2 = 1;   
  
  float xHome,yHome;      //home point coordinates
  float xCurrent,yCurrent;
  
  // pen settings
  int penPause = 350;
  int penUpVal = 21000;  //21000
  int penDownVal = 16000;  //16000
  String outConsole;
  
  //speed settings
  int maxStepsPerSecond = 1500;  //traverse speed, used everywhere
  int stepsPerSecondHi = 400;    //used at the top of the page
  int stepsPerSecondLo = 80;     //used at the bottom of the page
  float maxDrawDist = 2;
  
//    Speed control by rotational speed at shoulder, not at pen.
//    Max stepper speed is the only thing we care about and pen speed
//    is only tangentially related to this so we check for each motor
//    move what is the limiting stepper (normally the one moving farthest)
//    and move that at the fastest speed we define and then the other will
//    move slower. This should mean that the plotter always moves as fast
//    as it can (unless we want to slow it down for some reason)

  boolean verbose = false;
  
  Plotter() {
    //degrees per step (~0.05 for 8x microstep and 40/9 ratio)
    float finalStepsPerRev = (gearRatio * stepsPerRev * microStep);
    anglePerStep = 360/finalStepsPerRev;
    println("machine settings:");
    println("gear ratio:         " + gearRatio);
    println("full steps per rev: " + stepsPerRev);
    println("micro step:         " + microStep);
    println("set at " + finalStepsPerRev + " final steps for a full revolution");
    println("set at " + anglePerStep + " degrees per step");
    
    //initialisation of plotter - (0,0) is top left of board
    offx = 282;        //offset of LHS pulley in x
    offy = 32;         //offset of LHS pulley in y
    a1 = 223;          //arm length - upper
    a2 = 411.5;        //arm length - lower
    a3 = 47;           //arm length - pen extension
    aeff = sqrt(sq(a2)+sq(a3));      //effective lower right hand arm length incl pen extension
    d = 198;           //separation of shoulders
    
    //initialisation of page - (0,0) is top left of board
    poffx = 142;
    poffy = 267;
    pwide = 420;
    phigh = 297;
    
    //TEMPORARY - TO BE REPLACED WITH HARDWARE HOMING
    //set home position
    xHome = 382;
    yHome = 575;
    
    xCurrent = xHome;
    yCurrent = yHome;

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
//      
//     X<    offx   ><---d---->    ^
//     ^                          offy
//   poffy           o        o    v
//            
//     v        x--------------------|
//     < poffx >|                    |
//              |         A3         |
//              |                    |
//              |                    |
//              |____________________|
//      
    
    outConsole = ("SC,4," + penDownVal + "\r");  //17000? SC,4,<servo_min> - sets the minimum value for the servo (1 to 65535)
    myPort.write(outConsole);
    outConsole = ("SC,5," + penUpVal + "\r");  //17000? SC,4,<servo_max> - sets the minimum value for the servo (1 to 65535)
    myPort.write(outConsole);
    outConsole = ("SC,11,500\r");  //SC,10,<servo_rate> - sets the rate of change of the servo (when going up/down)
    myPort.write(outConsole);
    outConsole = ("SC,12,500\r");  //SC,10,<servo_rate> - sets the rate of change of the servo (when going up/down)
    myPort.write(outConsole);
  }
  
  void initialise() {
    float[] temp = alphabeta(xHome,yHome);
    alph = temp[0];
    beta = temp[1];

    println("Home coords: " + xHome+"/"+yHome);
    println("Home angles: " + alph + "/" + beta);
    
    //assume start position is a whole step + exact
    appAlph = alph;
    appBeta = beta;
  }
  
  float[] alphabeta(float x, float y) {
    //inverse kinematic calculation - calculate alpha and beta for input x,y
    float a; //internal alpha
    float b; //internal beta    
    //aeff is calculated once in setup
    
    //includes angled extension for pen at 90 from LH arm (below wrist)
    //finding alpha
    float hypp = dist(offx,offy,x,y);
    float cosang5 = (sq(hypp)+sq(a1)-sq(aeff))/(2*hypp*a1);
    float ang5 = degrees(acos(cosang5));
    float ang6 = degrees(atan2(y-offy,x-offx));
    a = 180-ang5-ang6+90;
    
    //from alpha find the wrist position
    float ang4 = degrees(acos((a2*a2+aeff*aeff-a3*a3)/(2*a2*aeff)));
    float ye = a1*sin(radians(a-90))+offy;
    float xe = offx-a1*cos(radians(a-90));
    float ang3 = degrees(acos((x-xe)/aeff));
    float ang8 = 180 - ang4 - 90;
    float ang11 = ang3 + ang8 - 90;
    //wrist found
    float xw = x + a3*sin(radians(ang11));
    float yw = y - a3*cos(radians(ang11));
    
    xprime = xw;
    yprime = yw;
    x1_2 = xe;
    y1_2 = ye;
    
    // RH Arm, get beta from wrist
    float hypw = dist(offx+d,offy,xw,yw);
    float ang2 = degrees(acos((offx+d-xw)/hypw));
    
    float cosAng1 = (sq(a1)+sq(hypw)-sq(a2))/(2*a1*hypw);
    float ang1 = degrees(acos(cosAng1));
   
    b = 270-ang2-ang1;
    x2_2 = offx+d+a1*cos(radians(b-90));
    y2_2 = offy+a1*sin(radians(b-90));
    
    float[] out =  {a,b};
    return out;
    
  }
  

  float[] xy(float alphaAng, float betaAng) {
    //forward kinematic calculation - calculate x,y for input alpha and beta
    //predicts x and y from alpha and beta (check of IK calc)
    //
    //            O <-d-> O
    //
    //        ea    angh
    //          ange       eb
    //
    //
    //
    //             w
    //           p
    //
    //ange is the angle w-ea-eb
    //angh is the angle eb-ea-(horz)
    //angw is the angle p-ea-w
    
    float xa,ya,xb,yb;  //positions of the elbows
    xa = offx-a1*cos(radians(alphaAng-90));
    ya = offy+a1*sin(radians(alphaAng-90));
    xb = offx+d+a1*cos(radians(betaAng-90));
    yb = offy+a1*sin(radians(betaAng-90));
    float sep = dist(xa,ya,xb,yb);
    float ange = acos((sep/2)/a2);
    float angh = atan2((yb-ya),(xb-xa));
    float angw = atan(a3/a2);
    float angp = angh+ange+angw;
    
    float newX = xa+aeff*cos(angp);
    float newY = ya+aeff*sin(angp);
    
    float[] out =  {newX,newY};
    return out;
  }
  
  
  //draw calculation, used when precise line paths are required
  void drawTo(float x, float y) {
    //this kind of machine will not draw straight lines from point to point naturally
    //here we interpolate intermediate points which are in the straight line to ensure
    //that this line bending doesn't happen when drawing.
    
    //calls traverse move code to move, at lower speed
    
    float drawDist = dist(xCurrent,yCurrent,x,y);
    
    if (drawDist>maxDrawDist) {
      //split line when over threshold distance
      //determine intermediate points
      int segments = int(drawDist/maxDrawDist)+1;
      
      float[] xinter = new float[segments];
      float[] yinter = new float[segments];
      
      for (int i=1;i<segments;i++) {
        xinter[i-1] = map(i,0,segments,xCurrent,x);
        yinter[i-1] = map(i,0,segments,yCurrent,y);
      }
  
      xinter[segments-1] = x;
      yinter[segments-1] = y;
  
      //draw intermediates and final
      for (int i=0;i<segments;i++) {
        travTo(xinter[i],yinter[i],stepsPerSecond(xinter[i],yinter[i]));
      }
      
    } else {
      //draw line in one segment
      travTo(x,y,stepsPerSecond(x,y));
    }
  }
  
  //we need to slow the speed when the pen is low down the page because it gets wobbly
  int stepsPerSecond(float x, float y) {
    return int(map(y,265,575,stepsPerSecondHi,stepsPerSecondLo));
  }
  
  //traverse calculation, used when imprecise lines are required
  //called by draw above, using small line lengths for accuracy
  void travTo(float x, float y, int speed) {
    //traverse move (faster, no intermediate points)
    //move - new exact target values
    float[] newAng = alphabeta(x,y);
    alphT = newAng[0];
    betaT = newAng[1];
    
    if(verbose) {
      println();
      println("move command: " + x + " " + y);
      println("calculated angles - current: " + alph + "/" + beta + " approx: " + appAlph + "/" + appBeta + " target: " + alphT + "/" + betaT);
    }
    
    //find angle deltas from current position to target exact
    float deltaAT = alphT-alph;  //was appAlph and appBeta
    float deltaBT = betaT-beta;
    if(verbose) println("angle deltas: " + deltaAT + "/" + deltaBT);
    
    //find step deltas (change from current position in steps)
    int deltaStepAT = int(deltaAT/anglePerStep);
    int deltaStepBT = int(deltaBT/anglePerStep);
    if(verbose) println("step deltas: " + (rev1*deltaStepAT) + "/" + (rev2*deltaStepBT));
    
    //find step time
    float moveTimeA = abs(float(deltaStepAT)/speed);
    float moveTimeB = abs(float(deltaStepBT)/speed);
    float moveTime = 1000*max(moveTimeA,moveTimeB);  //milliseconds!
    
    int timer = int(moveTime);
    if (!((deltaStepAT==0) && (deltaStepBT==0))) {
      //don't write zero length moves to serial
      String outConsole = ("SM," + timer + "," + (rev1*deltaStepAT) + "," + (rev2*deltaStepBT) + "\r");
      myPort.write(outConsole);
    }
    
    //find actual angle changes from move (using integer steps above)
    float delAlphStep = (deltaStepAT*anglePerStep);
    float delBetaStep = (deltaStepBT*anglePerStep);
    if(verbose) {
      println("alpha angle step from change: " + delAlphStep);
      println("beta angle step from change:  " + delBetaStep);
    }
    
    //calculate the approximate position that we got to instead of the target
    appAlph = alph + delAlphStep;
    appBeta = beta + delBetaStep;
    if(verbose) {
      println("setting approx: " + appAlph + "/" + appBeta);
    
      //re-set current
      println("reset current:  alph/beta:  " +alph+"/"+beta);
      println("               alphT/betaA: " +alphT+"/"+betaT);
    }
    //set current position to the angles the arms are at (approximated by steps)
    alph = appAlph;
    beta = appBeta;
    if(verbose) println("check:          alph/beta:  " +alph+"/"+beta);
    
    //back calculate current x and y from actual angles
    float[] currentXYs = xy(alph,beta);
    xCurrent = currentXYs[0];
    yCurrent = currentXYs[1];
    
  }
  
  void nudgeA(int st) {
    String outConsole = ("SM," + 5 + "," + st + "," + "0" + "\r");
    myPort.write(outConsole);
  }
  
  void nudgeB(int st) {
    String outConsole = ("SM," + 5 + "," + "0" + "," + st + "\r");
    myPort.write(outConsole);
  }
  
  void penDown() {
    //pen down
    String outConsole = ("SP,1," + penPause + "\r"); //SP,<value>,<duration> : <value> is 0 (for up) or 1 (for down)
    myPort.write(outConsole);
    wait(100);
  }
  
  void penUp() {
    //pen up
    String outConsole = ("SP,0," + penPause + "\r"); //SP,<value>,<duration> : <value> is 0 (for up) or 1 (for down)
    myPort.write(outConsole);
    wait(100);
  }
  
  void goHome() {
    penUp();
    travTo(xHome,yHome,maxStepsPerSecond);
  }
  
  void shutDown() {
    String outConsole = ("EM,0,0\r");
    myPort.write(outConsole);
    println("shut down");
  }
  
  void wait(int timeMilli) {
    boolean done = false;
    long lastTime= millis();
    while (!done) {
      if(millis() - lastTime >= timeMilli){
        done = true;
      }
    }
  }
  
}
