// Fixed X drag-chain bracket for the mirrored (+Y) X-drive assembly.
//
// Local coordinates match x_axis_drive_assembly() AFTER it has been mirrored
// across Y: motor centre [39, 35.5, 29], motor plate near Y=-7.25, and the
// fixed chain connector centred near [50, 45, 60].  The bracket shares the
// upper pair of M3 motor-plate bolts, runs around (not through) the motor
// body, and carries the chain above the motor and X-belt envelopes.

$fn = 48;

module x_drag_chain_fixed_bracket(show_hardware=true,
                                  body_color=[0.10, 0.32, 0.55],
                                  chain_x=50,
                                  chain_y=45,
                                  shelf_top_z=52.5) {
    plate_y = -10.5;
    plate_t = 3;
    upper_bolt_z = 44.5;
    bolt_x = [23.5, 54.5];
    outside_x = [14, 64];
    arm_w = 6;
    shelf_w = 30;
    shelf_d = 24;
    shelf_t = 4;

    color(body_color)
        difference() {
            union() {
                // Thin doubler captured by the two upper motor-mount screws.
                translate([39, plate_y, upper_bolt_z])
                    cube([43, plate_t, 13], center=true);

                // Arms leave the motor plate outside the NEMA-17 body and
                // climb above it, so neither the motor nor reduction belt is
                // trapped by the bracket.
                for (x = outside_x)
                    hull() {
                        translate([x, plate_y + plate_t / 2,
                                   upper_bolt_z + 2])
                            cube([arm_w, 4, 8], center=true);
                        translate([x, chain_y - shelf_d / 2,
                                   shelf_top_z - shelf_t / 2])
                            cube([arm_w, 6, shelf_t], center=true);
                    }

                // Shelf lies directly beneath the blue fixed-end connector.
                translate([chain_x, chain_y - shelf_d / 2,
                           shelf_top_z - shelf_t / 2])
                    cube([shelf_w, shelf_d, shelf_t], center=true);
            }

            // Shared clearance holes for the upper pair of M3 motor screws.
            for (x = bolt_x)
                translate([x, plate_y, upper_bolt_z])
                    rotate([90, 0, 0])
                        cylinder(d=3.5, h=plate_t + 2, center=true);

            // M4 fixed-end connector bolt/adjustment slot location.
            translate([chain_x, chain_y,
                       shelf_top_z - shelf_t / 2])
                cylinder(d=4.4, h=shelf_t + 2, center=true);
        }

    if (show_hardware) {
        color([0.62, 0.63, 0.64]) {
            for (x = bolt_x) {
                translate([x, plate_y - 2.2, upper_bolt_z])
                    rotate([90, 0, 0]) cylinder(d=6, h=3, center=true);
                translate([x, plate_y, upper_bolt_z])
                    rotate([90, 0, 0]) cylinder(d=3, h=11, center=true);
            }
            translate([chain_x, chain_y, shelf_top_z + 2.5])
                cylinder(d=7, h=3, center=true);
            translate([chain_x, chain_y, shelf_top_z - 1])
                cylinder(d=4, h=9, center=true);
        }
        color([0.42, 0.43, 0.44])
            translate([chain_x, chain_y, shelf_top_z - shelf_t - 1.6])
                cylinder(d=7.7, h=3.2, center=true, $fn=6);
    }
}

// Standalone fabrication preview. Ignored when imported with `use`.
x_drag_chain_fixed_bracket();
