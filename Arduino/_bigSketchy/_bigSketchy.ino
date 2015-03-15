#include <AccelStepper.h>

// Define the stepper and the pins it will use
#define M1_DIR 3
#define M1_STP 2
#define M2_DIR 5
#define M2_STP 4
#define MS1 11        // PIN 11 = MS1
#define MS2 12        // PIN 12 = MS2
AccelStepper stepper1(1, M1_STP, M1_DIR);
AccelStepper stepper2(1, M2_STP, M2_DIR);




// Define our three input button pins
//#define  LEFT_PIN  4
//#define  STOP_PIN  3
//#define  RIGHT_PIN 2

// Define our analog pot input pin
//#define  SPEED_PIN 0

// Define our maximum speed in steps per second
#define MAX_SPEED 200
#define ACCEL 2000

int stpCount = 0;
int modeType = 2;
static int stepTo = 25*modeType;  //should be one complete motor revolution (200 @ 8x microstep)
int pos1 = -stepTo;
int pos2 = stepTo;

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

// stepper move command:
// "SM,<move_duration>,<axis1>,<axis2><CR>"
  
void setup() {
  Serial.begin(9600);     // open the serial connection at 9600bps
  // The only AccelStepper value we have to set here is the max speeed, which is higher than we'll ever go 
  stepper1.setMaxSpeed(MAX_SPEED);
  stepper1.setAcceleration(ACCEL);
  stepper2.setMaxSpeed(MAX_SPEED);
  stepper2.setAcceleration(ACCEL);
  pinMode(MS1, OUTPUT);   // set pin 11 to output
  pinMode(MS2, OUTPUT);   // set pin 12 to output

//  pinMode(M1_DIR, OUTPUT);
//  pinMode(M1_STP, OUTPUT);
//  pinMode(M2_DIR, OUTPUT);
//  pinMode(M2_STP, OUTPUT);
  
  
  // Set up the three button inputs, with pullups
//  pinMode(LEFT_PIN, INPUT_PULLUP);
//  pinMode(STOP_PIN, INPUT_PULLUP);
//  pinMode(RIGHT_PIN, INPUT_PULLUP);
  
  stepper1.moveTo(pos1);
  stepper2.moveTo(pos2);
}

void loop() {
  // use & then reset the string when a newline arrives:
  if (stringComplete) {
    // clear the string:
    inputString = "";
    stringComplete = false;
  }
  //define the step mode
  digitalWrite(MS1, MS1_MODE(modeType));  // Set state of MS1 based on the returned value from the MS1_MODE() switch statement.
  digitalWrite(MS2, MS2_MODE(modeType));  // Set state of MS2 based on the returned value from the MS2_MODE() switch statement.
  if (stepper1.distanceToGo()==0) {
    pos1 = -pos1;
    stepper1.moveTo(pos1);
  }
  if (stepper2.distanceToGo()==0) {
    pos2 = -pos2;
    stepper2.moveTo(pos2);
  }
  stepper1.run();
  stepper2.run();
}

void drawTo(int posA, int posB) {
}

void travTo(int posA, int posB) {
}
  

int MS1_MODE(int MS1_StepMode){              // A function that returns a High or Low state number for MS1 pin
  switch(MS1_StepMode){                      // Switch statement for changing the MS1 pin state
  case 1:
    MS1_StepMode = 0;
    break;
  case 2:
    MS1_StepMode = 1;
    break;
  case 4:
    MS1_StepMode = 0;
    break;
  case 8:
    MS1_StepMode = 1;
    break;
  }
  return MS1_StepMode;
}

int MS2_MODE(int MS2_StepMode){              // A function that returns a High or Low state number for MS2 pin
  switch(MS2_StepMode){                      // Switch statement for changing the MS2 pin state
                                             // Different input states allowed are 1,2,4 or 8
  case 1:
    MS2_StepMode = 0;
    break;
  case 2:
    MS2_StepMode = 0;
    break;
  case 4:
    MS2_StepMode = 1;
    break;
  case 8:
    MS2_StepMode = 1;
    break;
  }
  return MS2_StepMode;
}
 
/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
      //now decode the string
      
    } 
  }
}

//  static float current_speed = 0.0;         // Holds current motor speed in steps/second
//  static int analog_read_counter = 1000;    // Counts down to 0 to fire analog read
//  static char sign = 0;                     // Holds -1, 1 or 0 to turn the motor on/off and control direction
//  static int analog_value = 0;              // Holds raw analog value.
//  
//  // If a switch is pushed down (low), set the sign value appropriately
//  if (digitalRead(LEFT_PIN) == 0) {
//    sign = 1;
//  }
//  else if (digitalRead(RIGHT_PIN) == 0) {    
//    sign = -1;
//  }
//  else if (digitalRead(STOP_PIN) == 0) {
//    sign = 0;
//  }
//
//  // We only want to read the pot every so often (because it takes a long time we don't
//  // want to do it every time through the main loop).  
//  if (analog_read_counter > 0) {
//    analog_read_counter--;
//  }
//  else {
//    analog_read_counter = 3000;
//    // Now read the pot (from 0 to 1023)
//    analog_value = analogRead(SPEED_PIN);
//    // Give the stepper a chance to step if it needs to
//    stepper1.runSpeed();
//    //  And scale the pot's value from min to max speeds
//    current_speed = sign * ((analog_value/1023.0) * (MAX_SPEED - MIN_SPEED)) + MIN_SPEED;
//    // Update the stepper to run at this new speed
//    stepper1.setSpeed(current_speed);
//  }
//
//  // This will run the stepper at a constant speed
//  stepper1.runSpeed();
