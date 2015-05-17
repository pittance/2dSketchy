mirror([1,0,0])rotate([0,180,0]) {
    translate([-137.28,14.16,0]){
        linear_extrude(3)import("motorMount_lh_IS.dxf");
    }
    difference() {
        translate([0,17.92,-20])cube([50,3,20]);
        #translate([10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
        #translate([50-10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
    }
}