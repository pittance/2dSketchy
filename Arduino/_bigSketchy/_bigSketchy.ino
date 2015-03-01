#include <AccelStepper.h>

// Define the stepper and the pins it will use
#define M1_DIR 3
#define M1_STP 2
#define M2_DIR 5
#define M2_STP 4
AccelStepper stepper1(1, M1_STP, M1_DIR);
AccelStepper stepper2(1, M2_STP, M2_DIR);

// Define our three input button pins
//#define  LEFT_PIN  4
//#define  STOP_PIN  3
//#define  RIGHT_PIN 2

// Define our analog pot input pin
//#define  SPEED_PIN 0

// Define our maximum speed in steps per second
#define MAX_SPEED 3000
#define ACCEL 10000

int stpCount = 0;
static int stepTo = 200*8;  //should be one complete motor revolution (200 @ 8x microstep)
int pos1 = -stepTo;
int pos2 = stepTo;
  
void setup() {
  // The only AccelStepper value we have to set here is the max speeed, which is higher than we'll ever go 
  stepper1.setMaxSpeed(MAX_SPEED);
  stepper1.setAcceleration(ACCEL);
  stepper2.setMaxSpeed(MAX_SPEED);
  stepper2.setAcceleration(ACCEL);
  
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
