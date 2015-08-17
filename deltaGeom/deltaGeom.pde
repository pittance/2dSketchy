float x1, y1, x, y, x2, y2;
float a1, a2, a3, d, s, r;
float aeff;       //effective length of RH arm incl extension
float sigma,phi;  //another angle in the lower RH arm (between aeff and a3)
float offx;       //offset of LHS in x
float offy;       //offset of LHS in y
float alph;
float beta;
float xo,yo;
float xprime,yprime;
float x1_2, y1_2, x2_2, y2_2;
float xchange, ychange;
float ang1, ang2, ang3, ang4;
float xlength, ylength, hyp;
float cosC, sinA;

PFont p;

float outX,outY;
float[] xPoints;
float[] yPoints;

void setup() {
  size(760, 574);
  smooth();
  p = createFont("arial",10);
  textFont(p,10);
  //initialisation
  offx = 280;   //offset of LHS in x
  offy = 30;         //offset of LHS in y
  a1 = 217;          //arm length - upper
  a2 = 395;          //arm length - lower
  a3 = 25;           //arm length - pen extension
  aeff = a2+a3;      //effective lower arm length incl extension
  d = 200;           //separation of shoulders
}

void draw() {
//  println("drawing background");
  background(226);
  fill(50,50);
  noStroke();
  ellipse(offx,offy,2*(a1+a2),2*(a1+a2));
  ellipse(offx+d,offy,2*(a1+a2),2*(a1+a2));
  rect(0,offy,width,height);
  fill(255,50);
  ellipse(offx,offy,2*(a2-a1),2*(a2-a1));
  ellipse(offx+d,offy,2*(a2-a1),2*(a2-a1));

  fill(0);
  noStroke();

  if (dist(offx,offy,mouseX,mouseY) < (a1+a2) && dist((offx+d),offy,mouseX,mouseY) < (a1+a2) && mouseY > offy){
    //condition for the end point within the range of the arms
    x = mouseX;
    y = mouseY;
    revcalcExt(x, y);
    fill(0);
    text("alph: " + alph,offx,offy);
    text("beta: " + beta,offx+d,offy);
    text("input: " + x + " " + y,offx+d/2,offy/2);
    text(checkCalc(alph,beta),offx+d/2,offy/2+10);
    noFill();
    stroke(0);
    drawArmsExt();

  } 
}

//fwd kinematic used
String checkCalc(float al, float be) {
  //predicts x and y from alpha and beta (check of IK calc)
  float xa,ya,xb,yb;  //positions of the elbows
  xa = offx-a1*cos(radians(alph-90));
  ya = offy+a1*sin(radians(alph-90));
  xb = offx+d+a1*cos(radians(beta-90));
  yb = offy+a1*sin(radians(beta-90));
//  println(xa+" "+ya+" "+xb+" "+yb);
  float sep = dist(xa,ya,xb,yb);
//  println(sep);
  float ange = acos((sep/2)/a2);
//  println(degrees(ange));
  float angh = atan2((yb-ya),(xb-xa));
//  println(degrees(angh));
  float newX = xb-(aeff*cos(ange-angh));
  float newY = yb+(aeff*sin(ange-angh));
  return "output: " + newX + " " + newY;
}



//rev kinematic used
void revcalcExt(float x, float y) {
  //includes angled extension for pen at 90 from LH arm (below wrist)
  float hypp = sqrt(((x-offx)*(x-offx))+((y-offy)*(y-offy)));
  float ang5 = degrees(acos((hypp*hypp+a1*a1-aeff*aeff)/(2*hypp*a1)));
  float ang6 = degrees(atan2(y-offy,x-offx));
  alph = 180-ang5-ang6+90;
  float ang4 = degrees(acos((a2*a2+aeff*aeff-a3*a3)/(2*a2*aeff)));
  float ye = a1*sin(radians(alph-90))+offy;
  float xe = offx-a1*cos(radians(alph-90));
  float ang3 = degrees(acos((x-xe)/aeff));
  float ang8 = 180 - ang4 - 90;
  float ang11 = ang3 + ang8 - 90;
  float xw = x + a3*sin(radians(ang11));
  float yw = y - a3*cos(radians(ang11));
  xprime = xw;
  yprime = yw;
  x1_2 = xe;
  y1_2 = ye;
  
  // RH Arm
  float hypw = dist(offx+d,offy,xw,yw);
  float ang2 = degrees(acos((offx+d-xw)/hypw));
  
  float cosAng1 = (sq(a1)+sq(hypw)-sq(a2))/(2*a1*hypw);
  float ang1 = degrees(acos(cosAng1));
 
  beta = 270-ang2-ang1;
  x2_2 = offx+d+a1*cos(radians(beta-90));
  y2_2 = offy+a1*sin(radians(beta-90));
  
  
}

void drawArmsExt(){
  //LH arm
  //upper
  stroke(165,53,53);
  line(offx,offy,x1_2,y1_2);
  text("x1_2,y1_2",x1_2,y1_2);
  //lower
  stroke(53,165,53);
  line(x1_2,y1_2,xprime,yprime);
  text("xprime,yprime",xprime,yprime);
  
  //RH arm
  //upper
  stroke(165,53,53);
  line(d+offx,offy,x2_2,y2_2);
  //lower
  stroke(53,165,53);
  line(x2_2,y2_2,xprime,yprime);
  text("x2_2,y2_2",x2_2,y2_2);
  //ext
  stroke(0);
  line(xprime,yprime,x,y);
}

////earlier versions
//void drawArms(){
//  line(offx,offy,x1_2,y1_2);
//  line(x1_2,y1_2,x,y);
//  line(d+offx,offy,x2_2,y2_2);
//  line(x2_2,y2_2,x,y);
//}
//void revcalc(float x, float y) {
//  xlength = x - offx;
//  ylength = y - offy;
//  hyp = dist(offx, offy, x, y);
//  cosC = (sq(a1)+sq(hyp)-sq(a2))/(2*a1*hyp);
//  ang1 = degrees(acos(cosC));
//  sinA = (a1*sin(radians(ang1)))/a2;
//  ang4 = degrees(asin(sinA));
//  ang2 = (degrees(asin(xlength / hyp))) + ang4;
//  ang3 = 90 - ang2;
//  xchange = -a2*sin(radians((ang2)));
//  ychange = -a2*sin(radians((ang3)));
//  x1_2 = x + xchange;
//  y1_2 = y + ychange;
//  
//  alph = (degrees(atan2((y1_2-offy), (x1_2-offx))));
//  if (alph < 0){
//    alph = (90 + alph) * -1;
//  } 
//  else {
//    alph = 270 - alph;
//  }
//
//  xlength = x - (offx + d);
//  ylength = y - offy;
//  hyp = dist((offx + d), offy, x, y);
//  cosC = (sq(a1)+sq(hyp)-sq(a2))/(2*a1*hyp);
//  ang1 = degrees(acos(cosC));
//  sinA = (a1*sin(radians(ang1)))/a2;
//  ang4 = degrees(asin(sinA));
//  ang2 = (degrees(asin(xlength / hyp))) - ang4;
//  ang3 = 90 - ang2;
//  xchange = a2*sin(radians((ang2)));
//  ychange = -a2*sin(radians((ang3)));
//  x2_2 = x - xchange;
//  y2_2 = y + ychange;
//  
//  beta = 90 + (degrees(atan2((y2_2-offy), (x2_2-(d+offx)))));
//}
//
//void xy(float alphaAng, float betaAng) {
//  //forward kinematic calculation - calculate x,y for input alpha and beta
//  //predicts x and y from alpha and beta (check of IK calc)
//  float xa,ya,xb,yb;  //positions of the elbows
//  xa = offx-a1*cos(radians(alphaAng-90));
//  ya = offy+a1*sin(radians(alphaAng-90));
//  xb = offx+d+a1*cos(radians(betaAng-90));
//  yb = offy+a1*sin(radians(betaAng-90));
//  float sep = dist(xa,ya,xb,yb);
//  float ange = acos((sep/2)/a2);
//  float angh = atan2((yb-ya),(xb-xa));
//  float newX = xb-(aeff*cos(ange-angh));
//  float newY = yb+(aeff*sin(ange-angh));
//  outX = newX;
//  outY = newY;
////  println(alphaAng + " " + betaAng + " " + outX + " " + outY);
//}



