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
                                 center_bore=4.2) {
    difference() {
        // Slightly relieved corners approximate a standard rounded profile.
        offset(r=0.8) offset(delta=-0.8) square([20,20],center=true);
        circle(d=center_bore);
        for (a=[0,90,180,270])
            rotate(a)
                translate([0,10])
                    _aluminum_extrusion_slot_2d(
                        slot_width=slot_width,cavity_width=cavity_width);
    }
}

module _aluminum_2040_profile_2d(slot_width=6, cavity_width=11,
                                 center_bore=4.2) {
    difference() {
        offset(r=0.8) offset(delta=-0.8) square([40,20],center=true);

        // Two core bores, one for each nominal 20 mm cell.
        for (x=[-10,10]) translate([x,0]) circle(d=center_bore);

        // Two slots on each 40 mm face.
        for (x=[-10,10], a=[0,180])
            rotate(a) translate([x,10])
                _aluminum_extrusion_slot_2d(
                    slot_width=slot_width,cavity_width=cavity_width);

        // One centered slot on each 20 mm end face.
        for (a=[90,270])
            rotate(a) translate([0,20])
                _aluminum_extrusion_slot_2d(
                    slot_width=slot_width,cavity_width=cavity_width);

        // Internal lightening cavities while retaining a central structural web.
        for (x=[-10,10], y=[-5.7,5.7])
            translate([x,y]) circle(d=4.8,$fn=24);
    }
}

/*
 * 20 x 20 mm T-slot extrusion. Cross section is centered on X/Y; length is Z.
 * center=true places the midpoint at Z=0, otherwise the bottom is at Z=0.
 */
module aluminum_extrusion_2020(length=100, center=false, black=false,
                               slot_width=6, center_bore=4.2) {
    color(black ? ALUMINUM_BLACK : ALUMINUM_CLEAR)
        linear_extrude(height=length,center=center,convexity=10)
            _aluminum_2020_profile_2d(
                slot_width=slot_width,center_bore=center_bore);
}

/*
 * 20 x 40 mm T-slot extrusion. The 40 mm dimension follows X and length is Z.
 */
module aluminum_extrusion_2040(length=100, center=false, black=false,
                               slot_width=6, center_bore=4.2) {
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

// Uncomment for a direct preview when opening this file by itself.
// laser_tube_holder(tube_diameter=65, height=135, show_tube=true);
