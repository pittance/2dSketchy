pulleyDepth = 15;
pulleyRadius = 50;
pulleyResolution = 100;
pulleyRimDepth = 3;
pulleyWebDepth = 3;

union() {
	difference() {
		cylinder(h=pulleyDepth,r1=pulleyRadius,r2=pulleyRadius,$fn=pulleyResolution);
		cylinder(h=pulleyDepth-pulleyWebDepth,r1=pulleyRadius-pulleyRimDepth,r2=pulleyRadius-pulleyRimDepth,$fn=pulleyResolution);
		cylinder(h=pulleyDepth,r1=10,r2=10,$fn=pulleyResolution);
	}
	difference() {
		cylinder(h=pulleyWebDepth,r1=pulleyRadius+pulleyWebDepth,r2=pulleyRadius+pulleyWebDepth,$fn=pulleyResolution);
		cylinder(h=pulleyWebDepth,r1=pulleyRadius-pulleyWebDepth,r2=pulleyRadius-pulleyWebDepth,$fn=pulleyResolution);
	}
	translate([0,0,pulleyDepth-pulleyWebDepth]) {
		difference() {
			cylinder(h=pulleyWebDepth,r1=pulleyRadius+pulleyWebDepth,r2=pulleyRadius+pulleyWebDepth,$fn=pulleyResolution);
			cylinder(h=pulleyWebDepth,r1=pulleyRadius-pulleyWebDepth,r2=pulleyRadius-pulleyWebDepth,$fn=pulleyResolution);
		}
	}
}