/*
 * laser_parts.scad
 * Reusable models for common CO2 laser-machine parts.
 *
 * First model: adjustable 50-80 mm CO2 laser-tube holder matching the
 * common Yongli/Cloudray-style plastic bracket (Amazon ASIN B085WNT5KX).
 *
 * Published dimensions:
 *   width 118 mm; depth 66 mm; overall height 110-160 mm;
 *   tube diameter 50-80 mm; mounting-slot spacing 70 mm.
 * Dimensions not shown by the manufacturer are photo-derived approximations
 * and are exposed below where they are useful for fit/layout work.
 *
 * Coordinate convention:
 *   X = holder width, Y = laser-tube axis, Z = height above mounting surface.
 *
 * Example:
 *   use <laser_parts.scad>
 *   laser_tube_holder(tube_diameter=65, height=135, show_tube=true);
 */

$fn = 64;

LASER_HOLDER_WIDTH = 118;
LASER_HOLDER_DEPTH = 66;
LASER_HOLDER_MIN_HEIGHT = 110;
LASER_HOLDER_MAX_HEIGHT = 160;
LASER_HOLDER_MIN_TUBE_D = 50;
LASER_HOLDER_MAX_TUBE_D = 80;

// ---------------------------------------------------------------------------
// TEN-HIGH-style 50 W CO2 tube, 800 mm overall length and 50 mm jacket OD.
// Local Y is the optical axis. The output aperture is at +Y, matching the
// orientation used by laser_cutter.scad after its 90-degree Z rotation.

module _co2_y_cylinder(d=10,length=20,center=true,$fn=48) {
    rotate([90,0,0]) cylinder(d=d,h=length,center=center,$fn=$fn);
}

module _co2_glass_segment(a,b,d=4) {
    hull() {
        translate(a) sphere(d=d,$fn=24);
        translate(b) sphere(d=d,$fn=24);
    }
}

module _co2_torus_y(major_d=35,tube_d=3) {
    rotate([90,0,0]) rotate_extrude($fn=48)
        translate([major_d/2,0,0]) circle(d=tube_d,$fn=18);
}

module co2_laser_tube_50w(length=800,diameter=50,colors=true,
                          show_labels=true,show_wires=true) {
    glass=colors ? [0.72,0.91,1.00,0.30] : [0.80,0.80,0.80,0.35];
    glass_edge=colors ? [0.84,0.96,1.00,0.48] : [0.72,0.72,0.72,0.48];
    coolant=colors ? [0.35,0.74,0.92,0.17] : [0.60,0.60,0.60,0.16];
    metal=colors ? [0.63,0.65,0.66] : [0.55,0.55,0.55];
    body_length=length-116;
    body_end=body_length/2;
    neck_end=length/2-18;

    // Main water jacket with a visible wall and faint coolant volume.
    color(glass)
        difference() {
            _co2_y_cylinder(d=diameter,length=body_length);
            _co2_y_cylinder(d=diameter-3.2,length=body_length+2);
        }
    color(coolant) _co2_y_cylinder(d=diameter-5,length=body_length-8);

    // Central discharge capillary and the offset coolant return tube.
    color(glass_edge) {
        _co2_y_cylinder(d=10,length=length-64);
        translate([0,0,-13]) _co2_y_cylinder(d=4.2,length=body_length-20);
    }
    color([0.73,0.10,0.08,0.55])
        _co2_y_cylinder(d=3.2,length=length-95);

    // Photo-visible glass spacers supporting the bore inside the jacket.
    color(glass_edge)
        for (y=[-245,-80,95,255])
            translate([0,y,0]) _co2_torus_y(major_d=36,tube_d=2.4);

    // Helical-looking coolant return near the positive-electrode end. Closely
    // spaced glass loops communicate its form without expensive true threads.
    color(glass_edge)
        for (y=[body_end-105:9:body_end-28])
            translate([0,y,0]) _co2_torus_y(major_d=26,tube_d=3.0);

    // Tapered jacket shoulders and hand-formed end bulbs. Their extreme faces
    // remain exactly at +/- length/2 for reliable optical layout.
    color(glass) for (s=[-1,1]) {
        translate([0,s*(body_end+15),0])
            rotate([s<0 ? -90 : 90,0,0])
                cylinder(d1=diameter,d2=25,h=30,center=true,$fn=48);
        translate([0,s*(body_end+35),0])
            _co2_y_cylinder(d=28,length=24);
        translate([0,s*(body_end+49),0]) sphere(d=31,$fn=40);
        _co2_glass_segment([0,s*(body_end+47),0],
                           [0,s*neck_end,0],d=13);
    }

    // Metal electrode cups inside the terminal bulbs.
    color(metal)
        for (s=[-1,1])
            translate([0,s*(body_end+48),0])
                _co2_y_cylinder(d=17,length=7);

    // +Y is the beam-output end: clear aperture, short lens collar, and a
    // downward water outlet. The opposite end receives the HV terminal.
    color(glass_edge) {
        translate([0,length/2-9,0]) _co2_y_cylinder(d=15,length=18);
        translate([0,-length/2+10,0]) _co2_y_cylinder(d=13,length=20);
        _co2_glass_segment([0,length/2-42,-4],[0,length/2-30,-22],d=7);
        _co2_glass_segment([0,-length/2+48,-4],[0,-length/2+36,-22],d=7);
    }
    color([0.84,0.88,0.90])
        translate([0,length/2-2,0]) difference() {
            _co2_y_cylinder(d=21,length=4);
            _co2_y_cylinder(d=9,length=6);
        }
    color(metal) {
        translate([0,-length/2+13,0]) _co2_y_cylinder(d=8,length=14);
        translate([0,-length/2+8,0]) sphere(d=9,$fn=24);
    }

    // Simplified product labels wrapped as thin placards on the visible side.
    if (show_labels) {
        color([0.91,0.91,0.88]) {
            translate([0,205,diameter/2+0.6]) cube([28,104,1],center=true);
            translate([0,-210,diameter/2+0.6]) cube([30,95,1],center=true);
            translate([0,-25,diameter/2+0.6]) cube([32,82,1],center=true);
        }
        color([0.96,0.73,0.04])
            translate([0,-25,diameter/2+1.2]) cube([16,18,1],center=true);
        color([0.76,0.03,0.025])
            translate([0,205,diameter/2+1.2]) cube([7,34,1],center=true);
    }

    // Flexible visual electrode leads. They terminate close to the tube so
    // machine-level routing can later connect them to real insulated wiring.
    if (show_wires) {
        color([0.76,0.02,0.025]) {
            _co2_glass_segment([0,-length/2+18,-2],[10,-length/2+38,-18],d=2.4);
            _co2_glass_segment([10,-length/2+38,-18],[28,-length/2+68,-20],d=2.4);
        }
        color([0.025,0.025,0.028]) {
            _co2_glass_segment([0,length/2-28,-4],[-9,length/2-62,-18],d=2.2);
            _co2_glass_segment([-9,length/2-62,-18],[-25,length/2-95,-18],d=2.2);
        }
    }
}

// ---------------------------------------------------------------------------
// Active Aqua AAPA45L commercial air pump. Manufacturer-published unboxed
// envelope: 5.5 x 3.5 x 3.5 in (139.7 x 88.9 x 88.9 mm), excluding the
// detachable six-outlet manifold and flexible cord. Z=0 is the resting plane.

AAPA45L_BODY_ENVELOPE=[139.7,88.9,88.9];

module _aapa45l_barb(length=18,base_d=7,tip_d=4) {
    rotate([0,90,0]) {
        cylinder(d=base_d,h=4,$fn=24);
        translate([0,0,4]) cylinder(d1=base_d,d2=tip_d,h=length-4,$fn=24);
        for (z=[7:4:length-2])
            translate([0,0,z]) cylinder(d1=tip_d+2,d2=tip_d,h=1.5,$fn=24);
    }
}

module _aapa45l_rubber_foot() {
    color([0.045,0.047,0.05]) {
        cylinder(d1=18,d2=15,h=8,$fn=32);
        translate([0,0,7.5]) cylinder(d=8,h=5,$fn=24);
    }
}

module active_aqua_aapa45l(show_manifold=false,show_straight_connector=true,
                           connector_barb_d=8,show_cord=true,
                           colors=true) {
    overall=AAPA45L_BODY_ENVELOPE;
    body=[132,80,68];
    body_z=16;
    silver=colors ? [0.66,0.68,0.69] : [0.62,0.62,0.62];
    dark=colors ? [0.055,0.06,0.065] : [0.30,0.30,0.30];
    brass=colors ? [0.72,0.48,0.16] : [0.55,0.55,0.55];

    // Four vibration-isolating feet establish the published resting plane.
    for (x=[-overall[0]/2+18,overall[0]/2-18],
         y=[-overall[1]/2+15,overall[1]/2-15])
        translate([x,y,0]) _aapa45l_rubber_foot();

    // Cast aluminum compressor housing with rounded end caps.
    color(silver) {
        translate([0,0,body_z+body[2]/2])
            cube(body,center=true);
        for (x=[-body[0]/2,body[0]/2])
            translate([x,0,body_z+body[2]/2]) rotate([0,90,0])
                cylinder(d=body[1],h=7,center=true,$fn=48);

        // Longitudinal heat-dissipation fins on top and both side faces.
        for (y=[-body[1]/2+8:9:body[1]/2-8])
            translate([0,y,body_z+body[2]+3])
                cube([body[0]-10,2.2,6],center=true);
        for (side=[-1,1],z=[body_z+12:9:body_z+body[2]-10])
            translate([0,side*(body[1]/2+3),z])
                cube([body[0]-12,6,2.2],center=true);
    }

    // Black end covers, fasteners, label and top carry handle.
    color(dark) {
        for (x=[-body[0]/2-4,body[0]/2+4])
            translate([x,0,body_z+body[2]/2]) rotate([0,90,0])
                cylinder(d=body[1]-8,h=4,center=true,$fn=48);
        translate([0,0,body_z+body[2]+9])
            difference() {
                cube([64,13,17],center=true);
                translate([0,0,-2]) cube([43,17,11],center=true);
            }
    }
    color([0.82,0.83,0.84])
        for (x=[-body[0]/2-6,body[0]/2+6],a=[-35,35])
            translate([x,sin(a)*25,body_z+body[2]/2+cos(a)*25])
                rotate([0,90,0]) cylinder(d=5,h=2,center=true,$fn=20);
    color([0.91,0.91,0.87])
        translate([0,-body[1]/2-3,body_z+body[2]/2])
            cube([72,1,29],center=true);

    // Main threaded outlet and the supplied six-way brass/copper manifold.
    color(brass) {
        translate([body[0]/2+8,0,body_z+body[2]/2]) rotate([0,90,0])
            cylinder(d=18,h=16,center=true,$fn=32);
        if (show_manifold) {
            manifold_x=body[0]/2+33;
            translate([manifold_x,0,body_z+body[2]/2]) rotate([0,90,0])
                cylinder(d=12,h=44,center=true,$fn=28);
            translate([manifold_x+20,0,body_z+body[2]/2])
                rotate([90,0,0]) cylinder(d=10,h=66,center=true,$fn=28);
            for (y=[-27:10.8:27]) {
                translate([manifold_x+20,y,body_z+body[2]/2])
                    rotate([0,0,90]) _aapa45l_barb(length=15);
                translate([manifold_x+20,y,body_z+body[2]/2+10])
                    cylinder(d=8,h=10,$fn=24);
            }
        }
        else if (show_straight_connector) {
            // User-owned configuration: single straight hose adapter fitted
            // directly to the pump outlet instead of the six-way manifold.
            connector_x=body[0]/2+18;
            translate([connector_x,0,body_z+body[2]/2]) rotate([0,90,0])
                cylinder(d1=16,d2=12,h=14,center=true,$fn=28);
            translate([body[0]/2+25,0,body_z+body[2]/2])
                _aapa45l_barb(length=24,base_d=12,tip_d=connector_barb_d);
        }
    }

    // Molded cord gland and shortened visual 120 V cord with plug.
    if (show_cord) {
        color(dark)
            translate([-body[0]/2-7,-18,body_z+24]) rotate([0,90,0])
                cylinder(d=12,h=12,center=true,$fn=24);
        color([0.035,0.038,0.04]) {
            _co2_glass_segment([-body[0]/2-10,-18,body_z+24],
                               [-body[0]/2-35,-26,body_z+16],d=5);
            _co2_glass_segment([-body[0]/2-35,-26,body_z+16],
                               [-body[0]/2-60,-46,8],d=5);
            translate([-body[0]/2-65,-48,8]) cube([18,10,24],center=true);
        }
        color([0.72,0.73,0.74])
            for (y=[-51,-45])
                translate([-body[0]/2-76,y,12]) cube([8,1.5,5],center=true);
    }
}

// ---------------------------------------------------------------------------
// TAILONZ 2V025-08 two-position/two-way normally-closed air solenoid.
// User-owned version: 24 VDC coil and two 1/4-inch NPT ports.
// Product-image envelope is 1.17 x 2.2 in (29.7 x 55.9 mm); the unlisted
// depth is modeled from the standard 2V025-08 family envelope. Z=0 is the
// valve-body resting plane and flow runs from local -X (IN) to +X (OUT).

TAILONZ_2V025_08_ENVELOPE=[29.7,24,55.9];

module _tailonz_push_fitting_1_4(axis_sign=1,tube_d=8) {
    steel=[0.70,0.72,0.73];
    dark=[0.055,0.06,0.065];
    blue=[0.05,0.35,0.92];

    scale([axis_sign,1,1]) rotate([0,90,0]) {
        color(steel) {
            // Installed male thread, hex wrench body and tapered shoulder.
            cylinder(d=11.8,h=7,$fn=32);
            translate([0,0,7]) cylinder(d=15.5,h=8,$fn=6);
            translate([0,0,15]) cylinder(d1=13,d2=10.5,h=4,$fn=32);
        }
        color(dark)
            translate([0,0,19]) cylinder(d=12,h=4,$fn=32);
        color(blue)
            translate([0,0,22])
                difference() {
                    cylinder(d=12.5,h=3,$fn=32);
                    translate([0,0,-0.1]) cylinder(d=tube_d,h=3.2,$fn=24);
                }
    }
}

module tailonz_2v025_08_solenoid(show_fittings=true,show_wires=true,
                                 tube_d=8,colors=true) {
    body=[29.7,24,25];
    coil=[25.5,22,23.3];
    cap_d=27.9;
    cap_h=7.6;
    valve=colors ? [0.72,0.73,0.74] : [0.62,0.62,0.62];
    coil_color=colors ? [0.035,0.038,0.042] : [0.32,0.32,0.32];

    // Machined aluminum valve body and thin coil-retaining plate.
    color(valve) {
        translate([0,0,body[2]/2]) cube(body,center=true);
        translate([0,0,body[2]+1]) cube([31.5,25.5,2],center=true);
        // Shallow circular port bosses on the IN and OUT faces.
        for (sx=[-1,1])
            translate([sx*(body[0]/2+1.5),0,12.5]) rotate([0,90,0])
                cylinder(d=17,h=3,center=true,$fn=32);
    }

    // Encapsulated AC coil, center pole and scalloped manual-retainer cap.
    color(coil_color) {
        translate([0,0,body[2]+2+coil[2]/2]) cube(coil,center=true);
        translate([0,0,body[2]+2+coil[2]]) cylinder(d=22,h=2,$fn=40);
        translate([0,0,body[2]+4+coil[2]])
            cylinder(d=cap_d,h=cap_h,$fn=8);
        // Molded lead strain relief on the rear side of the coil.
        translate([0,coil[1]/2+2,body[2]+13])
            cube([11,6,10],center=true);
    }

    if (show_fittings)
        for (sx=[-1,1])
            translate([sx*body[0]/2,0,12.5])
                _tailonz_push_fitting_1_4(axis_sign=sx,tube_d=tube_d);

    if (show_wires) {
        wire_start=[0,coil[1]/2+5,body[2]+13];
        wire_end_y=66;
        color([0.78,0.02,0.025]) {
            _co2_glass_segment([wire_start[0]-2,wire_start[1],wire_start[2]],
                               [-5,40,42],d=1.7);
            _co2_glass_segment([-5,40,42],[-5,wire_end_y,37],d=1.7);
        }
        color([0.025,0.025,0.028]) {
            _co2_glass_segment([wire_start[0]+2,wire_start[1],wire_start[2]],
                               [5,40,39],d=1.7);
            _co2_glass_segment([5,40,39],[5,wire_end_y,34],d=1.7);
        }
        color([0.90,0.90,0.87])
            translate([0,wire_end_y+5,35.5]) cube([17,12,9],center=true);
    }
}

// ---------------------------------------------------------------------------
// CW-3000-style external CO2 laser water cooler shown by the user.
// Published pictured envelope: 270 W x 470 D x 370 H mm. Front faces -Y;
// rear coolant and electrical services face +Y. Z=0 is the resting plane.

CW3000_ENVELOPE=[270,470,370];

module _cw3000_louver_bank(rows=8,cols=3,slot=[34,3,9]) {
    for (r=[0:rows-1],c=[0:cols-1])
        translate([(c-(cols-1)/2)*47,0,(r-(rows-1)/2)*30])
            cube(slot,center=true);
}

module _cw3000_handle(width=88,depth=28,height=46,bar=13) {
    hull() {
        translate([-width/2+bar/2,0,bar/2]) cube([bar,depth,bar],center=true);
        translate([-width/2+bar/2,0,height-bar/2]) cube([bar,depth,bar],center=true);
    }
    hull() {
        translate([width/2-bar/2,0,bar/2]) cube([bar,depth,bar],center=true);
        translate([width/2-bar/2,0,height-bar/2]) cube([bar,depth,bar],center=true);
    }
    translate([0,0,height-bar/2]) cube([width,depth,bar],center=true);
}

module _cw3000_hose_port(label_color=[0.05,0.05,0.05]) {
    color([0.70,0.46,0.15]) {
        rotate([90,0,0]) cylinder(d=24,h=14,center=true,$fn=32);
        translate([0,8,0]) rotate([90,0,0])
            cylinder(d1=16,d2=11,h=24,center=true,$fn=28);
        for (y=[13,18,23])
            translate([0,y,0]) rotate([90,0,0])
                cylinder(d1=14,d2=11,h=2,$fn=24);
    }
}

module cw3000_water_cooler(show_rear_services=true,show_cord=true,
                           colors=true) {
    w=CW3000_ENVELOPE[0];
    d=CW3000_ENVELOPE[1];
    h=CW3000_ENVELOPE[2];
    shell=colors ? [0.78,0.79,0.78] : [0.68,0.68,0.68];
    edge=colors ? [0.54,0.56,0.56] : [0.48,0.48,0.48];
    dark=colors ? [0.045,0.05,0.055] : [0.28,0.28,0.28];

    // Rubber feet and sheet-metal cabinet.
    color(dark)
        for (x=[-w/2+24,w/2-24],y=[-d/2+30,d/2-30])
            translate([x,y,0]) cylinder(d=26,h=15,$fn=28);
    color(shell)
        translate([0,0,15+(h-15)/2]) cube([w,d,h-15],center=true);
    color(edge) {
        for (x=[-w/2,w/2])
            translate([x,0,h/2+7]) cube([4,d,h-15],center=true);
        for (y=[-d/2,d/2])
            translate([0,y,h/2+7]) cube([w,4,h-15],center=true);
        translate([0,0,h-5]) cube([w,d,10],center=true);
    }

    // Two folding-style carry handles on the top panel.
    color(dark)
        for (y=[-120,120])
            translate([0,y,h]) _cw3000_handle();

    // Front display, master rocker, status lamps and printed identification.
    front_y=-d/2-3;
    color(dark)
        translate([-35,front_y,255]) cube([94,10,57],center=true);
    color([0.08,0.10,0.11])
        translate([-35,front_y-6,255]) cube([78,2,39],center=true);
    color([0.55,0.035,0.025])
        translate([88,front_y-5,263]) cube([28,10,41],center=true);
    color([0.76,0.03,0.025])
        translate([-42,front_y-8,198]) rotate([90,0,0])
            cylinder(d=18,h=8,center=true,$fn=28);
    color([0.02,0.62,0.14])
        translate([36,front_y-8,198]) rotate([90,0,0])
            cylinder(d=18,h=8,center=true,$fn=28);
    color(dark) {
        translate([0,front_y-5,92])
            rotate([90,0,0]) linear_extrude(height=1)
                text("CW-3000",size=24,halign="center",valign="center");
        translate([0,front_y-5,53])
            rotate([90,0,0]) linear_extrude(height=1)
                text("WATER COOLER",size=15,halign="center",valign="center");
    }

    // Repeated punched louvers on both side panels and rear fan grille.
    color([0.36,0.38,0.39]) {
        for (side=[-1,1])
            translate([side*(w/2+2),0,185]) rotate([0,90,0])
                _cw3000_louver_bank(rows=8,cols=3,slot=[32,5,8]);
        translate([0,d/2+3,205]) rotate([90,0,0])
            difference() {
                cylinder(d=150,h=5,center=true,$fn=64);
                cylinder(d=132,h=7,center=true,$fn=64);
            }
        for (a=[0:30:330])
            translate([sin(a)*60,d/2+6,205+cos(a)*60])
                rotate([90,0,0]) cube([5,4,125],center=true);
    }

    if (show_rear_services) {
        // Clearly separated coolant supply/return ports, drain and alarm jack.
        translate([-62,d/2+8,92]) _cw3000_hose_port();
        translate([ 62,d/2+8,92]) _cw3000_hose_port();
        color([0.15,0.18,0.20])
            translate([-78,d/2+6,42]) rotate([90,0,0])
                cylinder(d=18,h=12,center=true,$fn=28);
        color(dark)
            translate([80,d/2+5,42]) cube([36,10,25],center=true);
    }

    if (show_cord) {
        color(dark) {
            translate([105,d/2+6,55]) rotate([90,0,0])
                cylinder(d=13,h=13,center=true,$fn=24);
            _co2_glass_segment([105,d/2+12,55],[122,d/2+40,35],d=6);
            _co2_glass_segment([122,d/2+40,35],[150,d/2+78,18],d=6);
            translate([154,d/2+84,18]) cube([20,12,28],center=true);
        }
    }
}

// Extrude a polygon drawn in the X/Z plane symmetrically along Y.
module _lp_xz_extrude(points, depth) {
    rotate([90, 0, 0])
        linear_extrude(height=depth, center=true, convexity=10)
            polygon(points=points);
}

module _lp_tube_cut(d, depth) {
    rotate([90, 0, 0]) cylinder(d=d, h=depth, center=true);
}

module _lp_capsule_slot(length, width, height) {
    hull()
        for (x=[-(length-width)/2, (length-width)/2])
            translate([x, 0, 0]) cylinder(d=width, h=height, center=true);
}

module _lp_knurled_knob(d=18, thickness=6, teeth=28) {
    union() {
        cylinder(d=d-1.2, h=thickness, center=true);
        for (a=[0:360/teeth:359])
            rotate([0, 0, a])
                translate([d/2-0.7, 0, 0])
                    cube([1.4, 1.2, thickness], center=true);
    }
}

module _lp_wing_nut(stem_d=7, hub_d=12, thickness=6) {
    union() {
        cylinder(d=hub_d, h=thickness, center=true);
        for (a=[-35, 35])
            rotate([0, 0, a])
                translate([hub_d/2+5, 0, 0])
                    hull() {
                        sphere(d=4);
                        translate([5, 0, 2]) sphere(d=5);
                    }
        difference() {
            cylinder(d=stem_d+4, h=thickness+2, center=true);
            cylinder(d=stem_d, h=thickness+4, center=true);
        }
    }
}

module _lp_base(width=118, depth=66, base_t=8, housing_h=28,
                housing_depth=24, slot_spacing=70) {
    difference() {
        union() {
            // Mounting foot and the hollow-looking adjustment housing.
            translate([0, 0, base_t/2]) cube([width, depth, base_t], center=true);
            translate([0, (depth-housing_depth)/2-7, base_t+housing_h/2])
                cube([width-6, housing_depth, housing_h], center=true);
            // Small end blocks visible behind the horizontal fixing screws.
            for (x=[-1,1])
                translate([x*(width/2-7), 4, base_t+9])
                    cube([12, 18, 18], center=true);
        }
        // Two elongated mounting slots, 70 mm center-to-center.
        for (x=[-slot_spacing/2, slot_spacing/2])
            translate([x, -depth/2+15, base_t/2])
                _lp_capsule_slot(24, 5.5, base_t+2);
        // Front windows expose the central lift adjuster.
        translate([0, -depth/2-0.1, base_t+housing_h/2])
            cube([30, housing_depth+2, 13], center=true);
    }

    // Side fixing knobs.
    for (x=[-1,1])
        translate([x*(width/2+1), 3, base_t+housing_h/2])
            rotate([0,90,0]) _lp_knurled_knob(d=17, thickness=6);
}

module _lp_lower_cradle(tube_d=65, tube_z=92, width=104, depth=22,
                        bottom_z=36, wall=12) {
    outer_r = tube_d/2 + wall;
    shoulder_x = width/2;
    difference() {
        _lp_xz_extrude([
            [-shoulder_x,bottom_z], [shoulder_x,bottom_z],
            [shoulder_x,tube_z+outer_r*.58], [outer_r*.82,tube_z+outer_r*.58],
            [outer_r*.55,tube_z-outer_r*.25], [0,bottom_z],
            [-outer_r*.55,tube_z-outer_r*.25], [-outer_r*.82,tube_z+outer_r*.58]
        ], depth);
        _lp_tube_cut(tube_d, depth+2);
    }
}

module _lp_top_cap(tube_d=65, tube_z=92, width=104, depth=20, wall=12,
                   screw_d=3.8) {
    outer_r = tube_d/2 + wall;
    cap_bottom = tube_z + tube_d/2 - 1;
    cap_top = tube_z + outer_r;
    difference() {
        _lp_xz_extrude([
            [-width/2,cap_bottom], [-width/2+12,cap_bottom],
            [-outer_r*.74,tube_z+outer_r*.62], [-outer_r*.28,cap_top],
            [outer_r*.28,cap_top], [outer_r*.74,tube_z+outer_r*.62],
            [width/2-12,cap_bottom], [width/2,cap_bottom],
            [width/2,cap_bottom+13], [outer_r*.84,tube_z+outer_r*.82],
            [outer_r*.32,cap_top+10], [-outer_r*.32,cap_top+10],
            [-outer_r*.84,tube_z+outer_r*.82], [-width/2,cap_bottom+13]
        ], depth);
        _lp_tube_cut(tube_d, depth+2);
        for (x=[-width/2+6,width/2-6])
            translate([x,0,cap_bottom+5]) cylinder(d=screw_d, h=35, center=true);
    }
}

module _lp_rubber_pads(tube_d=65, tube_z=92, depth=24) {
    r = tube_d/2;
    pad_w = 18;
    pad_t = 3;
    // Two lower pads follow the lower tangent approximately.
    for (a=[-48,48])
        translate([sin(a)*(r+pad_t/2), 0, tube_z-cos(a)*(r+pad_t/2)])
            rotate([0,a,0]) cube([pad_w, depth+1, pad_t], center=true);
    // One upper pad centered under the cap.
    translate([0,0,tube_z+r+pad_t/2])
        cube([25,depth+1,pad_t],center=true);
}

/*
 * Adjustable CO2 laser-tube support.
 *
 * tube_diameter : nominal tube OD, clamped to the published 50-80 mm range
 * height        : overall holder height, clamped to 110-160 mm
 * show_tube     : include a translucent reference cylinder (layout only)
 * show_hardware : include screws, knobs, and adjustment wheel
 * colors        : apply product-like display colors
 */
module laser_tube_holder(tube_diameter=65, height=135,
                         show_tube=false, show_hardware=true, colors=true) {
    tube_d = min(max(tube_diameter, LASER_HOLDER_MIN_TUBE_D),
                 LASER_HOLDER_MAX_TUBE_D);
    overall_h = min(max(height, LASER_HOLDER_MIN_HEIGHT),
                    LASER_HOLDER_MAX_HEIGHT);
    wall = 12;
    cap_extra = 10;
    tube_z = overall_h - (tube_d/2 + wall + cap_extra);
    cradle_bottom = 36;
    white = colors ? [0.90,0.91,0.89] : [0.8,0.8,0.8];
    blue = colors ? [0.02,0.25,0.78] : [0.55,0.55,0.55];
    metal = colors ? [0.38,0.40,0.41] : [0.5,0.5,0.5];

    color(white) {
        _lp_base();
        _lp_lower_cradle(tube_d=tube_d, tube_z=tube_z,
                          bottom_z=cradle_bottom, wall=wall);
        _lp_top_cap(tube_d=tube_d, tube_z=tube_z, wall=wall);
    }

    color(blue) _lp_rubber_pads(tube_d=tube_d, tube_z=tube_z);

    if (show_hardware) {
        // Central height screw and its front adjustment wheel.
        color(white)
            translate([0,-17,25]) rotate([90,0,0])
                _lp_knurled_knob(d=20,thickness=7);
        color(metal)
            translate([0,0,(cradle_bottom+18)/2])
                cylinder(d=10,h=cradle_bottom-18,center=true);

        // Two 3.8 mm clamp screws and wing nuts.
        for (x=[-46,46]) {
            color(metal)
                translate([x,0,(tube_z+tube_d/2+overall_h-4)/2])
                    cylinder(d=3.8,h=overall_h-4-(tube_z+tube_d/2),center=true);
            color(white)
                translate([x,0,overall_h-5])
                    _lp_wing_nut(stem_d=3.8);
        }
    }

    if (show_tube)
        color([0.65,0.88,1.0,0.30])
            rotate([90,0,0]) cylinder(d=tube_d,h=120,center=true);
}

// ---------------------------------------------------------------------------
// STARTNOW A-series 25 mm mirror mounts and 20 mm cutting head
// Amazon ASIN B09GK9318V. Outer dimensions are photo-derived approximations;
// optical interface sizes are the manufacturer's published dimensions.

STARTNOW_MIRROR_D = 25;
STARTNOW_LENS_D = 20;
STARTNOW_OWNED_FOCAL_LENGTH = 63.5;
STARTNOW_RED = [0.72, 0.035, 0.025];
STARTNOW_GOLD = [0.82, 0.55, 0.18];
STARTNOW_STEEL = [0.66, 0.68, 0.70];

module _sn_bored_plate(size=[62,8,62], bore=20, bore_z=31) {
    difference() {
        translate([0,0,size[2]/2]) cube(size,center=true);
        translate([0,0,bore_z]) rotate([90,0,0])
            cylinder(d=bore,h=size[1]+2,center=true);
    }
}

module _sn_adjuster(pos=[0,0,0], axis=[0,1,0], knob_d=10, length=14) {
    color(STARTNOW_STEEL)
        translate(pos) rotate([90,0,0]) cylinder(d=3.5,h=length,center=true);
    color(STARTNOW_GOLD)
        translate([pos[0],pos[1]-length/2-3,pos[2]])
            rotate([90,0,0]) _lp_knurled_knob(d=knob_d,thickness=6,teeth=24);
}

// A1: first mirror mount on an adjustable-height pedestal.
module startnow_first_mirror_mount(height=205, mirror_d=25, colors=true,
                                   head_yaw=0) {
    red = colors ? STARTNOW_RED : [0.65,0.65,0.65];
    base=[78,58,8];
    plate=[64,8,64];
    mirror_z=height-32;

    color(red) {
        difference() {
            translate([0,0,base[2]/2]) cube(base,center=true);
            for (x=[-24,24])
                translate([x,0,base[2]/2])
                    _lp_capsule_slot(22,5.5,base[2]+2);
        }
        translate([0,0,12]) cylinder(d=31,h=13);
        translate([0,0,19]) cylinder(d=25,h=max(10,mirror_z-51));
        translate([0,0,mirror_z-36]) cylinder(d=29,h=12);
        // The telescoping round post is also the yaw adjustment. Only the
        // upper crossbar/mirror head rotates; the slotted base remains square.
        rotate([0,0,head_yaw]) {
            translate([0,0,mirror_z-36]) cube([70,22,7],center=true);
            translate([0,0,mirror_z-32])
                _sn_bored_plate(size=plate,bore=mirror_d-3,bore_z=32);
            translate([0,5,mirror_z-32])
                rotate([90,0,0])
                    difference() {
                        cylinder(d=mirror_d+6,h=3,center=true);
                        cylinder(d=mirror_d-3,h=5,center=true);
                    }
        }
    }
    // Physical mirror surface centered on the optical bore datum.
    color([0.76,0.82,0.88])
        rotate([0,0,head_yaw])
            translate([0,1,mirror_z]) rotate([90,0,0])
                cylinder(d=mirror_d,h=1,center=true);
    rotate([0,0,head_yaw]) {
        for (p=[[-24,0,mirror_z-10],[24,0,mirror_z-10],[24,0,mirror_z+17]])
            _sn_adjuster(pos=p,knob_d=11);
        for (p=[[-20,0,mirror_z+14],[18,0,mirror_z-14]])
            color(STARTNOW_STEEL) translate(p) rotate([90,0,0])
                cylinder(d=5,h=15,center=true);
    }
}

// A2: second mirror mount with slotted XY-adjustable foot and upright plate.
module startnow_second_mirror_mount(mirror_d=25, colors=true) {
    red = colors ? STARTNOW_RED : [0.65,0.65,0.65];
    color(red) {
        difference() {
            translate([0,0,4]) cube([70,66,8],center=true);
            for (x=[-22,22])
                translate([x,0,4]) _lp_capsule_slot(20,6,10);
        }
        difference() {
            translate([0,0,13]) cube([62,54,10],center=true);
            for (x=[-18,18])
                translate([x,0,13]) rotate([90,0,0])
                    _lp_capsule_slot(22,5.5,56);
        }
        translate([0,17,18]) cube([64,8,10],center=true);
        translate([0,17,18])
            _sn_bored_plate(size=[60,8,62],bore=mirror_d-3,bore_z=33);
        translate([0,12,51]) rotate([90,0,0])
            difference() {
                cylinder(d=mirror_d+6,h=3,center=true);
                cylinder(d=mirror_d-3,h=5,center=true);
            }
    }
    for (p=[[-24,10,35],[24,10,35],[24,10,66]])
        _sn_adjuster(pos=p,knob_d=10);
    for (x=[-18,18])
        color(STARTNOW_STEEL) translate([x,-13,20]) cylinder(d=7,h=9);
}

module _sn_nozzle() {
    color(STARTNOW_RED) {
        cylinder(d=26,h=15);
        translate([0,0,-15]) cylinder(d1=5,d2=23,h=15);
    }
    // Simplified side air-assist elbow and blue push-fit collar.
    color([0.08,0.08,0.09]) {
        translate([17,0,7]) rotate([0,90,0]) cylinder(d=9,h=20,center=true);
        translate([27,0,12]) cylinder(d=10,h=15);
    }
    color([0.1,0.35,0.9]) translate([27,0,27]) cylinder(d=11,h=3);
}

// A3: third 25 mm mirror mount with a 20 mm lens barrel and air nozzle.
module startnow_laser_head(focal_length=STARTNOW_OWNED_FOCAL_LENGTH,
                           mirror_d=25, lens_d=20,
                           colors=true) {
    red = colors ? STARTNOW_RED : [0.65,0.65,0.65];
    barrel_h = focal_length + 32;
    color(red) {
        translate([0,0,0]) cylinder(d=31,h=barrel_h);
        translate([0,0,-8]) cylinder(d=38,h=12);
        translate([0,0,-15]) cylinder(d=33,h=10);
        // Square-to-axis mirror housing. The *internal mirror* is at 45
        // degrees; the external housing remains aligned with X/Y. The beam
        // enters through the lateral -X aperture and reflects down Z.
        translate([0,0,barrel_h])
            difference() {
                _lp_xz_extrude([[-30,0],[30,0],[30,28],[-30,58]],30);
                translate([-10,0,28]) rotate([0,90,0])
                    cylinder(d=mirror_d-3,h=80,center=true);
            }
        // Aperture collar makes the required entry direction explicit.
        translate([-34,0,barrel_h+28]) rotate([0,90,0])
            difference() {
                cylinder(d=mirror_d+6,h=10,center=true);
                cylinder(d=mirror_d-3,h=12,center=true);
            }
        translate([0,0,barrel_h+3])
            difference() {
                cube([65,44,7],center=true);
                cylinder(d=mirror_d-3,h=9,center=true);
            }
    }
    // Three gold adjusters on the sloping mirror plate.
    for (p=[[-20,-12,barrel_h+34],[18,-12,barrel_h+14],[18,-12,barrel_h+43]])
        _sn_adjuster(pos=p,knob_d=10,length=12);
    translate([0,0,-15]) _sn_nozzle();
}

// A4: connecting/carriage plate and removable belt fastener.
module startnow_connecting_plate(width=138, depth=66, thickness=6,
                                 head_hole_d=32, colors=true,
                                 show_belt_fastener=true,
                                 carriage_hole_pitch=[20,20]) {
    red = colors ? STARTNOW_RED : [0.65,0.65,0.65];
    head_x = -width/2 + 35;
    color(red)
        difference() {
            translate([0,0,thickness/2]) cube([width,depth,thickness],center=true);

            // Laser-head barrel opening and its four mounting holes.
            translate([head_x,0,thickness/2])
                cylinder(d=head_hole_d,h=thickness+2,center=true);
            for (x=[-16,16], y=[-16,16])
                translate([head_x+x,y,thickness/2])
                    cylinder(d=5,h=thickness+2,center=true);

            // Four MGN12H carriage screws.  The slots are centered on the
            // block's 20 x 20 mm M3 pattern and provide modest adjustment
            // along the plate's long axis.
            carriage_center_x=38;
            for (x=[carriage_center_x-carriage_hole_pitch[0]/2,
                    carriage_center_x+carriage_hole_pitch[0]/2],
                 y=[-carriage_hole_pitch[1]/2,carriage_hole_pitch[1]/2])
                translate([x,y,thickness/2])
                    _lp_capsule_slot(10,4.2,thickness+2);
        }

    if (show_belt_fastener) {
        clamp_x=38;
        clamp_y=depth/2-8;
        jaw_top_z=12;
        belt_thickness=1.4;
        belt_center_z=jaw_top_z+belt_thickness/2;
        cap_thickness=8;
        cap_center_z=jaw_top_z+belt_thickness+cap_thickness/2;

        // Fixed black jaw is seated on A4.  Its two bores are the threaded
        // receivers for the removable cap screws.
        color([0.06,0.06,0.065])
            translate([clamp_x,clamp_y,9])
                difference() {
                    cube([45,13,6],center=true);
                    for (x=[-15,15])
                        translate([x,0,0]) cylinder(d=3.4,h=8,center=true);
                }

        // The cap is assembled directly over the fixed jaw.  The 1.4 mm gap
        // between them is the actual GT2 belt thickness, not an exploded-view
        // display gap.
        color([0.06,0.06,0.065])
            translate([clamp_x,clamp_y,cap_center_z])
                difference() {
                    cube([50,14,cap_thickness],center=true);
                    for (x=[-15,15])
                        translate([x,0,0]) cylinder(d=4.3,h=cap_thickness+2,
                                                    center=true);
                }

        // Two socket-head screws pass through the cap and enter those jaw
        // bores.  There are deliberately no floating underside nuts.
        color(STARTNOW_STEEL)
            for (x=[23,53]) {
                translate([x,clamp_y,14]) cylinder(d=4,h=15,center=true);
                translate([x,clamp_y,22.4]) cylinder(d=7,h=4,center=true);
            }
    }
}

// Convenient display of the complete red A1/A2/A3/A4 set, not an optical layout.
module startnow_head_set_preview(spacing=115,
                                 focal_length=STARTNOW_OWNED_FOCAL_LENGTH,
                                 colors=true) {
    translate([-spacing,0,0])
        startnow_first_mirror_mount(colors=colors);
    startnow_second_mirror_mount(colors=colors);
    translate([spacing,0,30])
        startnow_laser_head(focal_length=focal_length,colors=colors);
    translate([0,-105,0])
        startnow_connecting_plate(colors=colors);
}

// ---------------------------------------------------------------------------
// Metric T-slot aluminum extrusion
// Nominal cross sections with 6 mm-series slots. Exact internal webs vary by
// manufacturer; slot_width and center_bore are exposed for matching stock.

ALUMINUM_CLEAR = [0.72,0.74,0.76];
ALUMINUM_BLACK = [0.08,0.085,0.09];

module _aluminum_extrusion_slot_2d(slot_width=6, cavity_width=11,
                                   cavity_depth=5, neck_depth=3) {
    // Slot opens toward +Y. Its cavity creates the familiar inverted T.
    union() {
        translate([-slot_width/2,-0.01])
            square([slot_width,neck_depth+0.02]);
        translate([-cavity_width/2,-cavity_depth])
            square([cavity_width,cavity_depth+0.01]);
    }
}

module _aluminum_2020_profile_2d(slot_width=6, cavity_width=11,
                                 center_bore=5) {
    // Dimensioned profile supplied from the user's existing extrusion model.
    // slot_width/cavity_width remain in the public API for compatibility;
    // this known stock uses a measured 5.26 mm opening geometry.
    difference() {
        square([20,20],center=true);
        square([17,17],center=true);
        square([40,5.26],center=true);
        rotate([0,0,90]) square([40,5.26],center=true);
    }

    difference() {
        union() {
            square([7.32,7.32],center=true);
            rotate([0,0,45]) square([1.5,25],center=true);
            rotate([0,0,-45]) square([1.5,25],center=true);
        }
        circle(d=center_bore,$fn=16);
    }

    for (x=[-7.9975,7.9975], y=[-7.9975,7.9975])
        translate([x,y]) square([4.005,4.005],center=true);
}

module _aluminum_2040_profile_2d(slot_width=6, cavity_width=11,
                                 center_bore=5) {
    union() {
        // A 2040 is two connected 20 mm cells. Their touching face lips and
        // webs merge into the central wall while retaining both core bores.
        for (x=[-10,10]) translate([x,0])
            _aluminum_2020_profile_2d(slot_width=slot_width,
                                      cavity_width=cavity_width,
                                      center_bore=center_bore);
    }
}

/*
 * 20 x 20 mm T-slot extrusion. Cross section is centered on X/Y; length is Z.
 * center=true places the midpoint at Z=0, otherwise the bottom is at Z=0.
 */
module aluminum_extrusion_2020(length=100, center=false, black=false,
                               slot_width=6, center_bore=5) {
    color(black ? ALUMINUM_BLACK : ALUMINUM_CLEAR)
        linear_extrude(height=length,center=center,convexity=10)
            _aluminum_2020_profile_2d(
                slot_width=slot_width,center_bore=center_bore);
}

/*
 * 20 x 40 mm T-slot extrusion. The 40 mm dimension follows X and length is Z.
 */
module aluminum_extrusion_2040(length=100, center=false, black=false,
                               slot_width=6, center_bore=5) {
    color(black ? ALUMINUM_BLACK : ALUMINUM_CLEAR)
        linear_extrude(height=length,center=center,convexity=10)
            _aluminum_2040_profile_2d(
                slot_width=slot_width,center_bore=center_bore);
}

// ---------------------------------------------------------------------------
// MGN12 miniature linear guide rail and C/H carriage blocks (HIWIN envelope).
// Coordinate convention: rail travel/length=X, rail width=Y, height=Z.

MGN12_RAIL_WIDTH = 12;
MGN12_RAIL_HEIGHT = 8;
MGN12_HOLE_PITCH = 25;
MGN12_ASSEMBLY_HEIGHT = 13;

// Adapter between an MGN12H carriage and the underside slot of a vertical
// 2040 gantry extrusion. The plate bottom is Z=0; default thickness is 6 mm.
// Four 4.2 mm clearance holes match the carriage's 20 x 20 mm M3 pattern.
// Two elongated M5 slots accept bolts/T-nuts in the gantry's bottom slot.
module mgn12h_2040_gantry_plate(size=[76,58], thickness=6,
                                carriage_pitch=[20,20],
                                gantry_bolt_spacing=52,
                                colors=true,show_hardware=true) {
    plate_color=colors ? [0.68,0.10,0.07] : [0.65,0.65,0.65];
    color(plate_color)
        difference() {
            translate([0,0,thickness/2])
                cube([size[0],size[1],thickness],center=true);

            // MGN12H carriage clearance holes and shallow cap recesses.
            for (x=[-carriage_pitch[0]/2,carriage_pitch[0]/2],
                 y=[-carriage_pitch[1]/2,carriage_pitch[1]/2]) {
                translate([x,y,thickness/2])
                    cylinder(d=4.2,h=thickness+2,center=true);
                translate([x,y,thickness-1])
                    cylinder(d=7,h=2.2,center=true);
            }

            // Adjustment along X while fastening into the 2040 bottom slot.
            for (x=[-gantry_bolt_spacing/2,gantry_bolt_spacing/2])
                translate([x,0,thickness/2])
                    _lp_capsule_slot(12,5.5,thickness+2);
        }

    // Visible hardware distinguishes the two independent bolt patterns.
    if (show_hardware)
        color([0.72,0.73,0.74]) {
            for (x=[-carriage_pitch[0]/2,carriage_pitch[0]/2],
                 y=[-carriage_pitch[1]/2,carriage_pitch[1]/2])
                translate([x,y,thickness+0.7])
                    cylinder(d=6.5,h=1.4,center=true,$fn=24);
            for (x=[-gantry_bolt_spacing/2,gantry_bolt_spacing/2])
                translate([x,0,thickness+2]) {
                    cylinder(d=9,h=4,center=true,$fn=24);
                    translate([0,0,2.2]) cylinder(d=4.8,h=2,center=true);
                }
        }
}

// Flat 6 mm side plate joining the X-axis NEMA 17 to the 2040 gantry.
// Fabrication coordinates: X=plate width, Y=plate height, Z=thickness.
// The motor shaft is at [0,0]; the two lower slots accept M5 screws/T-nuts in
// the longitudinal side slot of the 2040.  In the cutter assembly this flat
// part is rotated upright against the electronics-facing gantry side.
module x_axis_nema17_2040_motor_mount(size=[90,80], thickness=6,
                                     motor_pitch=31,
                                     gantry_slot_y=-38,
                                     plate_center_x=-25,
                                     gantry_bolt_x=[-50,-20],
                                     colors=true,show_hardware=true) {
    plate_color=colors ? [0.68,0.10,0.07] : [0.65,0.65,0.65];
    color(plate_color)
        difference() {
            translate([plate_center_x,0,thickness/2])
                cube([size[0],size[1],thickness],center=true);

            // NEMA 17 pilot and four M3 face fasteners.
            translate([0,0,thickness/2])
                cylinder(d=23,h=thickness+2,center=true);
            for (x=[-motor_pitch/2,motor_pitch/2],
                 y=[-motor_pitch/2,motor_pitch/2])
                translate([x,y,thickness/2])
                    cylinder(d=3.6,h=thickness+2,center=true);

            // Two horizontally adjustable M5/T-nut joints sit inward of the
            // gantry end, so neither fastener lands beyond the extrusion.
            for (x=gantry_bolt_x)
                translate([x,gantry_slot_y,thickness/2])
                    _lp_capsule_slot(10,5.5,thickness+2);
        }

    if (show_hardware)
        color(STARTNOW_STEEL) {
            for (x=[-motor_pitch/2,motor_pitch/2],
                 y=[-motor_pitch/2,motor_pitch/2])
                translate([x,y,thickness+1.4]) {
                    cylinder(d=6,h=2.8,center=true);
                    translate([0,0,-2.2]) cylinder(d=3,h=4,center=true);
                }
            for (x=gantry_bolt_x)
                translate([x,gantry_slot_y,thickness+2]) {
                    cylinder(d=9,h=4,center=true,$fn=24);
                    translate([0,0,-3]) cylinder(d=5,h=6,center=true);
                }
        }
}

// ---------------------------------------------------------------------------
// Printable enclosure hardware. Dimensions are deliberately parameterized so
// pin, screw and running clearances can be tuned after a calibration print.

module enclosure_hinge_leaf(width=42, leaf_depth=22, thickness=5,
                            pin_d=4, pin_clearance=0.35,
                            screw_d=5.2, moving=false) {
    knuckle_od=max(thickness*2.4,pin_d+4.5);
    segment=width/5;
    difference() {
        union() {
            // Leaf edge is tangent to the knuckle and includes two M5 slots.
            translate([0,leaf_depth/2,thickness/2])
                cube([width,leaf_depth,thickness],center=true);
            for (i=moving ? [1,3] : [0,2,4])
                translate([-width/2+(i+0.5)*segment,0,knuckle_od/2])
                    rotate([0,90,0])
                        cylinder(d=knuckle_od,h=segment-0.6,center=true,$fn=36);
        }
        // Continuous pin bore through every printed knuckle.
        translate([0,0,knuckle_od/2]) rotate([0,90,0])
            cylinder(d=pin_d+pin_clearance,h=width+2,center=true,$fn=28);
        for (x=[-width/2+10,width/2-10])
            translate([x,leaf_depth*0.58,thickness/2])
                hull()
                    for (y=[-2.5,2.5])
                        translate([0,y,0]) cylinder(d=screw_d,h=thickness+2,
                                                   center=true,$fn=24);
    }
}

module enclosure_hinge_assembly(width=42, leaf_depth=22, thickness=5,
                                pin_d=4, open_angle=0,
                                show_pin=true, colors=true) {
    dark=colors ? [0.055,0.06,0.065] : [0.55,0.55,0.55];
    color(dark)
        enclosure_hinge_leaf(width=width,leaf_depth=leaf_depth,
                             thickness=thickness,pin_d=pin_d,moving=false);
    color(dark)
        rotate([open_angle,0,0]) mirror([0,1,0])
            enclosure_hinge_leaf(width=width,leaf_depth=leaf_depth,
                                 thickness=thickness,pin_d=pin_d,moving=true);
    if (show_pin)
        color([0.68,0.69,0.70])
            translate([0,0,max(thickness*2.4,pin_d+4.5)/2])
                rotate([0,90,0]) cylinder(d=pin_d,h=width+4,center=true,$fn=28);
}

module enclosure_cam_latch_base(size=[34,28,5], screw_d=5.2,
                                pivot_d=4.4) {
    difference() {
        translate([0,size[1]/2,size[2]/2]) cube(size,center=true);
        // Base is printed on its broad face; holes accept M5 mounting screws.
        for (x=[-size[0]/2+7,size[0]/2-7])
            translate([x,7,size[2]/2])
                cylinder(d=screw_d,h=size[2]+2,center=true,$fn=24);
        translate([0,size[1]-7,size[2]/2])
            cylinder(d=pivot_d,h=size[2]+2,center=true,$fn=24);
    }
}

// Lever includes an eccentric nose. Rotating it approximately 90 degrees
// pulls the panel against the gasket; the M4 pivot remains separate hardware.
module enclosure_cam_latch_lever(length=42, width=13, thickness=6,
                                 pivot_d=4.4) {
    difference() {
        union() {
            hull() {
                cylinder(d=width,h=thickness,$fn=32);
                translate([0,length-width/2,0])
                    cylinder(d=width,h=thickness,$fn=32);
            }
            translate([width/2-1,-3,0])
                cube([7,12,thickness],center=false);
        }
        translate([0,0,-1]) cylinder(d=pivot_d,h=thickness+2,$fn=24);
    }
}

module enclosure_cam_latch_keeper(size=[28,12,8], screw_d=5.2) {
    difference() {
        cube(size,center=true);
        translate([0,0,1.5]) cube([12,size[1]+2,5],center=true);
        for (x=[-size[0]/2+5,size[0]/2-5])
            translate([x,0,0]) rotate([90,0,0])
                cylinder(d=screw_d,h=size[1]+2,center=true,$fn=24);
    }
}

module enclosure_cam_latch_assembly(angle=0, colors=true,
                                    show_hardware=true) {
    dark=colors ? [0.055,0.06,0.065] : [0.55,0.55,0.55];
    color(dark) enclosure_cam_latch_base();
    color(dark)
        translate([0,6,21]) rotate([90,0,angle])
            enclosure_cam_latch_lever();
    color(dark) translate([0,20,-7]) enclosure_cam_latch_keeper();
    if (show_hardware)
        color([0.68,0.69,0.70])
            translate([0,3.2,21]) rotate([90,0,0])
                cylinder(d=4,h=8,center=true,$fn=24);
}

// Visual 20-tooth GT2 drive pulley for a 5 mm motor shaft.  The toothed core
// is 12.2 mm pitch diameter with 16 mm retaining flanges and a 7 mm belt face.
module gt2_pulley_20t(axis="z",belt_width=7,bore=5,colors=true) {
    pulley_color=colors ? [0.10,0.10,0.11] : [0.55,0.55,0.55];
    module _pulley_z() {
        color(pulley_color)
            difference() {
                union() {
                    translate([0,0,-belt_width/2-0.6])
                        cylinder(d=16,h=1.2,center=true);
                    translate([0,0,belt_width/2+0.6])
                        cylinder(d=16,h=1.2,center=true);
                    translate([0,0,0])
                        cylinder(d=12.2,h=belt_width+1.2,center=true,$fn=40);
                    for (a=[0:18:342])
                        rotate([0,0,a])
                            translate([6.35,0,0])
                                cube([0.8,1.2,belt_width],center=true);
                }
                translate([0,0,0])
                    cylinder(d=bore,h=belt_width+4,center=true);
            }
    }
    if (axis=="x") rotate([0,90,0]) _pulley_z();
    else if (axis=="y") rotate([90,0,0]) _pulley_z();
    else _pulley_z();
}

// Two-hole 3/8-16 adjustable leveling foot set, Amazon ASIN B08VRPCDNL.
// Coordinate convention: the mounting-flange top is Z=0 and the complete
// foot extends downward.  This lets the socket point down beneath a metal
// frame rather than requiring its 27 mm collar to pass through an extrusion.
// `adjustment` is the exposed stud length below the socket (0..22.86 mm).
module leveling_foot_3_8_16(adjustment=12,
                            show_mount_screws=true,
                            mount_hole_half_spacing=12.2,
                            colors=true) {
    flange_w=35.56;          // 1.4 in
    flange_d=20;
    flange_t=2.5;            // supplied flange / optional felt-pad thickness
    socket_d=12.7;           // 1/2 in
    socket_h=26.99;          // 1-1/16 in overall insert height
    stud_d=9.525;            // 3/8-16 UNC
    thread_pitch=25.4/16;
    exposed=max(0,min(22.86,adjustment));
    nut_h=6.86;              // 0.27 in
    nut_af=14.3;             // nominal 9/16 in wrench size
    foot_d=35.56;            // 1.4 in
    foot_h=12.7;             // 0.5 in including glide
    glide_h=2.54;            // 0.1 in
    hole_x=mount_hole_half_spacing;

    metal=colors ? [0.68,0.69,0.70] : [0.62,0.62,0.62];
    foot_metal=colors ? [0.60,0.54,0.45] : [0.58,0.58,0.58];
    glide=colors ? [0.92,0.93,0.94] : [0.75,0.75,0.75];

    // Two-lobed mounting flange with actual screw clearances.
    color(metal)
        difference() {
            translate([0,0,-flange_t/2])
                hull() {
                    for (x=[-flange_w/2+5,flange_w/2-5])
                        translate([x,0,0]) cylinder(d=10,h=flange_t,center=true);
                    cube([flange_w-10,flange_d,flange_t],center=true);
                }
            for (x=[-hole_x,hole_x])
                translate([x,0,-flange_t/2])
                    cylinder(d=4.5,h=flange_t+2,center=true);
        }

    // Threaded socket/collar points downward from the mounting plate.
    color(metal)
        translate([0,0,-flange_t-(socket_h-flange_t)/2])
            difference() {
                cylinder(d=socket_d,h=socket_h-flange_t,center=true,$fn=48);
                cylinder(d=stud_d-1.2,h=socket_h-flange_t+2,center=true,$fn=40);
            }

    nut_top_z=-socket_h-exposed;
    foot_top_z=nut_top_z-nut_h;
    stud_bottom_z=foot_top_z-2;
    stud_top_z=-8;

    // Threaded shaft: core plus 16-TPI crest rings for readable previews.
    color(metal) {
        translate([0,0,(stud_top_z+stud_bottom_z)/2])
            cylinder(d=stud_d-1.1,h=stud_top_z-stud_bottom_z,center=true,$fn=36);
        for (z=[stud_bottom_z:thread_pitch:stud_top_z])
            translate([0,0,z]) cylinder(d=stud_d,h=0.55,center=true,$fn=36);
        translate([0,0,nut_top_z-nut_h/2])
            cylinder(d=nut_af/cos(30),h=nut_h,center=true,$fn=6);
    }

    // Stamped metal leveling pad with a separate non-marring lower glide.
    color(foot_metal)
        translate([0,0,foot_top_z-(foot_h-glide_h)/2])
            union() {
                cylinder(d=foot_d,h=foot_h-glide_h-2,center=true,$fn=64);
                translate([0,0,(foot_h-glide_h-2)/2])
                    cylinder(d1=foot_d-3,d2=foot_d-8,h=2,center=true,$fn=64);
            }
    color(glide)
        translate([0,0,foot_top_z-foot_h+glide_h/2])
            cylinder(d=foot_d-1,h=glide_h,center=true,$fn=64);

    if (show_mount_screws)
        color([0.72,0.73,0.74])
            for (x=[-hole_x,hole_x])
                translate([x,0,0.7]) cylinder(d=7,h=1.4,center=true,$fn=32);
}

// 60 x 60 x 4 mm five-hole 2020 corner gusset, Amazon ASIN B08PKFYPF2.
// The local right-angle corner is [0,0].  The diagonal runs from [20,60]
// to [60,20], and the five nominal M5 clearances are on a 20 mm grid.
module corner_gusset_2020_60(show_frame_screws=true, colors=true) {
    thickness=4;
    holes=[[10,10],[30,10],[50,10],[10,30],[10,50]];
    frame_holes=[[10,10],[50,10],[10,50]];
    aluminum=colors ? [0.76,0.77,0.78] : [0.66,0.66,0.66];
    hardware=colors ? [0.58,0.59,0.60] : [0.56,0.56,0.56];

    color(aluminum)
        difference() {
            linear_extrude(height=thickness,center=true)
                polygon([[0,0],[60,0],[60,20],[20,60],[0,60]]);
            for (p=holes)
                translate([p[0],p[1],0])
                    cylinder(d=5,h=thickness+2,center=true,$fn=28);
        }

    // These three fasteners tie the plate to the two perpendicular lower
    // extrusions.  The remaining diagonal pair belongs to the foot socket.
    if (show_frame_screws)
        color(hardware)
            for (p=frame_holes)
                translate([p[0],p[1],thickness/2+1.1])
                    cylinder(d1=8,d2=5.5,h=2.2,center=true,$fn=32);
}

module _mgn12_rounded_block(size=[10,10,10], radius=1) {
    hull()
        for (x=[-size[0]/2+radius,size[0]/2-radius],
             y=[-size[1]/2+radius,size[1]/2-radius])
            translate([x,y,0]) cylinder(r=radius,h=size[2]);
}

/*
 * MGN12 rail. Specify either hole_count or allow it to be derived from length.
 * end_offset defaults to an equalized layout; set it explicitly to match a
 * purchased rail. Mounting holes are 3.5 mm through with 6 mm counterbores.
 */
module mgn12_rail(length=300, hole_pitch=25, end_offset=undef,
                  hole_count=undef, center=true, colors=true) {
    n = is_undef(hole_count) ? max(1,floor((length-10)/hole_pitch)+1)
                             : max(1,hole_count);
    e = is_undef(end_offset) ? (length-(n-1)*hole_pitch)/2 : end_offset;
    x0 = center ? -length/2 : 0;
    steel = colors ? [0.68,0.70,0.72] : [0.65,0.65,0.65];

    color(steel)
        difference() {
            translate([x0,0,0])
                linear_extrude(height=MGN12_RAIL_HEIGHT)
                    polygon(points=[
                        [0,-5.0],[0,5.0],
                        [1.3,6],[length-1.3,6],[length,5.0],
                        [length,-5.0],[length-1.3,-6],[1.3,-6]
                    ]);

            for (i=[0:n-1]) {
                x = x0 + e + i*hole_pitch;
                translate([x,0,-0.1]) cylinder(d=3.5,h=MGN12_RAIL_HEIGHT+0.2);
                translate([x,0,4.5]) cylinder(d=6,h=MGN12_RAIL_HEIGHT-4.4);
            }

            // Shallow side race reliefs visible below the carriage.
            for (y=[-1,1])
                translate([x0-0.1,y*6,4.0]) rotate([0,90,0])
                    cylinder(d=2.1,h=length+0.2,$fn=24);
        }
}

/*
 * MGN12 carriage block: type="C" (34.7 mm) or type="H" (45.4 mm).
 * Position the block with its rail interface at Z=0; on mgn12_rail(), both
 * modules share the same origin and the combined top surface is Z=13 mm.
 */
module mgn12_carriage(type="H", colors=true, show_balls=false) {
    is_long = type == "H" || type == "h";
    length = is_long ? 45.4 : 34.7;
    hole_pitch_x = is_long ? 20 : 15;
    width = 27;
    top_z = 13;
    body = colors ? [0.68,0.70,0.72] : [0.62,0.62,0.62];
    seal = colors ? [0.10,0.11,0.12] : [0.35,0.35,0.35];

    color(body)
        difference() {
            union() {
                translate([0,0,3]) _mgn12_rounded_block([length-5,width,10],1.2);
                translate([0,0,5]) _mgn12_rounded_block([length,width-4,8],1.0);
            }
            // Underside channel wraps around the 12 mm rail.
            translate([0,0,4]) cube([length+2,12.4,8.2],center=true);
            // Four M3 threaded mounting holes, represented at tap diameter.
            for (x=[-hole_pitch_x/2,hole_pitch_x/2], y=[-10,10])
                translate([x,y,top_z-3.6]) cylinder(d=2.5,h=4);
            // Lubrication port centered in each end seal.
            for (x=[-length/2-0.1,length/2+0.1])
                translate([x,0,9]) rotate([0,90,0]) cylinder(d=2,h=3,center=true);
        }

    // Polymer end seals and stainless end plates.
    for (x=[-length/2+1.2,length/2-1.2]) {
        color(seal)
            translate([x,0,4.5])
                difference() {
                    cube([2.4,width-4,8.5],center=true);
                    cube([3,12.4,5.5],center=true);
                }
        color([0.82,0.83,0.84])
            translate([x+(x<0?-1.25:1.25),0,5])
                difference() {
                    cube([0.7,width-5,7],center=true);
                    cube([1.2,12.3,5],center=true);
                }
    }

    if (show_balls)
        color([0.78,0.79,0.80])
            for (x=[-length/2+5:3:length/2-5], y=[-7.1,7.1])
                translate([x,y,5.2]) sphere(d=2.35,$fn=16);
}

// Rail with one or more carriages. positions are offsets along the rail X axis.
module mgn12_assembly(length=300, carriage_type="H", positions=[0],
                      center=true, colors=true) {
    mgn12_rail(length=length,center=center,colors=colors);
    x0 = center ? 0 : length/2;
    for (position=positions)
        translate([x0+position,0,0])
            mgn12_carriage(type=carriage_type,colors=colors);
}

// ---------------------------------------------------------------------------
// VEVOR 50 W CO2 laser power supply, SKU KGDY50W0000000001V1.
// X=140 mm (5.5 in), Y=178 mm (7 in), Z=76 mm (3 in).

VEVOR_PSU_50W_SIZE = [139.7,177.8,76.2];

module _psu_cable_segment(a,b,d=6) {
    hull() {
        translate(a) sphere(d=d,$fn=20);
        translate(b) sphere(d=d,$fn=20);
    }
}

module _psu_terminal_block(width=27,poles=4) {
    green=[0.16,0.52,0.25];
    color(green)
        difference() {
            cube([width,13,22],center=true);
            for (i=[0:poles-1]) {
                x=(i-(poles-1)/2)*(width/poles);
                translate([x,-7,4]) rotate([90,0,0])
                    cylinder(d=3.2,h=4,center=true);
                translate([x,-7,-5]) cube([4.5,4,5],center=true);
            }
        }
}

/*
 * VEVOR 50 W supply. The electrical terminals face -Y and the fan faces -X.
 * show_cable adds a shortened layout representation of the supplied HV lead;
 * cable_length is visual only and is not routed to its full supplied 800 mm.
 */
module vevor_laser_power_supply_50w(show_cable=true,cable_length=180,
                                    colors=true) {
    w=VEVOR_PSU_50W_SIZE[0];
    d=VEVOR_PSU_50W_SIZE[1];
    h=VEVOR_PSU_50W_SIZE[2];
    blue=colors ? [0.00,0.43,0.70] : [0.62,0.62,0.62];
    dark=[0.035,0.055,0.05];

    // Folded sheet-metal enclosure with terminal-end opening and mount notches.
    color(blue)
        difference() {
            translate([0,0,h/2]) cube([w,d,h],center=true);
            translate([0,-d/2-0.1,h/2]) cube([w-14,5,h-13],center=true);
            // Four mounting notches in the projecting top flange.
            for (x=[-w/2+8,w/2-8], y=[-d/2+5,d/2-5])
                translate([x,y,h-1]) cylinder(d=7,h=4,center=true);
            // Rear vertical ventilation slots.
            for (x=[-54:7:54])
                translate([x,d/2+0.1,24]) cube([3,4,34],center=true);
            // Voltage-selector window on the right wall.
            translate([w/2+0.1,-25,48]) cube([4,18,11],center=true);
        }

    // Top pressed stiffening rectangles and case screws.
    color([0.02,0.34,0.59])
        for (y=[-35,30])
            translate([0,y,h+0.4])
                difference() {
                    cube([52,31,1.2],center=true);
                    cube([43,22,2],center=true);
                }
    color([0.75,0.77,0.78])
        for (x=[-50,50], y=[-62,62])
            translate([x,y,h+0.7]) cylinder(d=5,h=1.5,center=true);

    // Fan and square guard grid on the left side.
    color(dark)
        translate([-w/2-0.6,12,39]) rotate([0,90,0]) cylinder(d=52,h=1.5);
    color(blue) {
        for (y=[-13:7:37])
            translate([-w/2-1.5,y,39]) cube([2,3,56],center=true);
        for (z=[15:7:64])
            translate([-w/2-1.6,12,z]) cube([2,56,3],center=true);
    }
    color([0.82,0.83,0.84])
        for (y=[-13,37],z=[16,62])
            translate([-w/2-2,y,z]) rotate([0,90,0]) cylinder(d=5,h=2);

    // Controller PCB and three pluggable terminal blocks.
    color([0.02,0.20,0.10])
        translate([0,-d/2-1,h/2]) cube([w-20,2,h-15],center=true);
    translate([-43,-d/2-8,48]) _psu_terminal_block(width=30,poles=4);
    translate([-8,-d/2-8,48]) _psu_terminal_block(width=31,poles=5);
    translate([36,-d/2-8,30]) _psu_terminal_block(width=29,poles=4);

    // 110/220 V selector, shown in the side aperture.
    color([0.05,0.05,0.055]) translate([w/2+1,-25,48]) cube([2,16,10],center=true);
    color([0.75,0.04,0.03]) translate([w/2+2,-25,48]) cube([2,8,7],center=true);

    if (show_cable) {
        // Compact S-curve standing in for the supplied 800 mm silicone HV lead.
        color([0.78,0.015,0.035]) {
            _psu_cable_segment([35,d/2,48],[45,d/2+28,55]);
            _psu_cable_segment([45,d/2+28,55],[15,d/2+48,62]);
            _psu_cable_segment([15,d/2+48,62],[-25,d/2+35,55]);
            _psu_cable_segment([-25,d/2+35,55],[-35,d/2+10,38]);
            _psu_cable_segment([-35,d/2+10,38],[-35,d/2+10-cable_length/3,8]);
        }
    }
}

// ---------------------------------------------------------------------------
// Compact 4 A, 9-42 V microstep driver (Amazon ASIN B0C64RDCVD).
// X=68 mm overall width, Y=96 mm length, Z=28 mm height.

MICROSTEP_DRIVER_SIZE = [68,96,28];

module _microstep_terminal_strip(poles=12,length=88) {
    pitch=length/poles;
    green=[0.23,0.58,0.27];
    color(green)
        difference() {
            cube([15,length,18],center=true);
            for (i=[0:poles-1]) {
                y=(i-(poles-1)/2)*pitch;
                // Top wire entry and outward-facing screw access.
                translate([0,y,9]) cylinder(d=4.7,h=3,center=true);
                translate([8,y,2]) rotate([0,90,0])
                    cylinder(d=4.2,h=3,center=true);
                translate([4,y,-5]) cube([9,pitch-2,5],center=true);
            }
        }
}

/*
 * Generic driver matching the purchased two-pack. Terminals face +X and the
 * six-position DIP switch is on the -Y end. Mounting surface is Z=0.
 */
module microstep_driver_4a(colors=true,show_terminal_screws=true) {
    w=MICROSTEP_DRIVER_SIZE[0];
    l=MICROSTEP_DRIVER_SIZE[1];
    h=MICROSTEP_DRIVER_SIZE[2];
    black=colors ? [0.045,0.047,0.05] : [0.35,0.35,0.35];

    color(black) {
        // Central electronics cover.
        translate([-3,0,15]) cube([53,l-5,24],center=true);

        // Bottom mounting flange, with open-ended mounting slots.
        difference() {
            translate([-2,0,2]) cube([w,l,4],center=true);
            for (y=[-l/2,l/2])
                translate([-22,y,2]) cube([8,10,6],center=true);
        }

        // Extruded heatsink fins running the full 96 mm length.
        for (x=[-w/2+1:5.5:w/2-12])
            translate([x,0,7]) cube([2,l,12],center=true);

        // End cheeks around the DIP-switch and ventilation openings.
        for (y=[-l/2+2,l/2-2])
            difference() {
                translate([-3,y,14]) cube([58,4,23],center=true);
                for (x=[-20,-10,10,20])
                    translate([x,y,15]) cube([5,6,11],center=true);
            }
    }

    // Two six-pole pluggable terminal blocks form one 12-position strip.
    translate([27,0,19]) _microstep_terminal_strip(poles=12,length=88);

    if (show_terminal_screws)
        color([0.68,0.69,0.70])
            for (i=[0:11])
                translate([27,(i-5.5)*(88/12),28.4])
                    cylinder(d=3.2,h=0.9,center=true,$fn=20);

    // Six-position red DIP bank visible through the end aperture.
    color([0.72,0.025,0.025])
        translate([-3,-l/2-0.2,17]) cube([30,1.5,11],center=true);
    color([0.92,0.92,0.88])
        for (i=[0:5])
            translate([-15+i*5,-l/2-1.1,19]) cube([2.4,1.2,6],center=true);

    // Simplified white legend/table lines on the cover.
    color([0.78,0.79,0.78]) {
        translate([-8,4,27.3]) cube([29,0.6,0.5],center=true);
        for (y=[-26,-18,-10,-2,6,14,22,30])
            translate([-8,y,27.3]) cube([29,0.35,0.5],center=true);
        for (x=[-22,-10,2,7])
            translate([x,2,27.3]) cube([0.35,56,0.5],center=true);
    }
}

module microstep_driver_pair(spacing=82,colors=true) {
    for (x=[-spacing/2,spacing/2])
        translate([x,0,0]) microstep_driver_4a(colors=colors);
}

// ---------------------------------------------------------------------------
// IEC/EN 60715 35 mm top-hat DIN rail and simple mounting accessories.
// Local X is rail length, Y projects away from the mounting wall, and Z is
// the nominal 35 mm rail width.  These are layout envelopes, not spring-tool
// manufacturing drawings.

module din_rail_ts35(length=300, colors=true) {
    steel=colors ? [0.66,0.68,0.70] : [0.58,0.58,0.58];
    color(steel)
        linear_extrude(height=length,center=true)
            polygon([[-17.5,0],[-17.5,1.2],[-13,1.2],[-11,7.5],
                     [11,7.5],[13,1.2],[17.5,1.2],[17.5,0]]);
}

// Backplate that lets a non-DIN stepper driver clip onto TS35 rail.
module din_driver_adapter(width=64,height=106,thickness=4,colors=true) {
    dark=colors ? [0.07,0.075,0.08] : [0.38,0.38,0.38];
    color(dark) {
        translate([0,thickness/2,0]) cube([width,thickness,height],center=true);
        // Fixed upper hook and flexible-looking lower latch envelope.
        translate([0,5,height/2-13]) cube([38,10,5],center=true);
        translate([0,5,-height/2+13]) cube([38,10,5],center=true);
        translate([0,8,-height/2+7]) cube([13,8,10],center=true);
    }
}

module din_mosfet_output_24v(width=36,colors=true) {
    body=colors ? [0.08,0.10,0.12] : [0.40,0.40,0.40];
    green=colors ? [0.10,0.48,0.22] : [0.55,0.55,0.55];
    color(body) cube([width,30,68],center=true);
    color(green)
        for (z=[-20,20]) translate([0,-17,z]) cube([width-8,8,14],center=true);
    color([0.08,0.75,0.16]) translate([10,-18,0]) sphere(d=4,$fn=20);
}

module din_terminal_block_bank(count=8,pitch=6.2,colors=true) {
    for (i=[0:count-1])
        color(colors ? (i<2 ? [0.18,0.48,0.88] : [0.82,0.50,0.08])
                     : [0.58,0.58,0.58])
            translate([(i-(count-1)/2)*pitch,0,0])
                cube([pitch-0.4,28,46],center=true);
}

// ---------------------------------------------------------------------------
// External 2020 panel retainer inspired by the serviceable Voron enclosure
// approach.  The printable bridge spreads load around an M5 clearance hole;
// its shallow underside pad bears on the removable sheet while the screw
// engages a roll-in T-nut in the extrusion slot behind it.
//
// Default orientation is print-ready on Z=0.  In an assembly, rotate the
// module so local Z follows the panel-normal/screw axis.
module external_2020_panel_clip(panel_thickness=3,
                                size=[24,18,5],
                                screw_d=5.5,
                                show_hardware=true,
                                colors=true,
                                body_color=undef) {
    body=colors ? (is_undef(body_color) ? [0.055,0.06,0.065]
                                             : body_color)
                : [0.42,0.42,0.42];
    difference() {
        color(body)
            union() {
                // Rounded-looking bridge represented with a hull so it is
                // strong around the screw without bulky square corners.
                hull()
                    for (x=[-size[0]/2+4,size[0]/2-4])
                        translate([x,0,0]) cylinder(d=size[1],h=size[2],$fn=28);
                // The bridge begins exactly at Z=0, its panel-contact plane.
                // Do not extend a pressure pad below this plane: doing so
                // buries printable geometry inside the removable sheet.
            }
        translate([0,0,-2]) cylinder(d=screw_d,h=size[2]+5,$fn=28);
        // Counterbore keeps the M5 head nearly flush with the clip face.
        translate([0,0,size[2]-2]) cylinder(d=9.5,h=4,$fn=28);
    }

    if (show_hardware) {
        color([0.70,0.71,0.72])
            translate([0,0,size[2]-1.2]) cylinder(d=9,h=2.2,$fn=28);
        // T-nut envelope. This is the only modeled component intentionally
        // inside the extrusion slot when the panel pull distance is zero.
        color([0.43,0.44,0.45])
            translate([0,0,-panel_thickness-3]) cube([10,16,4],center=true);
    }
}

// ---------------------------------------------------------------------------
// STEPPERONLINE 17HS19-2004S1 NEMA 17 motor (Amazon ASIN B00PNEQKC0).
// Motor axis=Z; body occupies Z=0..body_length and the shaft projects +Z.

NEMA17_FRAME = 42;
NEMA17_HOLE_SPACING = 31;

module _nema17_frame_2d(size=42,chamfer=3) {
    polygon(points=[
        [-size/2+chamfer,-size/2], [size/2-chamfer,-size/2],
        [size/2,-size/2+chamfer], [size/2,size/2-chamfer],
        [size/2-chamfer,size/2], [-size/2+chamfer,size/2],
        [-size/2,size/2-chamfer], [-size/2,-size/2+chamfer]
    ]);
}

module _nema17_d_shaft(d=5,length=24,flat_depth=0.5) {
    difference() {
        cylinder(d=d,h=length);
        translate([d/2-flat_depth,-d,-0.1]) cube([d,d*2,length+0.2]);
    }
}

/*
 * 17HS19-2004S1: 42 mm frame, 48 mm body, 5x24 mm D shaft, 22x2 mm pilot,
 * and four M3 tapped holes on a 31 mm square. show_wires uses a shortened
 * visual pigtail; the purchased motor is supplied with a 1 m cable.
 */
module nema17_stepper_17hs19(body_length=48,shaft_length=24,
                             show_wires=true,colors=true) {
    black=colors ? [0.055,0.058,0.062] : [0.34,0.34,0.34];
    steel=colors ? [0.67,0.68,0.69] : [0.62,0.62,0.62];

    // Laminated stator stack with subtle layer ribs.
    color(black) {
        linear_extrude(height=body_length)
            _nema17_frame_2d(size=40.5,chamfer=3);
        for (z=[5:2:body_length-5])
            translate([0,0,z])
                linear_extrude(height=0.35)
                    difference() {
                        _nema17_frame_2d(size=41,chamfer=3);
                        _nema17_frame_2d(size=40.2,chamfer=3);
                    }
        // Black front and rear end-cap corner blocks.
        for (z=[0,body_length-6])
            translate([0,0,z]) linear_extrude(height=6)
                difference() {
                    _nema17_frame_2d();
                    circle(d=30);
                }
    }

    // Bright front face with M3 tapped mounting holes.
    color(steel)
        translate([0,0,body_length])
            linear_extrude(height=2)
                difference() {
                    _nema17_frame_2d();
                    circle(d=22);
                    for (x=[-15.5,15.5],y=[-15.5,15.5])
                        translate([x,y]) circle(d=2.5);
                }

    // 22 mm locating pilot and 5 mm D shaft.
    color([0.16,0.17,0.18])
        translate([0,0,body_length+2]) cylinder(d=22,h=2);
    color(steel)
        translate([0,0,body_length+2])
            _nema17_d_shaft(d=5,length=shaft_length);

    if (show_wires) {
        // Gray strain relief and four shortened, separated lead wires.
        color([0.45,0.46,0.47])
            translate([0,-19,2]) cube([12,5,7],center=true);
        wire_colors=[
            [0.80,0.02,0.02], [0.08,0.55,0.25],
            [0.02,0.18,0.75], [0.045,0.045,0.05]
        ];
        for (i=[0:3])
            color(wire_colors[i]) {
                _psu_cable_segment([-4.5+i*3,-21,2],
                                   [-8+i*4,-48,0],d=1.5);
                _psu_cable_segment([-8+i*4,-48,0],
                                   [-14+i*6,-76,-3],d=1.5);
            }
        color([0.10,0.10,0.11])
            translate([-5,-80,-3]) cube([20,9,6],center=true);
    }
}

module nema17_stepper_pair(spacing=62,colors=true) {
    for (x=[-spacing/2,spacing/2])
        translate([x,0,0])
            nema17_stepper_17hs19(colors=colors);
}

/*
 * Panel-mount IEC C14 mains inlet with integral fuse drawer and illuminated
 * rocker switch. Dimensions follow the advertised 2.24 x 1.97 x 1.38 inch
 * envelope. Local XY is the panel face; Z=0 is the panel's outside surface
 * and the body extends in +Z. The flange extends toward -Z.
 */
module iec_c14_fused_inlet(show_terminals=true) {
    flange_w=56.9;
    flange_h=50.0;
    flange_t=4;
    body_w=47.5;
    body_h=32;
    body_d=31;
    screw_spacing=39.88; // advertised 1.57 in

    flange_outline=[[-28.45,-18],[-22,-25],[22,-25],[28.45,-18],
                    [28.45,18],[22,25],[-22,25],[-28.45,18]];

    color([0.055,0.058,0.062]) {
        // Front mounting flange with two real 3.6 mm fixing holes.
        translate([0,0,-flange_t])
            linear_extrude(height=flange_t)
                difference() {
                    polygon(flange_outline);
                    for (x=[-screw_spacing/2,screw_spacing/2])
                        translate([x,0]) circle(d=3.6,$fn=24);
                }
        // Rear molded body passing through the panel cutout.
        translate([0,0,body_d/2])
            cube([body_w,body_h,body_d],center=true);
    }

    // Illuminated mains rocker, fuse drawer, and recessed C14 appliance inlet.
    color([0.78,0.025,0.02])
        translate([-14,10,-5.2]) cube([19,15,2.4],center=true);
    color([0.075,0.078,0.082]) {
        translate([10,11,-5.2]) cube([23,8,2.2],center=true);
        translate([10,-9,-5.3]) cube([25,20,2.6],center=true);
    }
    // Three visible C14 blades inside the recessed socket.
    color([0.70,0.71,0.72]) {
        for (x=[4,16])
            translate([x,-7,-6.8]) cube([3,7,1.2],center=true);
        translate([10,-15,-6.8]) cube([3,7,1.2],center=true);
        for (x=[-screw_spacing/2,screw_spacing/2])
            translate([x,0,-4.8]) cylinder(d=3.3,h=1.6,center=true,$fn=24);
    }

    if (show_terminals)
        color([0.72,0.73,0.74])
            for (x=[-10,0,10])
                translate([x,0,body_d+5]) cube([5,1.2,10],center=true);
}

// Uncomment for a direct preview when opening this file by itself.
// laser_tube_holder(tube_diameter=65, height=135, show_tube=true);
