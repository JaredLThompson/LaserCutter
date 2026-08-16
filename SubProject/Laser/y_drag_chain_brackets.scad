// Right-side Y drag-chain supports.
// Both modules use a structural mounting datum at Z=0 and present a shelf at
// shelf_top_z.  X grows toward the machine's right side; Y is rearward.

use <shcs.scad>;

$fn = 48;

module y_drag_chain_moving_bracket(show_hardware=true,
                                   shelf_top_z=-60.5,
                                   chain_x=0,
                                   chain_y=10,
                                   body_color=[0.70, 0.04, 0.06]) {
    mount_t = 4;
    shelf_t = 4;

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

            // M4 chain-end mounting slot location.
            translate([chain_x, chain_y,
                       shelf_top_z - shelf_t / 2])
                cylinder(d=4.4, h=shelf_t + 2, center=true);
        }

    if (show_hardware)
        for (x = [-10, 10])
            // Head remains below the flange; shaft enters the gantry T-slot.
            translate([x, 0, -mount_t])
                m5_shcs(length=14);
}


module y_drag_chain_fixed_bracket(show_hardware=true,
                                  shelf_top_z=-66.5,
                                  chain_x=-45,
                                  chain_y=10,
                                  body_color=[0.10, 0.32, 0.55]) {
    post_t = 6;
    shelf_t = 4;

    color(body_color)
        difference() {
            union() {
                // Mounting plate for the stationary right-side longitudinal
                // 2020 chassis rail (never the moving X gantry).
                translate([-post_t / 2, 0, shelf_top_z / 2])
                    cube([post_t, 38, abs(shelf_top_z) + 20], center=true);

                // Inboard shelf reaches from the X=510 chassis rail to the
                // chain centreline near X=455.
                translate([chain_x / 2, chain_y,
                           shelf_top_z - shelf_t / 2])
                    cube([abs(chain_x) + 18, 34, shelf_t], center=true);

                for (y = [-12, 12])
                    hull() {
                        translate([-post_t, y, -8])
                            cube([4, 4, 16], center=true);
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

            translate([chain_x, chain_y,
                       shelf_top_z - shelf_t / 2])
                cylinder(d=4.4, h=shelf_t + 2, center=true);
        }

    if (show_hardware)
        for (y = [-12, 12])
            // Head remains outside the bracket; shaft enters the side T-slot.
            translate([-post_t, y, 0])
                rotate([0, 90, 0])
                    m5_shcs(length=14);
}
