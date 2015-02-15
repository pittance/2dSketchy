detail = 60;	//20=low, 80=high
height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;
shaftDiam = 6+0.25;     //add a bit (6mm actual)
shaftPos = height/3;
shaftClampedLength = 35;        //after much fiddling this isn't the clamped length any more
shaftPad = 1;

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

tiny=0.001;

//print 4 copies of the elbow joints
//translate([-15,-30,0]) {
//    translate([0,0,0])elbowBearing2();
//    translate([0,20,0])elbowBearing2();
//    translate([0,40,0])elbowBearing2();
//    translate([0,60,0])elbowBearing2();
//}
// 
//print 1 each of the wrist joints

//print 1 each of the shoulder shaft mounts
translate([0,-15,0])shaftMount();
translate([0,15,0])shaftMount();


//build surface for check
//translate([0,0,-1])cylinder(h=1,d=175);

module wrist1() {
    
}
module wrist2() {
    
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
		}
		cylinder(h=height,d=holeDiam,$fn=detail);
		translate([holeDiam,0,shaftPos])rotate([0,90,0]) {
			cylinder(h=barLength,d=shaftDiam,$fn=detail);
			translate([-height,-shaftDiam/4,0])cube([height,shaftDiam/2,barLength]);
		}
		translate([barLength-holeDiam,holeDiam-4.5,1.5+shaftPos+shaftDiam/2])rotate([90,0,0])boltHoleNut(7,5.7,12,3.5);
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
		translate([0,0,shaftLength-2.4])cylinder(h=2.4,d=6.5,$fn=6);
	}
}

