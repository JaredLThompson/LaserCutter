// Fixed X drag-chain bracket for the mirrored (+Y) X-drive assembly.
//
// Local coordinates match x_axis_drive_assembly() AFTER it has been mirrored
// across Y: motor centre [39, 35.5, 29], motor plate near Y=-7.25, and the
// fixed chain connector centred near [50, 45, 60].  The bracket shares the
// upper pair of M3 motor-plate bolts, runs around (not through) the motor
// body, and carries the chain above the motor and X-belt envelopes.

$fn = 48;

use <fhcs.scad>;
use <shcs.scad>;
use <ruthex_heatset_inserts.scad>;

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
    plate_left_x = outside_x[0] - arm_w / 2;
    plate_right_x = outside_x[1] + arm_w / 2;
    plate_w = plate_right_x - plate_left_x;
    plate_center_x = (plate_left_x + plate_right_x) / 2;
    // Span the shelf across both uprights.  The previous 30 mm shelf began
    // at X=35, while the left upright ended at X=17, leaving two separate
    // printed bodies.  Derive the shelf bounds from the actual arm locations
    // so future placement changes cannot reopen that gap.
    shelf_left_x = outside_x[0] - arm_w / 2;
    shelf_right_x = max(chain_x + 15, outside_x[1] + arm_w / 2);
    shelf_w = shelf_right_x - shelf_left_x;
    shelf_center_x = (shelf_left_x + shelf_right_x) / 2;
    // The mirrored NEMA-17 body occupies Y=-4.5..35.5 and rises to Z=50.15.
    // Keep the low shelf behind that envelope instead of letting its underside
    // intersect the upper rear corner of the motor.
    shelf_d = 18;
    shelf_center_y = chain_y + 3;
    shelf_t = 6;
    // Reduction-drive clearance in the mirrored assembly.  These include
    // radial running clearance beyond the rendered pulley/belt envelopes.
    reduction_pulley_center = [0, 25];
    reduction_clearance_d = 44;
    motor_pulley_center = [39, 29];
    motor_pulley_clearance_d = 18;

    color(body_color)
        difference() {
            union() {
                // Doubler captured by the two upper motor-mount screws. Its
                // width is derived from the outside faces of both uprights,
                // guaranteeing real overlap instead of the former 0.5 mm
                // air gap at each end.
                translate([plate_center_x, plate_y, upper_bolt_z])
                    cube([plate_w, plate_t, 13], center=true);

                // Arms leave the motor plate outside the NEMA-17 body and
                // climb above it, so neither the motor nor reduction belt is
                // trapped by the bracket.
                for (x = outside_x)
                    hull() {
                        translate([x, plate_y + plate_t / 2,
                                   upper_bolt_z + 2])
                            cube([arm_w, 4, 8], center=true);
                        translate([x, shelf_center_y - shelf_d / 2,
                                   shelf_top_z - shelf_t / 2])
                            cube([arm_w, 6, shelf_t], center=true);
                    }

                // Shelf lies directly beneath the blue fixed-end connector.
                translate([shelf_center_x, shelf_center_y,
                           shelf_top_z - shelf_t / 2])
                    cube([shelf_w, shelf_d, shelf_t], center=true);

                translate([chain_x, chain_y, 0])
                    ruthex_m3_boss(top_z=shelf_top_z);
            }

            // Shared clearance holes for the upper pair of M3 motor screws.
            for (x = bolt_x)
                translate([x, plate_y, upper_bolt_z])
                    rotate([90, 0, 0])
                        cylinder(d=3.5, h=plate_t + 2, center=true);

            // Clear the complete reduction-pulley and belt corridor from the
            // widened front plate.  The material above this relief remains a
            // continuous bridge joining both uprights.
            hull() {
                translate([reduction_pulley_center[0], plate_y,
                           reduction_pulley_center[1]])
                    rotate([90, 0, 0])
                        cylinder(d=reduction_clearance_d,
                                 h=plate_t + 2, center=true);
                translate([motor_pulley_center[0], plate_y,
                           motor_pulley_center[1]])
                    rotate([90, 0, 0])
                        cylinder(d=motor_pulley_clearance_d,
                                 h=plate_t + 2, center=true);
            }

            translate([chain_x, chain_y, 0])
                ruthex_m3_pocket(top_z=shelf_top_z);
        }

    if (show_hardware) {
        translate([chain_x, chain_y, 0])
            ruthex_rx_m3x5x4(top_z=shelf_top_z);

        color([0.62, 0.63, 0.64]) {
            for (x = bolt_x) {
                translate([x, plate_y - 1.6, upper_bolt_z])
                    rotate([-90, 0, 0]) m3_shcs();
            }
            translate([chain_x, chain_y, shelf_top_z])
                rotate([180, 0, 0])
                    m3_fhcs(length=8);
        }
    }
}

// Standalone fabrication preview. Ignored when imported with `use`.
x_drag_chain_fixed_bracket();
