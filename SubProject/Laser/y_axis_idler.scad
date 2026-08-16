// Adjustable Y-axis GT2 idler for a 2020 front cross member.
//
// Assembly origin:
//   X = belt centerline
//   Y = centerline of the front 2020 extrusion
//   Z = centerline of the front 2020 extrusion
//
// Positive `tension` moves the pulley toward the front of the machine,
// increasing the belt path length.  The useful adjustment range is 0-15 mm.

use <gt2_gears.scad>;
use <bhcs.scad>;
use <shcs.scad>;
use <nuts_and_washers.scad>;

y_axis_idler_tensioner_assembly();


module y_axis_idler_tensioner_assembly(tension=7.5, mirrored=false) {
    travel = 15;
    setting = min(max(tension, 0), travel);
    axle_y = 30 - setting;
    axle_z = 25;
    // Two symmetric adjusters avoid twisting the sliding fork.  Their captive
    // nuts sit forward of the pulley envelope rather than beside its flange.
    jack_screw_x_positions = [-7, 7];
    jack_screw_z = 18;
    jack_nut_y = -9;

    // Fixed saddle bolted into the top slot of the front 2020 member.
    color("FireBrick")
        y_idler_fixed_saddle(
            jack_screw_x_positions=jack_screw_x_positions,
            jack_screw_z=jack_screw_z);

    // Sliding fork, captured by the saddle's two longitudinal guide rails.
    color("Crimson")
        translate([0, axle_y, 0])
            y_idler_sliding_fork(
                jack_screw_x_positions=jack_screw_x_positions,
                jack_nut_y=jack_nut_y,
                jack_screw_z=jack_screw_z);

    // 20-tooth flanged GT2 idler and its M5 shoulder-bolt representation.
    translate([0, axle_y, axle_z])
        rotate([0, 90, 0])
            gt2_toothed_idler(teeth=20, bore=5, width=6, center=true);

    color("Silver")
        translate([0, axle_y, axle_z])
            rotate([0, 90, 0])
                // Flush/recessed axle hardware stays inside the captured fork
                // width so it cannot strike the fixed keeper rails.
                cylinder(d=5, h=19, center=true, $fn=40);

    // M5 jack screw.  The head remains accessible from the machine front.
    for (jack_screw_x=jack_screw_x_positions) {
        // Standard M4 SHCS: 7 mm cylindrical head, 4 mm tall, with a
        // modeled 3 mm hex socket.  The head sits flush in the counterbore.
        translate([jack_screw_x, -16.5, jack_screw_z])
            rotate([-90, 0, 0])
                m4_shcs(length=axle_y+16.5);

        color("Silver")
            translate([jack_screw_x, axle_y+jack_nut_y, jack_screw_z])
                rotate([90, 0, 0])
                    cylinder(d=7.8, h=3.2, center=true, $fn=6);
    }

    // Scale marks make it easy to set both belts to the same extension.
    color("White")
        for (mark=[0:2.5:travel])
            translate([mirrored ? -13.6 : 13.6, 30-mark, 12])
                cube([0.4, 0.5, mark % 5 == 0 ? 5 : 3], center=true);
}

module y_idler_fixed_saddle(jack_screw_x_positions=[-7, 7], jack_screw_z=18) {
    difference() {
        union() {
            // Base bridges the 2020 top face.  Its 4 mm thickness leaves
            // 3 mm below the pulley OD instead of crowding the belt path.
            translate([0, 8, 12]) cube([30, 56, 4], center=true);

            // Two guide cheeks capture the sliding fork without obstructing it.
            for (x=[-13, 13])
                translate([x, 8, 20]) cube([3, 56, 20], center=true);

            // Inward keeper lips capture the runner shoulders with 0.5 mm
            // vertical clearance.  Together with the side cheeks these form
            // two C-shaped slideways and prevent upward carriage escape.
            for (x=[-11, 11])
                translate([x, 8, 25.75])
                    cube([2, 56, 2.5], center=true);

            // Front reaction wall carries the offset jack screw while leaving
            // the center open for the belt loop.
            translate([0, -18, 20]) cube([30, 5, 20], center=true);
        }

        // Two M5 fasteners into the top T-slot, spaced along Y.
        for (y=[-2, 18]) {
            translate([0, y, 9]) cylinder(d=5.5, h=10, $fn=32);
            translate([0, y, 14]) cylinder(d=10, h=4, $fn=32);
        }

        // Jack-screw clearance in the reaction wall.
        for (jack_screw_x=jack_screw_x_positions) {
            translate([jack_screw_x, -21, jack_screw_z])
                rotate([-90, 0, 0]) cylinder(d=4.5, h=9, $fn=32);

            // Flat-bottom counterbore for a standard M4 SHCS head.  The
            // 7.5 mm pocket provides 0.25 mm radial printing clearance.
            translate([jack_screw_x, -20.6, jack_screw_z])
                rotate([-90, 0, 0]) cylinder(d=7.5, h=4.3, $fn=40);

            // Longitudinal clearance remains above the saddle base.
            translate([jack_screw_x, -14, jack_screw_z])
                rotate([-90, 0, 0]) cylinder(d=4.8, h=54, $fn=32);
        }

        // Continuous clearance for both the pulley sweep and the belt run
        // leaving toward +Y.  This remains open for the full 15 mm travel.
        translate([0, 22, 25])
            cube([10, 60, 20], center=true);
    }
}

module y_idler_sliding_fork(
    jack_screw_x_positions=[-7, 7],
    jack_nut_y=-9,
    jack_screw_z=18) {
    axle_z = 25;

    difference() {
        union() {
            // Runner captured between the fixed guide cheeks.
            translate([0, 0, 18]) cube([22, 20, 12], center=true);

            // Fork ears leave an 11 mm pocket for a 6 mm flanged idler.
            for (x=[-7.5, 7.5])
                hull() {
                    translate([x, 0, 19]) cube([4, 18, 10], center=true);
                    translate([x, 0, axle_z])
                        rotate([0, 90, 0]) cylinder(d=13, h=4, center=true, $fn=40);
                }

            // Reinforced bosses for the two captive nuts, moved away from the
            // pulley so neither nut enters the rotating flange envelope.
            for (jack_screw_x=jack_screw_x_positions)
                translate([jack_screw_x, jack_nut_y, jack_screw_z])
                    cube([8, 6, 10], center=true);

        }

        // M5 pulley axle.
        translate([0, 0, axle_z])
            rotate([0, 90, 0]) cylinder(d=5.2, h=40, center=true, $fn=32);

        // Pulley envelope: prevents the runner from touching either flange.
        translate([0, 0, axle_z])
            rotate([0, 90, 0]) cylinder(d=21, h=9.5, center=true, $fn=48);

        // Belt corridor from the pulley tangent region out through the rear.
        // It clears both the upper and lower runs of the loop, not merely the
        // belt centerline.
        translate([0, 12, axle_z])
            cube([10, 26, 20], center=true);

        // Captive M5 nut for the longitudinal jack screw.
        for (jack_screw_x=jack_screw_x_positions) {
            translate([jack_screw_x, jack_nut_y, jack_screw_z])
                rotate([90, 0, 0]) cylinder(d=8.1, h=3.5, center=true, $fn=6);
            translate([jack_screw_x, jack_nut_y, jack_screw_z])
                rotate([-90, 0, 0]) cylinder(d=4.3, h=24, center=true, $fn=32);
        }
    }
}

// Backward-compatible name for older assemblies.  Its origin now uses the
// documented front-extrusion datum described above.
module y_axis_idler_assembly(tension=7.5, mirrored=false) {
    y_axis_idler_tensioner_assembly(tension=tension, mirrored=mirrored);
}
