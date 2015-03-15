float x1, y1, x, y, x2, y2;
float a1, a2, a3, d, s, r;
float aeff;   //effective length of RH arm incl extension
float sigma,phi;  //another angle in the lower RH arm (between aeff and a3)
float offx = 250;  //offset of LHS in x
float offy = 50;   //offset of LHS in y
float alph = 120;
float beta = 120;
float delta;  //angle for extension relative to lower arm on RHS
float xo,yo;
float xprime,yprime;
float x1_2, y1_2, x2_2, y2_2;
float xchange, ychange;
float ang1, ang2, ang3, ang4;
float xlength, ylength, hyp;
float cosC, sinA;

void setup() {
  size(640, 480);
  smooth();
  a1 = 150;  //arm length - upper
  a2 = 200;  //arm length - lower
  a3 = 20;   //arm length - pen extension
  aeff = a2+a3;
  
  d = 100;   //separation of shoulders
}

void draw() {
  background(226);
  fill(50,50);
  noStroke();
  ellipse(offx,offy,2*(a1+a2),2*(a1+a2));
  ellipse(offx+d,offy,2*(a1+a2),2*(a1+a2));
  rect(0,offy,width,height);
  fill(255,50);
  ellipse(offx,offy,2*(a2-a1),2*(a2-a1));
  ellipse(offx+d,offy,2*(a2-a1),2*(a2-a1));
  
  if (dist(offx,offy,mouseX,mouseY) < (a1+a2) && dist((offx+d),offy,mouseX,mouseY) < (a1+a2) && mouseY > offy){
    //condition for the end point within the range of the arms
    x = mouseX;
    y = mouseY;
    revcalcExt(x, y);
    noFill();
    stroke(0);
    drawArmsExt();
  } 
}



void revcalcExt(float x, float y) {
  //includes angled extension for pen
  
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

  
}

void drawArms(){
  line(offx,offy,x1_2,y1_2);
  line(x1_2,y1_2,x,y);
  line(d+offx,offy,x2_2,y2_2);
  line(x2_2,y2_2,x,y);
}

void drawArmsExt(){
  //LH arm
  //upper
  stroke(165,53,53);
  line(offx,offy,x1_2,y1_2);
  //lower
  stroke(53,165,53);
  line(x1_2,y1_2,xprime,yprime);
  
  //RH arm
  //upper
  stroke(165,53,53);
  line(d+offx,offy,x2_2,y2_2);
  //lower
  stroke(53,165,53);
  line(x2_2,y2_2,xprime,yprime);
  //ext
  stroke(0);
  line(xprime,yprime,x,y);
}

void revcalc(float x, float y) {
  xlength = x - offx;
  ylength = y - offy;
  hyp = dist(offx, offy, x, y);
  cosC = (sq(a1)+sq(hyp)-sq(a2))/(2*a1*hyp);
  ang1 = degrees(acos(cosC));
  sinA = (a1*sin(radians(ang1)))/a2;
  ang4 = degrees(asin(sinA));
  ang2 = (degrees(asin(xlength / hyp))) + ang4;
  ang3 = 90 - ang2;
  xchange = -a2*sin(radians((ang2)));
  ychange = -a2*sin(radians((ang3)));
  x1_2 = x + xchange;
  y1_2 = y + ychange;
  
  alph = (degrees(atan2((y1_2-offy), (x1_2-offx))));
  if (alph < 0){
    alph = (90 + alph) * -1;
  } 
  else {
    alph = 270 - alph;
  }

  xlength = x - (offx + d);
  ylength = y - offy;
  hyp = dist((offx + d), offy, x, y);
  cosC = (sq(a1)+sq(hyp)-sq(a2))/(2*a1*hyp);
  ang1 = degrees(acos(cosC));
  sinA = (a1*sin(radians(ang1)))/a2;
  ang4 = degrees(asin(sinA));
  ang2 = (degrees(asin(xlength / hyp))) - ang4;
  ang3 = 90 - ang2;
  xchange = a2*sin(radians((ang2)));
  ychange = -a2*sin(radians((ang3)));
  x2_2 = x - xchange;
  y2_2 = y + ychange;
  
  beta = 90 + (degrees(atan2((y2_2-offy), (x2_2-(d+offx)))));
}



