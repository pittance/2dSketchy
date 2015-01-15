detail = 80;	//20=low, 80=high
height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;
shaftDiam = 6;

shaftMount2();

module shaftMount2() {
	difference() {
		union() {
			cylinder(h=height,d=holeDiam*2,$fn=detail);
			translate([0,-holeDiam,0])cube([barLength,holeDiam*2,height]);
		}
		cylinder(h=height,d=holeDiam,$fn=detail);
		#translate([holeDiam,0,height/2])rotate([0,90,0]) {
			cylinder(h=barLength,d=shaftDiam,$fn=detail);
			translate([-height,-shaftDiam/4,0])cube([height,shaftDiam/2,barLength]);
		}
	}
	
}

module shaftMount() {
	difference() {
		union() {
			difference() {
				cylinder(h=height,d=holeDiam*2,$fn=detail);
				cylinder(h=height,d=holeDiam,$fn=detail);
			}
			translate([-barLength/2,holeDiam/2,0]) cube([barLength,3*holeDiam/4,height]);
		}
		translate([-barLength/2,7,ledgeThick]) cube([barLength,5,height-ledgeThick]);
		translate([0,holeDiam,height/2+ledgeThick/2]) rotate([90,0,0]) {
			translate([-15,0,0]) cylinder(h=10,r=1.5,center=true,$fn=detail);
			translate([15,0,0]) cylinder(h=10,r=1.5,center=true,$fn=detail);
		}
	}
}
