
difference() {
    cube([60,72,3]);
    translate([10,(72-57)/2+57,0]){
        cylinder(h=3,d=3,$fn=15);
        translate([0,0,1])cylinder(h=2,d1=3,d2=6,$fn=15);
    }
    translate([50,(72-57)/2+57,0]){
        cylinder(h=3,d=3,$fn=15);
        translate([0,0,1])cylinder(h=2,d1=3,d2=6,$fn=15);
    }
    translate([30,30,0])cylinder(h=3,d=45,$fn=30);
    
}
translate([(60-48)/2,(60-48)/2,1])post();
translate([(60-48)/2+48,(60-48)/2,1])post();
translate([(60-48)/2+48,(60-48)/2+48,1])post();
translate([(60-48)/2,(60-48)/2+48,1])post();

module post() {
    difference() {
        cylinder(h=10,d=6,$fn=15);
        cylinder(h=10,d=2.5,$fn=15);
    }
}