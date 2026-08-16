// Right-side Y drag-chain supports.
// Both modules use a structural mounting datum at Z=0 and present a shelf at
// shelf_top_z.  X grows toward the machine's right side; Y is rearward.

use <shcs.scad>;
use <fhcs.scad>;
use <ruthex_heatset_inserts.scad>;

$fn = 48;

y_drag_chain_moving_bracket();

module y_drag_chain_moving_bracket(show_hardware=true,
                                   shelf_top_z=-60.5,
                                   chain_x=0,
                                   chain_y=10,
                                   body_color=[0.70, 0.04, 0.06]) {
    mount_t = 4;
    shelf_t = 6;

    color(body_color)
        difference() {
            union() {
                // Compact flange bears against the underside of the moving
                // X-gantry 2020 and uses its downward-facing T-slot.
                translate([0, 0, -mount_t / 2])
                    cube([48, 22, mount_t], center=true);

                // Shelf supports the moving red connector directly below it.
                // It is wide enough to join both outboard ribs without a
                // central wall blocking the cable exit.
                translate([chain_x, chain_y / 2,
                           shelf_top_z - shelf_t / 2])
                    cube([48, abs(chain_y) + 18, shelf_t], center=true);

                translate([chain_x, chain_y, 0])
                    ruthex_m3_boss(top_z=shelf_top_z);

                // Keep the structural ribs outside both M5 screw-head
                // envelopes and outside the 18 mm cable-chain width.
                for (x = [-19, 19])
                    hull() {
                        translate([x, 0, -8])
                            cube([8, 8, 16], center=true);
                        translate([x, chain_y,
                                   shelf_top_z - shelf_t / 2])
                            cube([12, 8, shelf_t], center=true);
                    }
            }

            // Two M5 bolts enter the moving crossbar's bottom T-slot.
            for (x = [-10, 10])
                translate([x, 0, -mount_t / 2])
                    cylinder(d=5.5, h=mount_t + 2, center=true);

            translate([chain_x, chain_y, 0])
                ruthex_m3_pocket(top_z=shelf_top_z);
        }

    if (show_hardware)
        for (x = [-10, 10])
            // Head remains below the flange; shaft enters the gantry T-slot.
            translate([x, 0, -mount_t])
                m5_shcs(length=14);

    if (show_hardware) {
        translate([chain_x, chain_y, 0])
            ruthex_rx_m3x5x4(top_z=shelf_top_z);

        translate([chain_x, chain_y, shelf_top_z])
            rotate([180, 0, 0])
                m3_fhcs(length=8);
    }
}


module y_drag_chain_fixed_bracket(show_hardware=true,
                                  shelf_top_z=-66.5,
                                  chain_x=-45,
                                  chain_y=10,
                                  body_color=[0.10, 0.32, 0.55]) {
    post_t = 6;
    post_depth = 46;
    shelf_t = 6; // was 4, increased to 6 to make printing easier

    // Symmetric outboard ribs leave the M5 mounting-hole centerlines at
    // Y=+/-12 unobstructed and make the cantilever a conventional L-bracket.
    rib_y_positions = [-21, 21];

    color(body_color)
        difference() {
            union() {
                // Mounting plate for the stationary right-side longitudinal
                // 2020 chassis rail (never the moving X gantry).
                translate([-post_t / 2, 0, 5+shelf_top_z / 2])
                    cube([post_t, post_depth, abs(shelf_top_z) + 10], center=true);

                // Inboard shelf reaches from the X=510 chassis rail to the
                // chain centreline near X=455.
                // Center the structural shelf beneath the mounting wall.
                // Only its X reach is offset, because that 32 mm cantilever
                // is required to meet the inboard cable-chain centerline.
                translate([chain_x / 2, 0,
                           shelf_top_z - shelf_t / 2])
                    cube([abs(chain_x) + 18, post_depth, shelf_t], center=true);

                translate([chain_x, chain_y, 0])
                    ruthex_m3_boss(top_z=shelf_top_z);

                for (y = rib_y_positions)
                    hull() {
                        // Upper wall root.
                        translate([-post_t, y, -8])
                            cube([4, 4, 16], center=true);
                        // Lower wall root closes the triangular gap behind
                        // the diagonal, producing a solid printable gusset.
                        translate([-post_t, y,
                                   shelf_top_z - shelf_t / 2])
                            cube([4, 4, shelf_t], center=true);
                        // Stop the gusset before the chain's inboard side.
                        // With an 18 mm chain and a 10 mm gusset tip this
                        // leaves 3 mm of running clearance.
                        translate([chain_x + 17, y,
                                   shelf_top_z - shelf_t / 2])
                            cube([10, 4, shelf_t], center=true);
                    }
            }

            for (y = [-12, 12])
                translate([-post_t / 2, y, 0])
                    rotate([0, 90, 0])
                        cylinder(d=5.5, h=post_t + 2, center=true);

            translate([chain_x, chain_y, 0])
                ruthex_m3_pocket(top_z=shelf_top_z);
        }

    if (show_hardware)
        for (y = [-12, 12])
            // Head remains outside the bracket; shaft enters the side T-slot.
            translate([-post_t, y, 0])
                rotate([0, 90, 0])
                    m5_shcs(length=14);

    if (show_hardware) {
        translate([chain_x, chain_y, 0])
            ruthex_rx_m3x5x4(top_z=shelf_top_z);

        translate([chain_x, chain_y, shelf_top_z])
            rotate([180, 0, 0])
                m3_fhcs(length=8);
    }
}
