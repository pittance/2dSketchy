detail = 85;	//20=low, 85=high
height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;
shaftDiam = 6+0.25;     //add a bit (6mm actual)
shaftPos = height/3;
shaftClampedLength = 35;        //after much fiddling this isn't the clamped length any more
shaftPad = 1;
penArmLength = 30;
penClampHeight = 15;
penClampThick = 4;
penDiam = 11;

layer = 0.2;

m5bolt = 5;
m5boltHead = 8;
m3bolt = 3;
bearingDiam = 10+0.5;       //add a bit (10mm actual)
bearingThick = 4;
bearingPad = 2;                 //padding around the outside of the bearing outer
bearingMarg = 0.4;              //thickness under the ends of the bearing & for clearances
bearingInterfaceDiam = 7;       //the nub that sticks up from the non-bearing side
shaftZ = (bearingThick + bearingMarg + bearingMarg/2); //was shaftPad+shaftDiam/2

boltMaxLen20 = 17.82; //max length for bolting on 20mm bolt

tiny=0.001;

//print 5 copies of the elbow joints (4x elbows + one wrist)
//print 1 of the wrist joints (one elbow is used as a wrist)

translate([0,10,0]) {
translate([-15,-60,0])elbowBearing3();
translate([-15,-40,0])elbowBearing3();
translate([-15,-20,0])elbowBearing3();
translate([-15,0,0])elbowBearing3();

//wrist assembly
//wrist1();
//translate([-15,20,0])elbowBearing2();
}
//translate([-30,8,11])rotate([90,180,0])9g_servo();

//checking assembly of wrist
//translate([0,0,9.5])rotate([0,180,222])elbowBearing2();
//translate([0,0,9.5])rotate([0,180,318])elbowBearing2();

//print 2 copies of the shoulder shaft mounts
//rotate([0,0,90])translate([-15,-55,0])shaftMount();
//rotate([0,0,90])translate([-15,45,0])shaftMount();

//elbowBearing3();

//build surface for check
//color([0.5,0,0.5])translate([0,0,-2])cylinder(h=1,d=175);

module wrist1() {
    difference() {
        union() {
            //bearing housing
            cylinder(h=bearingThick+bearingMarg,d=bearingDiam+2*bearingPad,$fn=detail);
            //shaft housing
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
            //clamp body
            rotate([0,0,90])translate([-bearingDiam,-(shaftDiam+shaftPad*2)/2,0])cube([bearingDiam,shaftDiam+shaftPad*2,bearingThick+bearingMarg]);
            //pen mount arm
            translate([0,(shaftDiam+shaftPad*2)/2,0])rotate([0,0,180])cube([penArmLength,shaftDiam+shaftPad*2,bearingThick+bearingMarg]);
            //pen clamp
            translate([-penArmLength,-(shaftDiam+shaftPad*2)/2,0])cube([penClampThick,shaftDiam+shaftPad*2,penClampHeight]);
            //pen clamp fixing
            translate([-(0.65*penArmLength),0,0])cylinder(h=penClampHeight,d1=5,d2=6,$fn=detail);
        }
        //remove bearing
        translate([0,0,bearingMarg])cylinder(h=m3bolt+shaftDiam+shaftPad*4,d=bearingDiam,$fn=detail);
        //bolt hole
        cylinder(h=bearingThick,d=bearingInterfaceDiam,$fn=detail);
        //shaft
        translate([bearingDiam,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        
        //remove extra bits for pivot angle
        rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad]);
        mirror([0,1,0])rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        //remove bearing mount + clearance
        translate([0,0,bearingThick+bearingMarg])cylinder(h=10,d=bearingDiam+2*2*bearingPad,$fn=detail);
        
        //keyway for clamping (shaft)
        translate([bearingDiam,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftDiam*2]);
        rotate([0,0,90]) {
            //keyway for bearing clamp
            translate([-bearingDiam-tiny,-shaftDiam/8,0])cube([bearingDiam,shaftDiam/4,bearingThick+bearingMarg]);
            //clamp bolt
            translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
            translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
        }
        
        //clamp bolt (shaft)
        translate([shaftClampedLength,bearingDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=bearingDiam,d=m3bolt,$fn=detail);
        translate([-bearingDiam*1.5,-bearingDiam,bearingThick+bearingMarg])cube([bearingDiam*2,bearingDiam*2,bearingDiam*2]);
        //pen clamp surface
        translate([-penArmLength-penDiam/2+2,0,0])rotate([])cylinder(h=penClampHeight,d=penDiam,$fn=detail);
    }
    
    
}


module elbowBearing3() {
    difference() {
        union() {
            cylinder(h=shaftPad+m3bolt+shaftDiam+shaftPad*2,d=bearingDiam+2*bearingPad,$fn=detail);
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
            rotate([0,0,90])translate([-bearingDiam,-(shaftDiam+shaftPad*2)/2,0])cube([bearingDiam,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        }
        //remove bearing
        translate([0,0,(shaftPad+m3bolt+shaftDiam+shaftPad*2)-(bearingThick*2+0.6)])cylinder(h=bearingThick*2+0.6,d=bearingDiam,$fn=detail);
        //bolt hole
        cylinder(h=bearingThick,d=bearingInterfaceDiam,$fn=detail);
        //shaft
        translate([bearingDiam,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        
        //remove extra bits for pivot angle
//        rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick*2+0.5])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad]);
//        mirror([0,1,0])rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick*2+0.5])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        //remove bearing mount + clearance
//        translate([0,0,bearingMarg+bearingThick*2+0.5])cylinder(h=10,d=bearingDiam+2*2*bearingPad,$fn=detail);
        
        //keyway for clamping (shaft)
        translate([bearingDiam,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        rotate([0,0,90]) {
            //keyway for bearing clamp
            translate([-bearingDiam-tiny,-shaftDiam/8,0])cube([bearingDiam,shaftDiam/4,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
            //clamp bolt
            #translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(shaftPad+m3bolt+shaftDiam+shaftPad*2)-(5.5/2+0.1)])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
            #translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(shaftPad+m3bolt+shaftDiam+shaftPad*2)-(5.5/2+0.1)])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
        }
        
        //clamp bolt (shaft)
        translate([shaftClampedLength,bearingDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=bearingDiam,d=m3bolt,$fn=detail);
        //final clip to top of bearings
//        translate([-bearingDiam*1.5,-bearingDiam,bearingMarg+bearingThick*2+0.5])cube([bearingDiam*2,bearingDiam*2,bearingDiam*2]);
    }
}

module elbowBearing2() {
    difference() {
        union() {
            cylinder(h=bearingThick+bearingMarg,d=bearingDiam+2*bearingPad,$fn=detail);
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
            rotate([0,0,90])translate([-bearingDiam,-(shaftDiam+shaftPad*2)/2,0])cube([bearingDiam,shaftDiam+shaftPad*2,bearingThick+bearingMarg]);
        }
        //remove bearing
        translate([0,0,bearingMarg])cylinder(h=m3bolt+shaftDiam+shaftPad*4,d=bearingDiam,$fn=detail);
        //bolt hole
        cylinder(h=bearingThick,d=bearingInterfaceDiam,$fn=detail);
        //shaft
        translate([bearingDiam,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        
        //remove extra bits for pivot angle
        rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad]);
        mirror([0,1,0])rotate([0,0,40])translate([0,-(shaftDiam+shaftPad*2)/2,bearingMarg+bearingThick])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        //remove bearing mount + clearance
        translate([0,0,bearingThick+bearingMarg])cylinder(h=10,d=bearingDiam+2*2*bearingPad,$fn=detail);
        
        //keyway for clamping (shaft)
        translate([bearingDiam,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftDiam*2]);
        rotate([0,0,90]) {
            //keyway for bearing clamp
            translate([-bearingDiam-tiny,-shaftDiam/8,0])cube([bearingDiam,shaftDiam/4,bearingThick+bearingMarg]);
            //clamp bolt
            translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
            translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
        }
        
        //clamp bolt (shaft)
        translate([shaftClampedLength,bearingDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=bearingDiam,d=m3bolt,$fn=detail);
        translate([-bearingDiam*1.5,-bearingDiam,bearingThick+bearingMarg])cube([bearingDiam*2,bearingDiam*2,bearingDiam*2]);
    }
}

module shaftMount() {
	difference() {
		union() {
			cylinder(h=height,d=holeDiam*2,$fn=detail);
			translate([0,-holeDiam,0])cube([barLength,holeDiam*2,height]);
                    //clamp for shaft
                    rotate([0,0,0])translate([-holeDiam*1.5,-holeDiam/2,0])cube([holeDiam,shaftDiam+shaftPad*2,height]);
		}
		cylinder(h=height,d=holeDiam,$fn=detail);
		translate([holeDiam,0,shaftPos])rotate([0,90,0]) {
			cylinder(h=barLength,d=shaftDiam,$fn=detail);
			translate([-height,-shaftDiam/4,0])cube([height,shaftDiam/2,barLength]);
		}
		translate([barLength-holeDiam,holeDiam-4.5,1.5+shaftPos+shaftDiam/2])rotate([90,0,0])boltHoleNut(7,5.7,12,3.5);
                //keyway for shaft clamp
                translate([-holeDiam*2,-1.4*shaftDiam/8,0])cube([bearingDiam*1.5,1.4*shaftDiam/4,height]);
                //clamp bolts
            translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2+1])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
            translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2+1])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
            translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2+height-6])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
            translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2+height-6])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
	}
	
}




module boltHole(headLength, headDiam, shaftLength, shaftDiam) {
 	//(M3)
	//head length std = 3mm
	//head diameter std = 5.5mm
	//shaft diameter std = 3mm
	//length defined
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
module 9g_servo(){
	difference(){			
		union(){
			color("steel blue") cube([23,12.5,22], center=true);
			color("steel blue") translate([0,0,5]) cube([32,12,2], center=true);
			color("steel blue") translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=20, center=true);
			color("steel blue") translate([-.5,0,2.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("steel blue") translate([-1,0,2.75]) cube([5,5.6,24.5], center=true);		
			color("white") translate([5.5,0,3.65]) cylinder(r=2.35, h=29.25, $fn=20, center=true);				
		}
		translate([10,0,-11]) rotate([0,-30,0]) cube([8,13,4], center=true);
		for ( hole = [14,-14] ){
			translate([hole,0,5]) cylinder(r=2.2, h=4, $fn=20, center=true);
		}	
	}
}
