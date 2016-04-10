//rh: mirror([0,0,0])
//lh: mirror([1,0,0])  

mirror([1,0,0])rotate([0,180,0]) {
    translate([-294.24,17.4+70,0]){
        linear_extrude(3)import("stepperMount_lh_IS.dxf",layer="bracket");
    }
    difference() {
        translate([0,17.92,-20])cube([52.52,3,20]);
        translate([10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
        translate([50-10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
    }
}

translate([-15,0,0])mirror([0,0,0])rotate([0,180,0]) {
    translate([-294.24,17.4+70,0]){
        linear_extrude(3)import("stepperMount_lh_IS.dxf",layer="bracket");
    }
    difference() {
        translate([0,17.92,-20])cube([52.52,3,20]);
        translate([10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
        translate([50-10,17.92+5,-10])rotate([90,0,0])cylinder(h=5,d=4);
    }
}