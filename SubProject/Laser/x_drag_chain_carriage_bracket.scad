// Opposite-side drag-chain bracket for the A4/MGN12H X carriage.
// Local origin: midpoint of the two existing M3 tapped holes on the +Y end
// face of MGN12HAdapterPlateAssembly(). The bracket grows toward +Y and +Z.

use <fhcs.scad>;
use <ruthex_heatset_inserts.scad>;

$fn = 48;

x_drag_chain_carriage_bracket();

module x_drag_chain_carriage_bracket(show_hardware=true,
                                     body_color=[0.70, 0.04, 0.06],
                                     shelf_top_z=73.5) {
    mount_hole_spacing = 30;
    vertical_width = 42;
    vertical_bottom_z = -8;
    vertical_height = shelf_top_z - vertical_bottom_z;
    vertical_thickness = 6;
    shelf_width = 54;
    shelf_depth = 45;
    shelf_thickness = 6;
    chain_bolt_x = 10;
    chain_bolt_y = 25;

    color(body_color)
        difference() {
            union() {
                // Plate bolts directly to the carriage's existing two-hole
                // M3 end-face pattern.
                translate([0, vertical_thickness / 2,
                           vertical_bottom_z + vertical_height / 2])
                    cube([vertical_width, vertical_thickness,
                          vertical_height], center=true);

                // Horizontal shelf supports the inverted red connector tab.
                translate([5, shelf_depth / 2,
                           shelf_top_z - shelf_thickness / 2])
                    cube([shelf_width, shelf_depth, shelf_thickness],
                         center=true);

                // Local 6 mm-thick boss for a Ruthex RX-M3x5x4 insert.
                translate([chain_bolt_x, chain_bolt_y, 0])
                    ruthex_m3_boss(top_z=shelf_top_z);

                // Two triangular side gussets resist cable-chain torque.
                for (x = [-19, 19])
                    hull() {
                        translate([x, vertical_thickness,
                                   shelf_top_z - 18])
                            cube([4, 4, 30], center=true);
                        translate([x, shelf_depth - 4,
                                   shelf_top_z - shelf_thickness])
                            cube([4, 8, shelf_thickness], center=true);
                    }
            }

            // M3 clearance bores align with the tapped A4 end-face holes.
            for (x = [-mount_hole_spacing / 2,
                       mount_hole_spacing / 2])
                translate([x, vertical_thickness / 2, 0])
                    rotate([90, 0, 0])
                        cylinder(d=3.4, h=vertical_thickness + 2,
                                 center=true);

            // Straight 4.4 mm through pocket for the M3 heat-set insert.
            translate([chain_bolt_x, chain_bolt_y, 0])
                ruthex_m3_pocket(top_z=shelf_top_z);
        }

    if (show_hardware) {
        translate([chain_bolt_x, chain_bolt_y, 0])
            ruthex_rx_m3x5x4(top_z=shelf_top_z);

        // Two M3 SHCS heads on the accessible outside face.
        color([0.62, 0.63, 0.64])
            for (x = [-mount_hole_spacing / 2,
                       mount_hole_spacing / 2]) {
                translate([x, vertical_thickness + 1.5, 0])
                    rotate([90, 0, 0])
                        cylinder(d=5.7, h=3, center=true);
                translate([x, vertical_thickness / 2, 0])
                    rotate([90, 0, 0])
                        cylinder(d=3, h=10, center=true);
            }

        // M3 FHCS installs from above and seats flush in the countersunk,
        // inverted drag-chain connector; its nut remains beneath the shelf.
        // The library model's shaft points +Z and its head extends toward -Z.
        // Flip it so the FHCS installs downward from the accessible top face.
        // The connector ear's underside lands directly on shelf_top_z.  The
        // FHCS head/shaft junction therefore begins at that same interface.
        translate([chain_bolt_x, chain_bolt_y, shelf_top_z])
            rotate([180, 0, 0])
                m3_fhcs(length=8);
    }
}

// Standalone CNC/printing preview. Ignored when imported with `use`.
x_drag_chain_carriage_bracket();
