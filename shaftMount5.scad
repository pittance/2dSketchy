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

//servo spline is 4.66mm diam, 3mm high
//2.2mm screw diam (to threads), 2.5mm hole & 3.42mm long (threads)


//WRISTWRISTWRIST

////ASSEMBLY
////servo wrist assembly & pen holder for assembly check
//wrist2(0);   
//translate([0,0,16.5])rotate([180,0,-140])wrist1(0);
//translate([0,16+21,0])penHolder();
//translate([-15/2,13,0])penLiftLower();
//translate([-15/2,12.5,12.5])penLiftUpper();

//PRINT
//wrist2(0);   
translate([0,-40,0])wrist1(0);
//translate([50,30,0])penHolder();
//translate([-20,20,0])penLiftLower();
//rotate([0,90,0])translate([-13.6,-20,-30])penLiftUpper();


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
            %translate([25,21,16])rotate([90,0,-90])9g_servo(0,servoRot);
            //servo mount - near pen
            translate([21,8,0]) {
                cube([6,25,9]);
                translate([0,25,0])cube([6,6,22]);
            }
            //servo mount - near bearing
            translate([21,-3,0])cube([6,12,22]);
            //pen mount
            translate([8,8,0])cube([17,12,7]);
        }
        //penHolder mount    
        translate([-27+17,16,(3+2+2)/2])rotate([0,90,0])cylinder(h=45,d=2.5,$fn=detail); //35mm m3 bolt
        //servo holes
        translate([19,35,16])rotate([0,90,0])cylinder(h=10,d=2.2,$fn=8);
        translate([19,7,16])rotate([0,90,0])cylinder(h=16,d=2.5,$fn=8);
        
    }
}
module penHolder() {
    difference() {
        union() {
            //base
            translate([-7.5,-3,0])cube([15,10,20]);
            //main pen holder body
            translate([0,12,0])cylinder(h=20,d=18,$fn=25);
        }
        //pen hole
        translate([0,12,0])cylinder(h=20,d=13,$fn=25);
        //pen holder bolts
        translate([0,12,0]) {
            translate([0,10,4])rotate([90,0,0])cylinder(h=10,d=2.5,$fn=10);
            translate([0,10,20-4])rotate([90,0,0])cylinder(h=10,d=2.5,$fn=10);
        }
        //pivot bolts
        translate([-10,0,3.5+13])rotate([90,0,90])cylinder(h=25,d=2.5,$fn=10);
        translate([-10,0,3.5])rotate([90,0,90])cylinder(h=25,d=2.5,$fn=10);
        //cutout for upper arm
        translate([1,-5,11])cube([9,9,9.1]);
    }
}
module penLiftLower() {
    difference() {
        //arm body
        union() {
            cube([15,18,3]);
            cube([15,7,7]);
            translate([15/2-(15+1+5+5)/2,11,0]) {
                cube([15+1+5+5,7,7]);
                cube([5,16,7]);
                translate([21,0,0])cube([5,16,7]);
            }
        }
        //bolt holes
        translate([-1,3,3.5])rotate([0,90,0])cylinder(h=30,d=3.1,$fn=20);
        translate([-10,21+3,3.5])rotate([0,90,0])cylinder(h=40,d=3.1,$fn=20);
    }
        
}
module penLiftUpper() {
    //to be glued to the servo horn
    difference() {
        //arm body
        union() {
            //servo mount block
            hull() {
                translate([9,3,3.5])rotate([0,90,0])cylinder(h=4.6,d=7,$fn=20);
                translate([9,3+17,3.5])rotate([0,90,0])cylinder(h=4.6,d=7,$fn=20);
            }
        }
        //bolt holes
        //servo position
        translate([-1,3,3.5]) {
            rotate([0,90,0]) {
                //location hole
                translate([0,0,9])cylinder(h=6,d=3.1,$fn=20);
            }
        }
        //pen end
        
        translate([-10,17+3,3.5])rotate([0,90,0])cylinder(h=40,d=3.1,$fn=20);
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
module 9g_servo(horn,hornRot){
	difference(){			
		union(){
			color("steelblue") cube([23,12.5,22], center=true);
			color("steelblue") translate([0,0,5]) cube([32,12,2], center=true);
			color("steelblue") translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=20, center=true);
			color("steelblue") translate([-.5,0,2.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("steelblue") translate([-1,0,2.75]) cube([5,5.6,24.5], center=true);
          if (horn==1) {  
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
            } else {
                color("white") translate([5.5,0,3.65]) {
                    difference() {
                        cylinder(d=4.7, h=29.25, $fn=20, center=true);
                        translate([0,0,1])cylinder(d=1, h=29.25, $fn=20, center=true);
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
