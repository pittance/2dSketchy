detail = 60;	//20=low, 80=high
height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;
shaftDiam = 6+0.25;     //add a bit (6mm actual)
shaftPos = height/3;
shaftClampedLength = 15;
shaftPad = 1;

layer = 0.2;

m5bolt = 5;
m5boltHead = 8;
m3bolt = 3;
bearingDiam = 10+0.5;       //add a bit (10mm actual)
bearingThick = 4;
bearingPad = 2;                 //padding around the outside of the bearing outer
bearingMarg = 0.4;                //thickness under the ends of the bearing
bearingInterfaceDiam = 7;       //the nub that sticks up from the non-bearing side
shaftZ = (bearingThick + bearingMarg + bearingMarg/2); //was shaftPad+shaftDiam/2

tiny=0.001;

elbow2();

module elbow2() {
    difference() {
        hull() {
            cylinder(h=bearingThick+bearingMarg,d=bearingInterfaceDiam,$fn=detail);
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
        }
        //remove bearing (clips top half sections)
        translate([0,0,bearingMarg+bearingThick])cylinder(h=m3bolt+shaftDiam+shaftPad*2,d=bearingDiam+bearingPad,$fn=detail);
        //shaft
        translate([bearingPad+bearingDiam/2,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
    }
}

module elbow() {
    difference() {
        union() {
            difference() {
                //main body (bearing housing + shaft clamp)
                union() {
                    #cylinder(h=bearingThick+bearingMarg,d=bearingInterfaceDiam,$fn=detail);
                    translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
                }
                //remove bearing (clips top half sections)
                translate([0,0,bearingMarg+bearingThick])cylinder(h=m3bolt+shaftDiam+shaftPad*2,d=bearingDiam+bearingPad,$fn=detail);
                //shaft
                translate([bearingPad+bearingDiam/2,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
                //keyway for clamping
                translate([bearingPad+bearingDiam/2,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftDiam*2]);
                //clamp bolt
                translate([shaftClampedLength+bearingDiam/2-bearingPad,tiny/2+shaftPad+shaftDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=tiny+shaftDiam+2*shaftPad,d=m3bolt,$fn=detail);
                //remove extra bits for pivot angle
                translate([0,0,bearingMarg+bearingThick])rotate([0,0,25])cube([bearingDiam,2*bearingPad,bearingDiam]);
                mirror([0,1,0])translate([0,0,bearingMarg+bearingThick])rotate([0,0,25])cube([bearingDiam,2*bearingPad,bearingDiam]);
            }
            translate([0,0,bearingThick+bearingMarg])cylinder(h=bearingMarg,d=bearingInterfaceDiam,$fn=detail);
        }
        //bolt hole
        cylinder(h=bearingThick+bearingMarg+bearingMarg,d=m5bolt,$fn=detail);
        //cylinder(h=bearingThick-bearingMarg,d=m5boltHead,$fn=detail);
    }
    //translate([-m5boltHead/2,-m5boltHead/2,bearingThick-bearingMarg])cube([m5boltHead,m5boltHead,0.2]);
}

module elbowBearing() {
    //needs clamping for bearing...
    difference() {
        //main body (bearing housing + shaft clamp)
        union() {
            cylinder(h=bearingThick+bearingMarg,d=bearingDiam+2*bearingPad,$fn=detail);
            translate([0,-(shaftDiam+shaftPad*2)/2,0])cube([bearingPad+shaftClampedLength+bearingDiam/2,shaftDiam+shaftPad*2,shaftPad+m3bolt+shaftDiam+shaftPad*2]);
            translate([-bearingDiam,-(shaftDiam+shaftPad*2)/2,0])cube([bearingDiam,shaftDiam+shaftPad*2,bearingThick+bearingMarg]);
        }
        //remove bearing
        translate([0,0,bearingMarg])cylinder(h=m3bolt+shaftDiam+shaftPad*4,d=bearingDiam+bearingPad,$fn=detail);
        //bolt hole
        cylinder(h=bearingThick,d=bearingInterfaceDiam,$fn=detail);
        //shaft
        translate([bearingPad+bearingDiam/2,0,shaftZ])rotate([0,90,0])cylinder(h=shaftClampedLength,d=shaftDiam,$fn=detail);
        //keyway for clamping
        translate([bearingPad+bearingDiam/2,-shaftDiam/8,shaftPad+shaftDiam/2])cube([bearingDiam/2+shaftClampedLength,shaftDiam/4,shaftDiam*2]);
        //clamp bolt
        translate([shaftClampedLength+bearingDiam/2-bearingPad,tiny/2+shaftPad+shaftDiam/2,shaftPad*2+shaftDiam+m3bolt/2])rotate([90,0,0])cylinder(h=tiny+shaftDiam+2*shaftPad,d=m3bolt,$fn=detail);
        //remove extra bits for pivot angle
        translate([0,0,bearingMarg+bearingThick])rotate([0,0,25])cube([bearingDiam,2*bearingPad,bearingDiam]);
        mirror([0,1,0])translate([0,0,bearingMarg+bearingThick])rotate([0,0,25])cube([bearingDiam,2*bearingPad,bearingDiam]);
        //keyway for bearing clamp
        translate([-bearingDiam,-shaftDiam/8,0])cube([bearingDiam,shaftDiam/4,bearingThick+bearingMarg]);
        //clamp bolt
        translate([-bearingDiam+bearingDiam/4,-(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,5.5,tiny+shaftDiam+2*shaftPad,3);
        translate([-bearingDiam+bearingDiam/4,3+(shaftDiam+2*shaftPad)/2,(bearingThick+bearingMarg)/2])rotate([90,0,180])boltHole(3,6.3,tiny+shaftDiam+2*shaftPad,3);
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