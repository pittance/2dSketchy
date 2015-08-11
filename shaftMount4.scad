detail = 20;	//20=low, 85=high

shaftDiam = 6+0.25;     //add a bit (6mm actual)

shaftClampedLength = 35;        //after much fiddling this isn't the clamped length any more


//elbowBearing4 inputs:
shaftClampWidth = 20-3;      //20mm M3 bolt and 3 for bolting
shaftZ = 2;                  //z position for the bottom of the shaft
//shaftDiam
//shaftClampedLength
bearingDiam = 10+0.5;       //add a bit (10mm actual)
bearingThick = 4;
washerThick = 0.4;
bearingPad = 6;
shaftEndPad = 2;

elbowHeight = 12;

tiny=0.001;

servoRot = 0;


//elbow();


//WRISTWRISTWRIST
//ASSEMBLY
//servo wrist assembly & pen holder for assembly check
wrist2(0);                                          //servo wrist
translate([0,-30,0])wrist1(180);                    //second wrist
penHolder();                                         //assembly check

////PRINT
////servo wrist assembly & pen holder for print
//wrist2(0);                                          //servo wrist
////translate([0,-30,0])wrist1(180);                    //second wrist
//translate([-20,5,0])penHolder();


module wrist1(clampAngle) {
    //this is called by the servo wrist unit, forms the basis of the wrist joint
    //clampAngle = 180 for pen wrist, 0 for non=pen
    padWide = 6;
    padThick = 4;
    clampThick = 6;
    difference() {
        //bearing base
        union() {
            //base strip
            translate([0,-(bearingDiam+padWide)/2,0]) {
                cube([55,bearingDiam+padWide,bearingThick+padThick]);
                //shaft clamp housing
                translate([55-30,0,0])cube([30,bearingDiam+padWide,(clampThick+bearingThick/2)*2]);
            }
            //bearing housing
            cylinder(h=bearingThick+padThick,d=bearingDiam+padWide,$fn=detail);
            //bearing clamp
            rotate([0,0,clampAngle])translate([-bearingDiam/2,0,0])cube([bearingDiam,bearingDiam/2+padWide/2+6+2,bearingThick+padThick]);
        }
        //bearing
        translate([0,0,padThick])cylinder(h=bearingThick,d=bearingDiam,$fn=detail);
        //bolt hole
        cylinder(h=padThick,d=6.5,$fn=detail);
        //shaft
        translate([55-28,0,(clampThick+bearingThick/2)])rotate([0,90,0])cylinder(h=28,d=shaftDiam,$fn=detail);
        //shaft clamp fixings
        translate([55-7,5.2,(clampThick+bearingThick/2)])rotate([0,0,90])nutSlot(15,15,0.5);
        translate([55-30+7,5.2,(clampThick+bearingThick/2)])rotate([0,0,90])nutSlot(15,15,0.5);
        //bearing clamp bolt
        translate([-bearingDiam/2,-(bearingDiam/2+padWide/2+3+1),(padThick+bearingThick)/2])rotate([0,90,0])boltHole(3,5.5,12,3);
        //bearing clamp nut
        
        //bearing clamp slot
        rotate([0,0,clampAngle])translate([-bearingDiam/4+bearingDiam/8,0,0])cube([bearingDiam/4,bearingDiam/2+padWide/2+6+2,bearingThick+padThick]);
    }
    
}

module wrist2() {
    //this is the one with the servo, adds extra bits to the base wrist
    padWide = 6;
    difference() {
        union() {
            //base wrist joint
            wrist1(180);
            //servo
            %translate([25,25,2])rotate([0,0,180])9g_servo(servoRot);
            //servo mount - near bearing
            translate([8,8,0])cube([5,22,6]);
            //servo mount - the other one
            translate([37,8,0])cube([5,22,6]);
            //pen mount
            translate([8,8,0])cube([17,10,7]);
        }
        //penHolder mount    
        translate([-27+17,14,(3+2+2)/2])rotate([0,90,0])cylinder(h=35,d=2.5,$fn=detail); //35mm m3 bolt
        //servo holes
        translate([11,25,8])rotate([0,180,0])cylinder(h=10,d=2.2,$fn=4);
        translate([39,25,8])rotate([0,180,0])cylinder(h=10,d=2.2,$fn=4);
        
    }
}
module penHolder() {
    difference() {
        union() {
            translate([0,18,0]) {
                //base
                translate([-15/2,-7,0]) {
                    //base
                    cube([15,25,4]);
                    //pivot bearing
                    translate([0,3,(3+2+2)/2])rotate([0,90,0])cylinder(h=15,d=7,$fn=20);   
                }
                //main for pen holder
                translate([0,20,0])cylinder(h=15,d=18,$fn=25);
                //'jiggle' adjustment boss (for grubscrew etc.)
                translate([0,-4,0])cylinder(h=12,d=6,$fn=20);
            }
            translate([2.5,25.2,2])rotate([100,0,0]){
                //base of lift arm
                cube([5,10,5]);
                //top of lift arm
                translate([0,10,0])rotate([0,0,-35])cube([5,22,5]);
            }
        }
        //pen hole
        translate([0,18+20,0])cylinder(h=15,d=13,$fn=25);
        //pen holder bolts
        translate([0,38,0]) {
            rotate([90,0,0])translate([0,7.5,-10])cylinder(h=10,d=2.5,$fn=10);
        }
        //pivot bolt
        translate([-10,14,(3+2+2)/2])rotate([90,0,90])cylinder(h=25,d=3.5,$fn=10);
        //pivot bolt 'jiggle' adjustment (optional?)
        translate([0,14,0])cylinder(h=15,d=2.5,$fn=10);
    }
    
}


module elbow() {
    difference() {
        union() {
            //bearing barrel
            cylinder(h=elbowHeight,d=bearingDiam+bearingPad,$fn=detail);
            //main elbow body
            translate([0,-(bearingDiam+bearingPad)/2,0])cube([bearingDiam/2+shaftEndPad+shaftClampedLength,bearingDiam+bearingPad,elbowHeight]);
            //bearing clamp body
            translate([-bearingDiam*1.25,-bearingDiam/2,0])cube([bearingDiam,bearingDiam,elbowHeight]);
        }
        //remove bearing stack
        translate([0,0,elbowHeight-(2*bearingThick+washerThick)])cylinder(h=2*bearingThick+washerThick,d=bearingDiam,$fn=detail);
        //remove shaft
        translate([bearingDiam/2+shaftEndPad,0,elbowHeight/2])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        //remove shaft clamp slots
        translate([(bearingDiam/2+shaftEndPad+shaftClampedLength)-7,shaftDiam/2+2,elbowHeight/2])rotate([0,0,90])nutSlot(15,15,0.5);
        translate([(bearingDiam/2+shaftEndPad)+7,shaftDiam/2+2,elbowHeight/2])rotate([0,0,90])nutSlot(15,15,0.5);
        //remove bearing clamp slot
        translate([-bearingDiam*1.25,-1.5,0])cube([bearingDiam,3,elbowHeight]);
        //remove clamp bolt holes
        #translate([-bearingDiam*1.25+3.5,bearingDiam/2,elbowHeight/2+1])rotate([90,0,0])boltHole(3,5.5,16,3.1);
        //remove axle bolt hole
        cylinder(h=elbowHeight,d=6.5,$fn=detail);
    }
}

module nutSlot(slotLength,holeLength,holeFrac) {
    //slot and hole for grubscrew and nut for retention of shaft/bearing
    //slot
    m3NutDiam = 6.24+0.6;    //equivalent diameter (6 faces)
    m3NutFlats = 5.5+0.6;   //distance across flats
    m3NutThick = 2.4+0.6;
    
    rotate([0,-90,0])translate([0,0,-m3NutThick/2]) {
        cylinder(h=m3NutThick,d=m3NutDiam,$fn=6);
        translate([0,-m3NutFlats/2,0])cube([slotLength,m3NutFlats,m3NutThick]);
        //hole
        translate([0,0,-holeFrac*holeLength])cylinder(h=holeLength,d=3.5,$fn=12);
    }
}

module boltHole(headLength, headDiam, shaftLength, shaftDiam) {
 	//(M3)
	//head length std = 3mm
	//head diameter std = 5.5mm
	//shaft diameter std = 3mm
	//length defined
    //e.g.: boltHole(3,5.5,8,3)
	union() {
		cylinder(h=shaftLength,d=shaftDiam,$fn=detail);
		translate([0,0,-headLength]) cylinder(h=headLength,d=headDiam,$fn=detail); //h=2.9
	}
}

module boltHoleNut(headLength, headDiam, shaftLength, shaftDiam) {
 	//(M3)
	//head length std = 3mm
	//head diameter std = 5.5mm
	//shaft diameter std = 3mm
	//length defined
	union() {
		cylinder(h=shaftLength,d=shaftDiam,$fn=detail);
		translate([0,0,-headLength]) cylinder(h=headLength,d=headDiam,$fn=detail); //h=2.9
		translate([0,0,shaftLength-2.4])cylinder(h=2.4,d=6.8,$fn=6);
	}
}


// from http://www.thingiverse.com/TheCase/designs/
// 9G Servo in OpenSCAD by TheCase is licensed under the Creative Commons - Attribution license.
module 9g_servo(hornRot){
	difference(){			
		union(){
			color("steelblue") cube([23,12.5,22], center=true);
			color("steelblue") translate([0,0,5]) cube([32,12,2], center=true);
			color("steelblue") translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=20, center=true);
			color("steelblue") translate([-.5,0,2.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("steelblue") translate([-1,0,2.75]) cube([5,5.6,24.5], center=true);		
			color("white") translate([5.5,0,3.65]) {
                cylinder(r=2.35, h=29.25, $fn=20, center=true);
                rotate([0,0,hornRot]){
                    hull(){
                        translate([0,0,13.7925]) {
                            cylinder(d=7.3,h=1.66,$fn=15,center=true);
                            translate([(16-4.8/2),0,0])cylinder(d=4.8,h=1.66,$fn=15,center=true);
                        }
                    }
                }
            }
			
		}
		translate([10,0,-11]) rotate([0,-30,0]) cube([8,13,4], center=true);
		for ( hole = [14,-14] ){
			translate([hole,0,5]) cylinder(r=2.2, h=4, $fn=20, center=true);
		}	
	}
}
