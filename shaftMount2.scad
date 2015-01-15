detail = 20;	//20=low, 80=high
height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;
shaftDiam = 6;
shaftPos = height/3;
shaftClampedLength = 15;
shaftPad = 1;

layer = 0.2;

m5bolt = 5;
m3bolt = 3;
bearingDiam = 10;
bearingThick = 4;
bearingPad = 2;         //padding around the outside of the bearing outer
bearingMarg = 1;        //thickness under the ends of the bearing

tiny=0.001;

elbowBearing();

module elbow() {
    
}

module elbowBearing() {
    difference() {
        //main body (bearing housing + shaft clamp)
        union() {
            cylinder(h=bearingThick+bearingMarg,d=bearingDiam+2*bearingPad,$fn=detail);
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        }
        //remove bearing
        translate([0,0,bearingMarg])cylinder(h=m3bolt+shaftDiam+shaftPad*2,d=bearingDiam,$fn=detail);
        //bolt hole
        cylinder(h=bearingThick,d=m5bolt,$fn=detail);
        //shaft
        translate([bearingPad+bearingDiam/2,0,shaftPad+shaftDiam/2])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        //keyway for clamping
        translate([bearingPad+bearingDiam/2,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftDiam*2]);
        //clamp bolt
        #translate([shaftClampedLength+bearingDiam/2-bearingPad,tiny/2+shaftPad+shaftDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=tiny+shaftDiam+2*shaftPad,d=m3bolt,$fn=detail);
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
		#translate([barLength-holeDiam,holeDiam-4.5,1.5+shaftPos+shaftDiam/2])rotate([90,0,0])boltHoleNut(7,5.7,12,3.5);
	}
	
}

module elbow1() {
	difference() {
		union() {
			cylinder(h=height,d=holeDiam*2,$fn=detail);
			translate([0,-holeDiam,0])cube([barLength,holeDiam*2,height]);
		}
		cylinder(h=height,d=m5bolt,$fn=detail);
		translate([0,0,height/2-0.5])cylinder(h=height,d=holeDiam*2+1,$fn=detail);	//assumes 1mm washer
		translate([0,0,height/2-0.5-bearingThick])cylinder(h=bearingThick,d=bearingDiam,$fn=detail);	//assumes 1mm washer
		translate([holeDiam,0,shaftPos])rotate([0,90,0]) {
			cylinder(h=barLength,d=shaftDiam,$fn=detail);
			translate([-height,-shaftDiam/4,0])cube([height,shaftDiam/2,barLength]);
		}
		#translate([barLength-holeDiam,holeDiam-4.5,1.5+shaftPos+shaftDiam/2])rotate([90,0,0])boltHoleNut(7,5.7,12,3.5);
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