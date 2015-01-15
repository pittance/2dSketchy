/********** customizable variables **********/

render_part = 1; // [1:Motor end, 2:Input half, 3:Output half, 4:Planetary carrier, 5:Sun gear, 6:Planet gears, 7:Output end, 8: Intermediate carrier, 9:Intermediate input half, 10:Intermediate output half]

// final ratio of planetary gearbox
final_ratio = 5.45; // [4.62, 4.91, 5.08, 5.23, 5.45, 5.54, 6, 6.55]

// (changing will likely require a change in ring diameter)
stepper_motor=0; // [0:NEMA17, 1:NEMA23]

// pitch diameter of ring gear (mm)
ring_diameter = 60; // [60:120]

// additional thickness for ring gear wall (mm)
radius_ring_back = 4; // [4:10]

// face width (height; thickness) of planetary gears (sun and ring size are adjusted to fit, mm)
planetary_face_width = 10; // [10:16]

// angle of helix
helix_angle = 30; // [0:35]

// number of screws around ring
case_screws = 4; // [4:8]

// total height of motor mount (mm)
height_motor_pedestal = 13; // [13:50]

// total height of output mount (mm)
height_output_mount = 16; // [16:50]

render(selected_gears(final_ratio), selected_motor(stepper_motor));

module render(
	gears,
	motor) {

	circular_pitch = fit_spur_gears(gears[0], gears[2], ring_diameter/2);

	rp_a = pitch_radius(gears[2], circular_pitch); // pitch radius of annulus
	rr_a = root_radius(gears[2], circular_pitch, clearance_a); // root radius of annulus
	r_outer = rp_a+(rp_a-rr_a)+radius_ring_back; // outer radius of annulus with wall
	r_mounts = r_outer+d_M3_screw/2; // radius of holes for case screws

	h_s_h_a = planetary_face_width+2; // height of sun gear and annulus

	twist_s = twist_for_helix_angle(helix_angle, pitch_radius(gears[0], circular_pitch), h_s_h_a/2); // twist of the sun gear to yield helix angle
	twist_s_mm = twist_s/h_s_h_a; // sun gear twist per mm

	if (render_part == 1)
		end_motor(
			r_outer=r_outer,
			r_mounts=r_mounts,
			motor=motor);

	if (render_part == 2)
		input_half(
			circular_pitch=circular_pitch,
			number_of_teeth=gears[2],
			twist=twist_s_mm*h_s_h_a*gears[0]/gears[2],
			r_outer=r_outer,
			r_mounts=r_mounts,
			face_width = h_s_h_a);

	if (render_part == 3)
		output_half(
			circular_pitch=circular_pitch,
			number_of_teeth=gears[2],
			twist=twist_s_mm*h_s_h_a*gears[0]/gears[2],
			r_outer=r_outer,
			r_mounts=r_mounts,
			face_width = h_s_h_a);

	if (render_part == 4)
		planetary_carrier(
			rr_p=root_radius(gears[1], circular_pitch),
			rp_s=pitch_radius(gears[0], circular_pitch),
			rp_p=pitch_radius(gears[1], circular_pitch),
			planets=gears[3]);

	if (render_part == 5)
		translate([0, 0, h_s_h_a+10])
			mirror([0, 0, 1])
				 gear_sun(
					circular_pitch=circular_pitch,
					number_of_teeth=gears[0],
					twist=twist_s,
					bore_diameter = motor[2],
					face_width = h_s_h_a);

	if (render_part == 6)
		planet_gear_plate(
			circular_pitch=circular_pitch,
			number_of_teeth=gears[1],
			face_width = planetary_face_width,
			twist = twist_s_mm*planetary_face_width*gears[0]/gears[1],
			planets=gears[3]);

	if (render_part == 7)
		end_output(
			r_outer=r_outer,
			r_mounts=r_mounts,
			motor=motor);

	if (render_part == 8)
		intermediate(
			circular_pitch=circular_pitch,
			sun_teeth=gears[0],
			sun_twist=twist_s,
			sun_face_width=h_s_h_a,
			rr_p=root_radius(gears[1], circular_pitch),
			rp_s=pitch_radius(gears[0], circular_pitch),
			rp_p=pitch_radius(gears[1], circular_pitch),
			planets=gears[3]);

	if (render_part == 9)
		intermediate_input_half(
			circular_pitch=circular_pitch,
			number_of_teeth=gears[2],
			twist=twist_s_mm*h_s_h_a*gears[0]/gears[2],
			r_outer=r_outer,
			r_mounts=r_mounts,
			face_width = h_s_h_a);

	if (render_part == 10)
		intermediate_output_half(
			circular_pitch=circular_pitch,
			number_of_teeth=gears[2],
			twist=twist_s_mm*h_s_h_a*gears[0]/gears[2],
			r_outer=r_outer,
			r_mounts=r_mounts,
			face_width = h_s_h_a);

	if (render_part == 11)
		assembly(
			ns=gears[0],
			np=gears[1],
			na=gears[2],
			circular_pitch=circular_pitch,
			twist_s_mm=twist_s_mm,
			r_outer=r_outer,
			r_mounts=r_mounts,
			planets=gears[3],
			motor=motor,
			z_section=z_section);

	if (render_part == 12)
		test_mesh(
			ns=gears[0],
			np=gears[1],
			na=gears[2],
			circular_pitch=circular_pitch,
			twist_s_mm=twist_s_mm,
			planets=gears[3],
			r_outer=r_outer,
			r_mounts=r_mounts);
}


// ignore variable values

// provides array of [ns, np, na, planets] based upon the final ratio provided 
function selected_gears(ratio) = 
	(ratio == 4.62) ? [13, 17, 47, 3] :
	(ratio == 4.91) ? [11, 16, 43, 3] :
	(ratio == 5.08) ? [13, 20, 53, 3] :
	(ratio == 5.23) ? [13, 21, 55, 4] :
	(ratio == 5.45) ? [11, 19, 49, 3] :
	(ratio == 5.54) ? [13, 23, 59, 3] :
	(ratio == 6) ? [11, 22, 55, 3] :
	[11, 25, 61, 3]
;

/* array of motor dimensions for motor_no:
		0:l_NEMA
		1:d_NEMA_collar
		2:d_NEMA_shaft
		3:d_NEMA_mounts
		4:cc_NEMA mounts
		5:c_d_NEMA mounts
		6:d_nut_mount
*/
function selected_motor(motor_no) = 
	(motor_no == 0) ? [42, 28,  5.3, 3.5, 31, 21.92031021678297, 6.2] :
	[56.4, 40, 6.7, 4.3, 47.14, 33.333013665, 8.7]
;

// this only works with the assembly rendering - allows you to move through the cross section
z_section = 20; // [0:100]

clearance_a = 0.2; // clearance to add to the annulus
t_case = 3; // case wall thickness

// from bearings.scad:
od_608 = 22.5;
id_608 = 8.4;
h_608 = 7;

// 624 bearing
od_624 = 13.4;
id_624 = 4.4;
h_624 = 5;

module bearing(type=608) {
	if (type==608)
		difference() {
			cylinder(r=od_608/2, h=h_608);
	
			translate([0, 0, -1])
				cylinder(r=id_608/2, h=h_608+2);
		}

	if (type==624)
		difference() {
			cylinder(r=od_624/2, h=h_624);
	
			translate([0, 0, -1])
				cylinder(r=id_624/2, h=h_624+2);
		}
}

// from fasteners.scad:
d_M3_screw = 3.5; // measured 2.9
d_M3_screw_head = 5.8; // measured 5.5
d_M3_washer = 6.9; // measured 6.7
d_M3_nut = 6.2;
h_M3_nut = 2.7; // measured 2.35
d_M3_cap = 5.5;
h_M3_cap = 3;

d_M4_screw = 4.3;
d_M4_cap = 7.4; // measured 12
h_M4_cap = 4;
d_M4_nut = 8.7;
h_M4_nut = 3.5; // measured 3.1
h_M4_locknut = 5;
d_M4_washer = 9; // measured 8.75
h_M4_washer = 0.75;

d_M6_screw = 6.5;
d_M6_nut = 11.3;
h_M6_nut = 4.2;

d_M8_screw = 8.4;
d_M8_nut = 15;
h_M8_nut = 6.35;
d_M8_washer= 16;
h_M8_washer = 1.5;

// from Trangles.scad:
module equilateral(h) {
	isosoles(0.577350269*h*2, h);
}

module isosoles(b, h) {
	polygon(points=[[0, 0], [b/2, h], [-b/2, h]]);
}

// from gear_calculator.scad:
// spur_generator Copyright 2011 Cliff L. Biffle.
// This file is licensed Creative Commons Attribution-ShareAlike 3.0.
// http://creativecommons.org/licenses/by-sa/3.0/

pi=3.1415926535897932384626433832795;

// Couple handy arithmetic shortcuts
function sqr(n) = pow(n, 2);
function cube(n) = pow(n, 3);

// This was derived as follows:
// In Greg Frost's original script, the outer radius of a spur
// gear can be computed as...
function pitch_radius(teeth, circular_pitch) =
	(sqr(teeth) * sqr(circular_pitch) + 64800)
		/ (360 * teeth * circular_pitch);

// We can fit gears to the spacing by working it backwards.
//  spacing = gear_outer_radius(teeth1, cp)
//          + gear_outer_radius(teeth2, cp);
//
// I plugged this into an algebra system, assuming that spacing,
// teeth1, and teeth2 are given.  By solving for circular pitch,
// we get this terrifying equation:
function fit_spur_gears(n1, n2, spacing) =
	(180 * spacing * n1 * n2  +  180
		* sqrt(-(2*n1*cube(n2)-(sqr(spacing)-4)*sqr(n1)*sqr(n2)+2*cube(n1)*n2)))
	/ (n1*sqr(n2) + sqr(n1)*n2);

// following functions taken straight out of parametric_involute_gear_v5.0.scad

function outer_radius(teeth, circular_pitch) =
	circular_pitch*(teeth/360+1/180);

// Pitch diameter: Diameter of pitch circle.
function pitch_diameter(teeth, circular_pitch)  =
	teeth * circular_pitch / 180;

function teeth_for_pitch_diameter(d_pitch, circular_pitch) = 
	d_pitch * 180 / circular_pitch;

// Base Circle
function base_radius(teeth, circular_pitch, pressure_angle=28) =
	pitch_diameter(teeth, circular_pitch)*cos(pressure_angle)/2;

// Diametrial pitch: Number of teeth per unit length.
function pitch_diametrial(teeth, circular_pitch) =
	teeth / pitch_diameter(teeth, circular_pitch);

// Addendum: Radial distance from pitch circle to outside circle.
function addendum(teeth, circular_pitch) =
	1/pitch_diametrial(teeth, circular_pitch);

// Dedendum: Radial distance from pitch circle to root diameter
function dedendum(teeth, circular_pitch, clearance=0) =
	addendum(teeth, circular_pitch) + clearance;

// Root diameter: Diameter of bottom of tooth spaces.
function root_radius(teeth, circular_pitch, clearance=0) =
	pitch_radius(teeth, circular_pitch)-dedendum(teeth, circular_pitch, clearance);

function backlash_angle(teeth, circular_pitch, backlash=0) =
	backlash / pitch_radius(teeth, circular_pitch) * 180 / pi;

function half_thick_angle(teeth, circular_pitch, backlash=0) =
	(360 / teeth - backlash_angle(teeth, circular_pitch, backlash=0)) / 4;

// calculates the twist required to yield the provided helix angle - simple trig
function twist_for_helix_angle(helix_angle, pitch_radius, thickness) =
	2*atan(0.5*thickness*tan(helix_angle)/pitch_radius);


// from parametric_involute_gear_v5.0.scad:
module gear (
	number_of_teeth=15,
	circular_pitch=false, diametral_pitch=false,
	pressure_angle=28,
	clearance = 0.2,
	gear_thickness=5,
	rim_thickness=8,
	rim_width=5,
	hub_thickness=10,
	hub_diameter=15,
	bore_diameter=5,
	circles=0,
	backlash=0,
	twist=0,
	involute_facets=0)
{
	if (circular_pitch==false && diametral_pitch==false) 
		echo("MCAD ERROR: gear module needs either a diametral_pitch or circular_pitch");

	//Convert diametrial pitch to our native circular pitch
	circular_pitch = (circular_pitch!=false?circular_pitch:180/diametral_pitch);

	// Pitch diameter: Diameter of pitch circle.
	pitch_diameter  =  number_of_teeth * circular_pitch / 180;
	pitch_radius = pitch_diameter/2;

	// Base Circle
	base_radius = pitch_radius*cos(pressure_angle);

	// Diametrial pitch: Number of teeth per unit length.
	pitch_diametrial = number_of_teeth / pitch_diameter;

	// Addendum: Radial distance from pitch circle to outside circle.
	addendum = 1/pitch_diametrial;

	//Outer Circle
	outer_radius = pitch_radius+addendum;

	// Dedendum: Radial distance from pitch circle to root diameter
	dedendum = addendum + clearance;

	// Root diameter: Diameter of bottom of tooth spaces.
	root_radius = pitch_radius-dedendum;
	backlash_angle = backlash / pitch_radius * 180 / pi;
	half_thick_angle = (360 / number_of_teeth - backlash_angle) / 4;

	//echo ("Teeth:", number_of_teeth, " Pitch radius:", pitch_radius, "Outer radius:", outer_radius);

	// Variables controlling the rim.
	rim_radius = root_radius - rim_width;

	// Variables controlling the circular holes in the gear.
	circle_orbit_diameter=hub_diameter/2+rim_radius;
	circle_orbit_curcumference=pi*circle_orbit_diameter;

	// Limit the circle size to 90% of the gear face.
	circle_diameter=
		min (
			0.70*circle_orbit_curcumference/circles,
			(rim_radius-hub_diameter/2)*0.9);

	difference ()
	{
		union ()
		{
			difference ()
			{
				linear_extrude (height=rim_thickness, convexity=10, twist=twist)
				gear_shape (
					number_of_teeth,
					pitch_radius = pitch_radius,
					root_radius = root_radius,
					base_radius = base_radius,
					outer_radius = outer_radius,
					half_thick_angle = half_thick_angle,
					involute_facets=involute_facets);

				if (gear_thickness < rim_thickness)
					translate ([0,0,gear_thickness])
					cylinder (r=rim_radius,h=rim_thickness-gear_thickness+1);
			}
			if (gear_thickness > rim_thickness)
				cylinder (r=rim_radius,h=gear_thickness);
			if (hub_thickness > gear_thickness)
				translate ([0,0,gear_thickness])
				cylinder (r=hub_diameter/2,h=hub_thickness-gear_thickness);
		}
		translate ([0,0,-1])
		cylinder (
			r=bore_diameter/2,
			h=2+max(rim_thickness,hub_thickness,gear_thickness));
		if (circles>0)
		{
			for(i=[0:circles-1])	
				rotate([0,0,i*360/circles])
				translate([circle_orbit_diameter/2,0,-1])
				cylinder(r=circle_diameter/2,h=max(gear_thickness,rim_thickness)+3);
		}
	}
}

module gear_shape (
	number_of_teeth,
	pitch_radius,
	root_radius,
	base_radius,
	outer_radius,
	half_thick_angle,
	involute_facets)
{
	union()
	{
		rotate (half_thick_angle) circle ($fn=number_of_teeth*2, r=root_radius);

		for (i = [1:number_of_teeth])
		{
			rotate ([0,0,i*360/number_of_teeth])
			{
				involute_gear_tooth (
					pitch_radius = pitch_radius,
					root_radius = root_radius,
					base_radius = base_radius,
					outer_radius = outer_radius,
					half_thick_angle = half_thick_angle,
					involute_facets=involute_facets);
			}
		}
	}
}

module involute_gear_tooth (
	pitch_radius,
	root_radius,
	base_radius,
	outer_radius,
	half_thick_angle,
	involute_facets)
{
	min_radius = max (base_radius,root_radius);

	pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
	pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
	centre_angle = pitch_angle + half_thick_angle;

	start_angle = involute_intersect_angle (base_radius, min_radius);
	stop_angle = involute_intersect_angle (base_radius, outer_radius);

	res=(involute_facets!=0)?involute_facets:($fn==0)?5:$fn/4;

	union ()
	{
		for (i=[1:res])
		assign (
			point1=involute (base_radius,start_angle+(stop_angle - start_angle)*(i-1)/res),
			point2=involute (base_radius,start_angle+(stop_angle - start_angle)*i/res))
		{
			assign (
				side1_point1=rotate_point (centre_angle, point1),
				side1_point2=rotate_point (centre_angle, point2),
				side2_point1=mirror_point (rotate_point (centre_angle, point1)),
				side2_point2=mirror_point (rotate_point (centre_angle, point2)))
			{
				polygon (
					points=[[0,0],side1_point1,side1_point2,side2_point2,side2_point1],
					paths=[[0,1,2,3,4,0]]);
			}
		}
	}
}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / pi;

// Calculate the involute position for a given base radius and involute angle.

function rotated_involute (rotate, base_radius, involute_angle) = 
[
	cos (rotate) * involute (base_radius, involute_angle)[0] + sin (rotate) * involute (base_radius, involute_angle)[1],
	cos (rotate) * involute (base_radius, involute_angle)[1] - sin (rotate) * involute (base_radius, involute_angle)[0]
];

function mirror_point (coord) = 
[
	coord[0], 
	-coord[1]
];

function rotate_point (rotate, coord) =
[
	cos (rotate) * coord[0] + sin (rotate) * coord[1],
	cos (rotate) * coord[1] - sin (rotate) * coord[0]
];

function involute (base_radius, involute_angle) = 
[
	base_radius*(cos (involute_angle) + involute_angle*pi/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*pi/180*cos (involute_angle)),
];

/**********

 as written, generates planetary gearboxs
 rules are invoked only as checks - rendering is not suspended if any are violated, so make sure
 design is valid before printing!

/**********
Rules for epicyclic gears (from http://www.wmberg.com/tools/):

(ns+na)/planet_gears = integer - mesh rule

ns+2*np = na - pitch diameter rule

planet_gears*asin((np+2)/(ns+np)) <= 360 - overlap rule

**********/

function valid_mesh(ns, na, planet_gears) = 
	((ns+na)%planet_gears == 0);

function valid_pitch_diameter(ns, np, na) = 
	(ns+2*np == na);

function valid_overlap(np, ns, planet_gears) = 
	(planet_gears *asin((np+2)/(ns+np)) <= 360);

function ratio_planetary(ns, na) = 
	na/ns +1;

// shaft and bearing dims
d_s_shaft = 5.3; // diameter of sun gear shaft
d_p_shaft = d_M4_screw; // diameter of planetary gear shaft
d_p_shaft_relief = d_M4_washer+1; // bore diameter at planetary gear end nearest carrier
h_p_indent = h_M4_cap; // height of above bore
d_p_nut = d_M4_nut; // diameter of nut cages on planetary carrier
h_p_nut = h_M4_locknut+2*h_M4_washer; // height of above
d_p_bearing = od_624; // diameter of planetary bearing
h_p_bearing = h_624; // height of planetary bearing

// planetary carrier dims
t_pc = h_p_nut+3; // thickness of planetary carrier
h_pc_collar = h_M8_nut+4; // overall height of carrier collar

module helical_gear (
	circular_pitch,
	gear_thickness,
	rim_thickness,
	hub_thickness,
	number_of_teeth,
	circles,
	bore_diameter,
	hub_diameter,
	twist) {

	gear (
		circular_pitch=circular_pitch,
		gear_thickness = gear_thickness,
		rim_thickness = rim_thickness,
		hub_thickness = hub_thickness,
		number_of_teeth = number_of_teeth,
		circles=circles,
		bore_diameter=bore_diameter,
		hub_diameter=hub_diameter,
		twist = twist);

}

module double_helical_gear (
	circular_pitch,
	gear_thickness,
	rim_thickness,
	hub_thickness,
	number_of_teeth,
	circles,
	bore_diameter,
	hub_diameter,
	twist) {

	translate([0, 0, gear_thickness/2])
		union() {
			helical_gear (
				circular_pitch=circular_pitch,
				gear_thickness = gear_thickness/2,
				rim_thickness = rim_thickness/2,
				hub_thickness = hub_thickness-gear_thickness/2,
				number_of_teeth = number_of_teeth,
				circles=circles,
				bore_diameter=bore_diameter,
				hub_diameter=hub_diameter,
				twist = twist);
		
			mirror([0, 0, 1])
				helical_gear (
					circular_pitch=circular_pitch,
					gear_thickness = gear_thickness/2,
					rim_thickness = rim_thickness/2,
					hub_thickness = 0,
					number_of_teeth = number_of_teeth,
					circles=circles,
					bore_diameter=bore_diameter,
					hub_diameter=0,
					twist = twist);
		}

}

module gear_sun(
	circular_pitch,
	number_of_teeth,
	twist,
	bore_diameter,
	face_width) {

	difference() {
		if (helix_angle==0) {
			gear(
				circular_pitch=circular_pitch,
				gear_thickness = face_width,
				rim_thickness = face_width,
				hub_thickness = face_width+10,
				number_of_teeth = number_of_teeth,
				circles=0,
				bore_diameter=bore_diameter,
				hub_diameter=20);
		}
		else {
			double_helical_gear(
				circular_pitch=circular_pitch,
				gear_thickness = face_width,
				rim_thickness = face_width,
				hub_thickness = face_width+10,
				number_of_teeth = number_of_teeth,
				circles=0,
				bore_diameter=bore_diameter,
				hub_diameter=20,
				twist = twist);
		}

		// set screw
		translate([0, 0, face_width+5])
			rotate([0, 270, 0])
				union() {
					cylinder(r=d_M3_screw/2, h=12);

					translate([0, 0, bore_diameter/2+1.5])
						hull() {
							cylinder(r=d_M3_nut/2+0.3, h=h_M3_nut+0.3, $fn=6);

							translate([8, 0, 0])
								cylinder(r=d_M3_nut/2+0.3, h=h_M3_nut+0.3, $fn=6);
						}
				}
	}
}

module gear_planet(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width) {

	difference() {
		if (helix_angle==0) {
			gear (circular_pitch=circular_pitch,
				gear_thickness = face_width,
				rim_thickness = face_width,
				hub_thickness = face_width,
				number_of_teeth = number_of_teeth,
				circles=0,
				bore_diameter=d_p_shaft_relief,
				hub_diameter=d_p_bearing+3);
		}
		else {
			double_helical_gear (circular_pitch=circular_pitch,
				gear_thickness = face_width,
				rim_thickness = face_width,
				hub_thickness = face_width,
				number_of_teeth = number_of_teeth,
				circles=0,
				bore_diameter=d_p_shaft_relief,
				hub_diameter=d_p_bearing+3,
				twist = twist);
		}

		translate([0, 0, face_width-h_p_bearing-h_p_indent])
			cylinder(r=d_p_bearing/2, h=h_p_bearing+h_p_indent+1);

	}
}

// this was fun!
module annulus_shape (
	teeth,
	circular_pitch,
	radius_back,
	clearance) {

	r_pitch = pitch_radius(teeth, circular_pitch);
	r_root = root_radius(teeth, circular_pitch, clearance);
		union() {
			for (i = [1:teeth])
			{
				rotate ([0,0,i*360/teeth])
					intersection() {
						translate([-2*r_pitch, 0, 0])
								involute_gear_tooth (
									r_pitch,
									r_root,
									base_radius(teeth, circular_pitch),
									outer_radius(teeth, circular_pitch),
									half_thick_angle(teeth, circular_pitch),
									involute_facets=0);
	
						circle ($fn=teeth*2, r=r_pitch+(r_pitch-r_root)+radius_back);
					}
			}

			difference() {
				circle ($fn=teeth*2, r=r_pitch+(r_pitch-r_root)+radius_back);

				circle ($fn=teeth*2, r=r_pitch+(r_pitch-r_root));
			}
		}
}

module annulus(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width,
	r_outer,
	r_mounts) {

//	rp_a = pitch_radius(number_of_teeth, circular_pitch);
//	rr_a = root_radius(number_of_teeth, circular_pitch, clearance_a);
//	r_outer = rp_a+(rp_a-rr_a)+radius_ring_back;
//	r_mounts = r_outer+d_M3_screw/2;

	union() {
		if (helix_angle==0) {
			linear_extrude(height=face_width)
				annulus_shape (number_of_teeth, circular_pitch, radius_ring_back, clearance_a);

			annulus_mounts(
				r_large=r_mounts,
				d_mount=d_M3_screw+6,
				d_screw=d_M3_screw,
				h_mount=face_width,
				count=case_screws,
				fn=24);
		}
		else {
			linear_extrude(height=face_width/2, convexity=10, twist=-twist)
				annulus_shape (number_of_teeth, circular_pitch, radius_ring_back, clearance_a);

			annulus_mounts(r_mounts, d_M3_screw+6,d_M3_screw, face_width/2, case_screws);
		}
	}
}

module carrier_stage(
	rr_p,
	rp_s,
	rp_p,
	planets) {

	difference() {
		union() {
			for (i=[0:planets-1]) {
				rotate([0, 0, i*360/planets])
						hull() {
							cylinder(r=rr_p-1, h=t_pc);
				
							translate([rp_p+rp_s, 0, 0])
								cylinder(r=rr_p-1, h=t_pc);
						}
			}
			
			rotate_extrude(convexity=48)
				translate([rp_p+rp_s-t_pc/2, 0, 0])
					square(t_pc);
		}

		for (i=[0:planets-1]) {
			rotate([0, 0, i*360/planets])
				translate([rp_p+rp_s, 0, 0]) {
					translate([0, 0, t_pc-h_p_nut])
						rotate([0, 0, 30])
							cylinder(r=d_p_nut/2, h=h_p_nut+1, $fn=6);

					translate([0, 0, -1])
						cylinder(r=d_p_shaft/2, h=t_pc);
				}
		}
	}
}

module planetary_carrier(
	rr_p,
	rp_s,
	rp_p,
	planets) {

	difference() {
		union() {
			carrier_stage(
				rr_p=rr_p,
				rp_s=rp_s,
				rp_p=rp_p,
				planets=planets);

			cylinder(r=d_M8_nut/2+2, h=h_pc_collar);
		}
	
		translate([0, 0, -1])
			cylinder(r=d_M8_nut/2, h=h_M8_nut+3, $fn=6);

		translate([0, 0, h_M8_nut+2.25])
			cylinder(r=d_M8_screw/2, h=t_pc);
	
	}
}

module intermediate(
	circular_pitch,
	sun_teeth,
	sun_twist,
	sun_face_width,
	rr_p,
	rp_s,
	rp_p,
	planets) {

	ro_s = outer_radius(sun_teeth, circular_pitch);
	difference() {
		union() {
			carrier_stage(
				rr_p=rr_p,
				rp_s=rp_s,
				rp_p=rp_p,
				planets=planets);
		
			// made the intermediate gear thickness the same as the annulus so that the tip
			// of the gear hits the next carrier stage before the planetary gears hit the
			// the carrier stage preceding it.
			translate([0, 0, t_pc])
				if (helix_angle==0) {
					gear (
						circular_pitch=circular_pitch,
						gear_thickness = sun_face_width+1,
						rim_thickness = sun_face_width+1,
						hub_thickness = sun_face_width+1,
						number_of_teeth = sun_teeth,
						circles=0,
						bore_diameter=0,
						hub_diameter=0);
				}
				else {
					double_helical_gear (
						circular_pitch=circular_pitch,
						gear_thickness = sun_face_width,
						rim_thickness = sun_face_width,
						hub_thickness = sun_face_width,
						number_of_teeth = sun_teeth,
						circles=0,
						bore_diameter=0,
						hub_diameter=0,
						twist = sun_twist);
				}
		}

		// relief for previous stage sun gear
		translate([0, 0, -1])
			cylinder(r=ro_s+1, h=4);
	}
}

module annulus_mounts(
	r_large,
	d_mount,
	d_screw,
	h_mount,
	count,
	fn=24) {

	difference () {
		union() {
			translate([r_large+d_mount*2/3, 0, 0])
				rotate([0, 0, 90])
					linear_extrude(height=h_mount)
						equilateral(d_mount);

			for (i=[1:count-1]) {
				rotate([0, 0, i*360/count])
					translate([r_large, 0, 0])
						cylinder(r=d_mount/2, h=h_mount, $fn=fn);
			}
		}

		for (i=[0:count-1]) {
			rotate([0, 0, i*360/count])
				translate([r_large, 0, -1])
					cylinder(r=d_screw/2, h=h_mount+2, $fn=fn);
		}

	}
}

// spacer between the annulus and output end
module carrier_ring(
	r_outer,
	r_mounts,
	r_inner,
	thickness) {

	difference() {
		end_flange(r_outer, r_mounts, thickness, thickness=thickness);

		translate([0, 0, -1])
			cylinder(r=r_inner, h=thickness+2);
	}
}

// end flange blank
module end_flange(
	r_outer,
	r_mounts,
	thickness) {

	union() {
		cylinder(r=r_outer, h=thickness, $fn=96);

		annulus_mounts(r_mounts, d_M3_screw+6,d_M3_screw, thickness, case_screws);
	}
}

/* parallel mount holes for NEMA17 motor
	height=height of holes
	l_slot=length of slots for collor and mounts
	motor=array of motor dimensions:
		0:l_NEMA
		1:d_NEMA_collar
		2:d_NEMA_shaft
		3:d_NEMA_mounts
		4:cc_NEMA mounts
		5:c_d_NEMA mounts
		6:d_nut_mount
*/
module NEMA_parallel_holes(
	height,
	l_slot,
	motor)
	{

	// collar opening
	hull() {
		translate([l_slot/2, 0, 0])
			cylinder(r=motor[1]/2, h=height);

		translate([-l_slot/2, 0, 0])
			cylinder(r=motor[1]/2, h=height);
	}

	// mount hole openings
	for(i=[-1, 1]) {
		translate([motor[4]*i/2, motor[4]*i/2, 0])
			hull() {
				translate([l_slot/2, 0, 0])
					cylinder(r=motor[3]/2, h=height, $fn=48);
	
				translate([-l_slot/2, 0, 0])
					cylinder(r=motor[3]/2, h=height, $fn=48);
			}
	
		translate([motor[4]*i/2, -motor[4]*i/2, 0])
			hull() {
				translate([l_slot/2, 0, 0])
					cylinder(r=motor[3]/2, h=height, $fn=48);
	
				translate([-l_slot/2, 0, 0])
					cylinder(r=motor[3]/2, h=height, $fn=48);
			}
	}
}

/* pedestal for a NEMA motor
	height=total height of pedestal
	t_wall=thickness
	t_mounts=thickness of mountss from interface of motor to nut trap
	motor=array of NEMA motor dimensions:
		0:l_NEMA
		1:d_NEMA_collar
		2:d_NEMA_shaft
		3:d_NEMA_mounts
		4:cc_NEMA mounts
		5:c_d_NEMA mounts
		6:d_nut_mount
*/
module pedestal_NEMA(
	height,
	t_wall,
	t_mounts,
	motor) {

	washer_mount = motor[3]+4;

	difference() {
		// outer shape of pedestal
		hull() {
			for (i=[0:3]) {
				rotate([0, 0, i*90])
					translate([motor[5]+washer_mount/2, 0, 0])
						cylinder(r1=washer_mount/2+1, r2=washer_mount/2, h=height);
			}
		}

		// inner shape of pedestal
		translate([0 ,0, -t_wall])
			difference() {
				hull() {
					for (i=[0:3]) {
						rotate([0, 0, i*90])
							translate([motor[5]+washer_mount/2-t_wall, 0, 0])
								cylinder(r1=washer_mount/2+1, r2=washer_mount/2, h=height);
					}
				}

				translate([0, 0, height-t_mounts+t_wall])
					for (i=[0:3]) {
						rotate([0, 0, i*90])
							translate([motor[5], 0, 0])
								cylinder(r=washer_mount/2+1.5, h=t_mounts);
					}
			}

		// holes for motor mount
		translate([0, 0, -1])
			rotate([0, 0, 45])
				NEMA_parallel_holes(
					height=height+2,
					l_slot=0,
					motor=motor);
	}
}

/* end of the gearbox that the motor attaches to
	r_outer=outer radius of annulus
	r_mounts=radius of holes for gerabox screws
	motor=array of NEMA motor dimensions:
		0:l_NEMA
		1:d_NEMA_collar
		2:d_NEMA_shaft
		3:d_NEMA_mounts
		4:cc_NEMA mounts
		5:c_d_NEMA mounts
		6:d_nut_mount
*/
module end_motor(
	r_outer,
	r_mounts,
	motor) {

	washer_mount = motor[3]+4;
	t_mounts = 6;

	difference() {
		union() {
			end_flange(
				r_outer,
				r_mounts,
				thickness=t_case);

			rotate([0, 0, 45])
				pedestal_NEMA(
					height=height_motor_pedestal,
					t_wall=t_case,
					t_mounts=t_mounts,
					motor=motor);
		}

		// flange cutout to expose motor mount
		translate([0 ,0, -1])
			rotate([0, 0, 45])
				hull() {
					for (i=[0:3]) {
						rotate([0, 0, i*90])
							translate([motor[5]+washer_mount/2-t_case, 0, 0])
								cylinder(r=washer_mount/2, h=t_case+1.1);
					}
				}

		// hole to tighten grub screw
		translate([0, motor[0]/2+t_case, t_case+d_M3_screw/2])
			rotate([90, 0, 0])
				hull() {
					cylinder(r=d_M3_screw/2, h=t_case+2);

					translate([0, height_motor_pedestal-2*t_case-d_M3_screw, 0])
						cylinder(r=d_M3_screw/2, h=t_case+2);
				}
	}

	// add a floor for the motor collar
	translate([0, 0, height_motor_pedestal-t_case])
		cylinder(r=motor[1]/2+1, h=0.25);

	// add floors for the mount holes
	translate([-(motor[4]+washer_mount+t_case/2)/2, -(motor[0]+t_case/2)/2, height_motor_pedestal-t_mounts])
		cube([washer_mount+t_case/2, motor[0]+t_case/2, 0.25]);

	translate([(motor[4]-washer_mount-t_case/2)/2, -(motor[0]+t_case/2)/2, height_motor_pedestal-t_mounts])
		cube([washer_mount+t_case/2, motor[0]+t_case/2, 0.25]);
}

module end_output(
	r_outer,
	r_mounts,
	motor) {

	difference() {
		union() {
			end_flange(
				r_outer,
				r_mounts,
				thickness=t_case);

			rotate([0, 0, 45])
				pedestal_NEMA(
					height=height_output_mount,
					t_wall=t_case,
					t_mounts=height_output_mount,
					motor=motor);

			cylinder(r=motor[1]/2+2, h=height_output_mount);
		}

		// pocket for 608 bearing on case interior
		translate([0, 0, -1])
			cylinder(r=od_608/2, h=h_608+h_M8_washer+1);

		translate([0, 0, h_608+h_M8_washer+0.25])
			cylinder(r=d_M8_washer/2+1, h=height_output_mount);

		if (height_output_mount > 3*h_608) {
			// put a bearing pocket on case exterior
			translate([0, 0, height_output_mount-h_608-1])
				cylinder(r=od_608/2, h=h_608+2);
		}

		for(i=[0:3]) {
			rotate([0, 0, i*90+45])
				translate([motor[5], 0, -1])
					cylinder(r=motor[6]/2, h=height_output_mount-t_case+1, $fn=6);
		}
	}

	// add floors for mount holes
	for(i=[0:3]) {
		rotate([0, 0, i*90+45])
			translate([motor[5], 0, height_output_mount-t_case])
				cylinder(r=motor[6]/2+1, h=0.25);
	}
}

module input_half(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width,
	r_outer,
	r_mounts) {
	union() {

		if (helix_angle!=0) {
			translate([0, 0, 1+face_width/2])
				mirror([0, 0, 1])

					annulus(
						circular_pitch=circular_pitch,
						number_of_teeth=number_of_teeth,
						twist=twist,
						face_width=face_width,
						r_outer=r_outer,
						r_mounts=r_mounts);
		}
		else {
			translate([0, 0, 1])
				annulus(
					circular_pitch=circular_pitch,
					number_of_teeth=number_of_teeth,
					face_width=face_width,
					r_outer=r_outer,
					r_mounts=r_mounts);
		}

		carrier_ring(
			r_outer=r_outer,
			r_mounts=r_mounts,
			r_inner=root_radius(number_of_teeth, circular_pitch),
			thickness=1);
	}
}

module output_half(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width,
	r_outer,
	r_mounts) {

	if (helix_angle!=0) {
		union() {
			carrier_ring(
				r_outer=r_outer,
				r_mounts=r_mounts,
				r_inner=root_radius(number_of_teeth, circular_pitch),
				thickness=h_pc_collar);
			
			translate([0, 0, h_pc_collar])
					annulus(
						circular_pitch=circular_pitch,
						number_of_teeth=number_of_teeth,
						twist=twist,
						face_width=face_width,
						r_outer=r_outer,
						r_mounts=r_mounts);
		}
	}
	else {
		carrier_ring(
			r_outer,
			r_mounts,
			root_radius(number_of_teeth, circular_pitch),
			thickness=h_pc_collar);
	}
}

module intermediate_output_half(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width,
	r_outer,
	r_mounts) {

	if (helix_angle==0) {
		union() {
			carrier_ring(
				r_outer=r_outer,
				r_mounts=r_mounts,
				r_inner=root_radius(number_of_teeth, circular_pitch),
				thickness=t_pc/2);
	
				translate([0, 0, t_pc/2])
					annulus(
						circular_pitch=circular_pitch,
						number_of_teeth=number_of_teeth,
						face_width=face_width,
						r_outer=r_outer,
						r_mounts=r_mounts);
		}
	}
	else {
		union() {
			translate([0, 0, t_pc/2])
				annulus(
					circular_pitch=circular_pitch,
					number_of_teeth=number_of_teeth,
					twist=twist,
					face_width=face_width,
					r_outer=r_outer,
					r_mounts=r_mounts);
	
			carrier_ring(
				r_outer=r_outer,
				r_mounts=r_mounts,
				r_inner=root_radius(number_of_teeth, circular_pitch),
				thickness=t_pc/2);
		}
	}
}

module intermediate_input_half(
	circular_pitch,
	number_of_teeth,
	twist,
	face_width,
	r_outer,
	r_mounts) {

	if (helix_angle==0) {
		carrier_ring(
			r_outer=r_outer,
			r_mounts=r_mounts,
			r_inner=root_radius(number_of_teeth, circular_pitch),
			thickness=t_pc/2);
	}
	else {
		union() {
			translate([0, 0, t_pc/2+(planetary_face_width+2)/2])
				mirror([0, 0, 1])
					annulus(
						circular_pitch=circular_pitch,
						number_of_teeth=number_of_teeth,
						twist=twist,
						face_width=face_width,
						r_outer=r_outer,
						r_mounts=r_mounts);
	
				carrier_ring(
					r_outer=r_outer,
					r_mounts=r_mounts,
					r_inner=root_radius(number_of_teeth, circular_pitch),
					thickness=t_pc/2);
		}
	}
}

module planet_gear_plate(
	circular_pitch,
	number_of_teeth,
	face_width,
	twist,
	planets) {

	ro_p = outer_radius(number_of_teeth, circular_pitch);
	for (i=[0:planets-1])
		rotate([0, 0, i*360/planets])
			translate([ro_p+5, 0, 0])
				gear_planet(
					circular_pitch=circular_pitch,
					number_of_teeth=number_of_teeth,
					face_width=face_width,
					twist=twist);
}

module test_mesh(
	ns,
	np,
	na,
	circular_pitch,
	twist_s_mm,
	r_outer,
	r_mounts) {

	h_s_h_a = planetary_face_width+2;
	ro_a = outer_radius(na, circular_pitch);
	rp_a = pitch_radius(na, circular_pitch);
	rp_s = pitch_radius(ns, circular_pitch);
	rp_p = pitch_radius(np, circular_pitch);

	difference() {
		union() {
			annulus(
				circular_pitch=circular_pitch,
				number_of_teeth=na,
				twist=twist_s_mm*h_s_h_a*ns/na,
				face_width=h_s_h_a,
				r_outer=r_outer,
				r_mounts=r_mounts);
			
			translate([rp_a-rp_s, 0, 0])
				rotate([0, 0, -3])
					gear_sun(
					circular_pitch=circular_pitch,
					number_of_teeth=ns,
					twist=twist_s_mm*h_s_h_a,
					face_width=h_s_h_a,
					bore_diameter=0);
	
			translate([-rp_a+rp_p, 0, 1])
				rotate([0, 0, 360/np/2])
					gear_planet(
						circular_pitch=circular_pitch,
						number_of_teeth=np,
						face_width=planetary_face_width,
						twist=twist_s_mm*planetary_face_width*ns/np);
		}
		
		translate([-(ro_a+radius_ring_back), -(ro_a+radius_ring_back), h_s_h_a/2])
			cube([(ro_a+radius_ring_back)*2, (ro_a+radius_ring_back)*2, h_s_h_a*2]);
	}
}

module assembly(
	ns,
	np,
	na,
	circular_pitch,
	twist_s_mm,
	r_outer,
	r_mounts,
	planets,
	motor,
	z_section) {

	h_s_h_a = planetary_face_width+2;
	ro_a = outer_radius(na, circular_pitch);
	rp_a = pitch_radius(na, circular_pitch);
	rp_s = pitch_radius(ns, circular_pitch);
	rp_p = pitch_radius(np, circular_pitch);
	l_cube = r_mounts*2+20;

	difference() {
		union() {
			translate([0, 0, height_motor_pedestal]) {
				mirror([0, 0, 1])
					end_motor(
						r_outer=r_outer,
						r_mounts=r_mounts,
						motor=motor);
			
				input_half(
					circular_pitch=circular_pitch,
					number_of_teeth=na,
					twist=twist_s_mm*h_s_h_a*ns/na,
					face_width=planetary_face_width+2,
					r_outer=r_outer,
					r_mounts=r_mounts);
	
				translate([0, 0, 2])
					for (i=[0:planets-1])
						rotate([0, 0, i*360/planets])
							translate([-rp_a+rp_p, 0, 0])
								rotate([0, 0, 0])
									gear_planet(
										circular_pitch=circular_pitch,
										number_of_teeth=np,
										face_width=planetary_face_width,
										twist=twist_s_mm*planetary_face_width*ns/np);
	
				translate([0, 0, h_s_h_a+10-1-planetary_face_width+2])
					mirror([0, 0, 1])
						gear_sun(
							circular_pitch=circular_pitch,
							number_of_teeth=ns,
							twist=twist_s_mm*h_s_h_a,
							face_width=planetary_face_width+2);
	
			
				translate([0, 0, 1+planetary_face_width+2]) {
					planetary_carrier(
						rr_p=root_radius(np, circular_pitch),
						rp_s=pitch_radius(ns, circular_pitch),
						rp_p=pitch_radius(np, circular_pitch));
	
					translate([0, 0, h_pc_collar]) {
						rotate([180, 0, 0])
							output_half(
								circular_pitch=circular_pitch,
								number_of_teeth=na,
								twist=twist_s_mm*h_s_h_a*ns/na,
								face_width=planetary_face_width+2,
								r_outer=r_outer,
								r_mounts=r_mounts);
				
						translate([0, 0, 0])
							end_output(
								r_outer=r_outer,
								r_mounts=r_mounts,
								motor=motor);
					}
				}
			}
		}

		translate([-l_cube/2, -l_cube/2, z_section])
			cube([l_cube, l_cube, 100]);
	}
}
