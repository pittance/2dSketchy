detail = 20;	//20=low, 80=high
shaftDiameter = 6;
shaftClampLength = 25;
clampBoltDiameter = 3;
clampFlangeWidth = 7;
clampThickness = 2;
bearingOuterDiameter = 10;	//OD
bearingBoreDiameter = 5;		//bore i.e. 5 = M5 bolt
bearingInnerDiameter = 7;		//diameter of the inner runner of the bearing
bearingThickness = 5;
clampGap = 0.5;
bearingOffset = shaftDiameter/2+clampFlangeWidth;
tiny = 0.001;
m3boltHeadDiameter = 6; //6 for clearance, measures 5.5
m3boltHeadLength = 3;
m3boltShaftDiameter = 3;
m3boltShaftLength = 12;		//shaft length
m3nutDiameter = 6.5;
m3nutLength = 2;


module clampLower(useBearing) {
	difference() {
		difference() {
			//clamp block
			translate([-(shaftDiameter+clampThickness*2+clampFlangeWidth*2)/2,-(shaftClampLength+clampFlangeWidth),0]) {
				difference() {
					hull() {
					//base block...
						cube([shaftDiameter+clampThickness*2+clampFlangeWidth*2,shaftClampLength+clampFlangeWidth,clampThickness+shaftDiameter/2]);
						translate([0,0,(clampThickness+shaftDiameter/2)-(bearingThickness+clampThickness)]) 
							cylinder(d=bearingOuterDiameter+2*clampThickness*2,h=bearingThickness+clampThickness,$fn=detail);
					}
					//...remove bearing space
					union() {
						if (useBearing==1) cylinder(d=bearingOuterDiameter,h=bearingThickness+tiny,$fn=detail);
						#translate([0,0,-clampThickness]) cylinder(d=bearingBoreDiameter,h=bearingThickness+clampThickness*2,$fn=detail);
					}
				}
			}
			translate([0,tiny,clampThickness+shaftDiameter/2]) rotate([90,0,0]) cylinder(h=shaftClampLength,d=shaftDiameter,$fn=detail);
		}
	// clamp holes
	union() {
		#translate([shaftDiameter/2+clampFlangeWidth/2,-clampFlangeWidth,-3]) socketBolt();
		#translate([shaftDiameter/2+clampFlangeWidth/2,-shaftClampLength+clampFlangeWidth,-3]) socketBolt();
		#translate([-(shaftDiameter/2+clampFlangeWidth/2),-clampFlangeWidth,-3]) socketBolt();
		#translate([-(shaftDiameter/2+clampFlangeWidth/2),-shaftClampLength+clampFlangeWidth,-3]) socketBolt();
	}
	}
}

module clampCover() {
	difference() {
		difference() {
			union() {
				// clamp cover cyl section
				rotate([90,0,0]) cylinder(d=shaftDiameter+clampThickness*2,h=shaftClampLength,$fn=detail);
				// clamp flanges
				translate([-(shaftDiameter+clampThickness*2+clampFlangeWidth*2)/2,-shaftClampLength,clampGap]) cube([shaftDiameter+clampThickness*2+clampFlangeWidth*2,shaftClampLength,clampThickness]);
			}
			translate([-(shaftDiameter+clampThickness*2+clampFlangeWidth*2)/2,-shaftClampLength-tiny,-(shaftDiameter+clampThickness*2)+clampGap]) cube([shaftDiameter+clampThickness*2+clampFlangeWidth*2,shaftClampLength+tiny*2,shaftDiameter+clampThickness*2]);
		}
		rotate([90,0,0]) cylinder(d=shaftDiameter,h=shaftClampLength+tiny,$fn=detail);
		//bolt holes
		#translate([shaftDiameter/2+clampFlangeWidth/2,-clampFlangeWidth,-3]) socketBolt();
		#translate([shaftDiameter/2+clampFlangeWidth/2,-shaftClampLength+clampFlangeWidth,-3]) socketBolt();
		#translate([-(shaftDiameter/2+clampFlangeWidth/2),-clampFlangeWidth,-3]) socketBolt();
		#translate([-(shaftDiameter/2+clampFlangeWidth/2),-shaftClampLength+clampFlangeWidth,-3]) socketBolt();
		//sockets for nuts
		translate([shaftDiameter/2+clampFlangeWidth/2,-clampFlangeWidth,clampGap+clampThickness-m3nutLength/2]) cylinder(d=m3nutDiameter,h=m3nutLength*2,$fn=6);
		translate([shaftDiameter/2+clampFlangeWidth/2,-shaftClampLength+clampFlangeWidth,clampGap+clampThickness-m3nutLength/2]) cylinder(d=m3nutDiameter,h=m3nutLength*2,$fn=6);
		translate([-(shaftDiameter/2+clampFlangeWidth/2),-clampFlangeWidth,clampGap+clampThickness-m3nutLength/2]) cylinder(d=m3nutDiameter,h=m3nutLength*2,$fn=6);
		translate([-(shaftDiameter/2+clampFlangeWidth/2),-shaftClampLength+clampFlangeWidth,clampGap+clampThickness-m3nutLength/2]) cylinder(d=m3nutDiameter,h=m3nutLength*2,$fn=6);
	}
}

module socketBolt() {
	union() {
		//socket head
		cylinder(d=m3boltHeadDiameter,h=m3boltHeadLength,$fn=detail);
		//shaft
		translate([0,0,m3boltHeadLength]) cylinder(d=m3boltShaftDiameter,h=m3boltShaftLength,$fn=detail);
	}
}

// TOP LEVEL ASSEMBLY
translate([0,0,clampThickness+shaftDiameter/2]) rotate([0,180,0]) clampLower(1);
translate([-35,0,clampThickness+shaftDiameter/2]) rotate([0,180,0]) clampLower(0);
translate([35,0,-clampGap]) clampCover();
translate([35,30,-clampGap]) clampCover();








module shaftClamp() {
	rotate([90,0,0]) {
		difference() {
			difference() {
				union() {
					//outer clamp
					cylinder(h=shaftClampLength+clampFlangeWidth,d=shaftDiameter+(clampThickness*2),$fn=detail);
					//flange
					translate([-(shaftDiameter+clampFlangeWidth*2+clampThickness*2)/2,-clampThickness,0]) cube([shaftDiameter+clampFlangeWidth*2+clampThickness*2,clampThickness,shaftClampLength+clampFlangeWidth]);
				}
				//inner clamp (for rod)
				cylinder(h=shaftClampLength,d=shaftDiameter,$fn=detail);
			}
			//remove the top half - the bottom half does not have a gap for clamping
			translate([-(shaftDiameter+clampThickness*2+clampFlangeWidth*2)/2,0])  cube([shaftDiameter+clampThickness*2+clampFlangeWidth*2,shaftDiameter+clampThickness*2,shaftClampLength+clampFlangeWidth]);
		}
	}
	//bearing socket
	translate([-bearingOffset,-shaftClampLength-(bearingOuterDiameter+clampThickness*2)/2-clampThickness,-(bearingThickness+clampThickness)]) {
		#cylinder(d=bearingOuterDiameter+clampThickness*2,h=bearingThickness+clampThickness);
	}
}


height = 15;
barLength = 40;
holeDiam = 8;	//M8 bolt
ledgeThick = 2.5;

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

//translate([0,-height,0]) shaftMount();
//translate([0,height,0]) shaftMount();