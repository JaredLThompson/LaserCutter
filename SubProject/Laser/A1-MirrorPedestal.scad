// ============================================================================
// A1 mirror 2040 pedestal
// Local coordinates: centered on X/Y, lower plate bottom at Z=0.
// The default top mounting surface is Z=50.
// ============================================================================

use <extrusion-20xx.scad>;
use <shcs.scad>;

$fn = 64;

// Standalone centered preview.
a1_mirror_pedestal();

module a1_mirror_pedestal(
    height=50,
    plate_thickness=6,
    bottom_plate_width=100,
    bottom_plate_depth=100,
    top_plate_width=72,
    top_plate_depth=68,
    extrusion_core_spacing=20,
    black_extrusion=true) {

    extrusion_bottom_z = plate_thickness;
    extrusion_top_z = height - plate_thickness;
    extrusion_length = extrusion_top_z - extrusion_bottom_z;

    a1_pedestal_bottom_plate(
        width=bottom_plate_width,
        depth=bottom_plate_depth,
        thickness=plate_thickness,
        extrusion_core_spacing=extrusion_core_spacing);

    // The 40 mm section follows X for stiffness in the tube-to-A1 direction.
    translate([0, 0, extrusion_bottom_z])
        aluminum_extrusion_2040(
            length=extrusion_length,
            black=black_extrusion);

    a1_pedestal_top_plate(
        plate_top_z=height,
        width=top_plate_width,
        depth=top_plate_depth,
        thickness=plate_thickness,
        extrusion_core_spacing=extrusion_core_spacing);

    // M5 SHCS into tapped axial core bores at both ends of the 2040.
    for (core_x=[-extrusion_core_spacing/2, extrusion_core_spacing/2]) {
        // Bottom fasteners install upward from beneath the bridge plate.
        translate([core_x, 0, 5])
            m5_shcs(length=16);

        // Top fasteners install downward and finish flush below the A1 base.
        translate([core_x, 0, height-5])
            rotate([180, 0, 0])
                m5_shcs(length=16);
    }
}


// Bottom plate uses offsets relative to the pedestal center.  Defaults match
// the current lower-left chassis corner after importing at X=-465, Y=455.
module a1_pedestal_bottom_plate(
    width=100,
    depth=100,
    thickness=6,
    corner_post_x=-45,
    corner_post_y=45,
    left_rail_x=-45,
    left_rail_mount_y=[-25, 10],
    rear_rail_y=45,
    rear_rail_mount_x=[-15, 20],
    extrusion_core_spacing=20) {

    color([0.55, 0.57, 0.59])
        difference() {
            translate([0, 0, thickness/2])
                cube([width, depth, thickness], center=true);

            // Clearance for the existing rear-left vertical frame post.
            translate([corner_post_x, corner_post_y, thickness/2])
                cube([22, 22, thickness+2], center=true);

            // M5 slots over the left Y rail.
            for (mount_y=left_rail_mount_y)
                translate([left_rail_x+5, mount_y, -1])
                    hull()
                        for (slot_y=[-4, 4])
                            translate([0, slot_y, 0])
                                cylinder(d=5.5, h=thickness+2);

            // M5 slots over the rear X rail.
            for (mount_x=rear_rail_mount_x)
                translate([mount_x, rear_rail_y-5, -1])
                    hull()
                        for (slot_x=[-4, 4])
                            translate([slot_x, 0, 0])
                                cylinder(d=5.5, h=thickness+2);

            // M5 clearance and underside counterbores for the 2040 cores.
            for (core_x=[-extrusion_core_spacing/2,
                         extrusion_core_spacing/2]) {
                translate([core_x, 0, -1])
                    cylinder(d=5.5, h=thickness+2);
                translate([core_x, 0, -1])
                    cylinder(d=9, h=6.2);
            }
        }
}


// Top adapter duplicates the elongated mounting holes in the rotated
// 56 x 60 mm A1 base while remaining centered at the local origin.
module a1_pedestal_top_plate(
    plate_top_z=50,
    width=72,
    depth=68,
    thickness=6,
    extrusion_core_spacing=20) {

    color([0.55, 0.57, 0.59])
        difference() {
            translate([0, 0, plate_top_z-thickness/2])
                cube([width, depth, thickness], center=true);

            for (slot_x=[-22.5, 22.5], slot_y=[-15, 15])
                translate([slot_x, slot_y, plate_top_z-thickness-1])
                    hull()
                        for (travel_x=[-7.5, 7.5])
                            translate([travel_x, 0, 0])
                                cylinder(d=5.5, h=thickness+2);

            // M5 clearance and top counterbores for the 2040 cores.
            for (core_x=[-extrusion_core_spacing/2,
                         extrusion_core_spacing/2]) {
                translate([core_x, 0, plate_top_z-thickness-1])
                    cylinder(d=5.5, h=thickness+2);
                translate([core_x, 0, plate_top_z-5.2])
                    cylinder(d=9, h=5.4);
            }
        }
}


// Convenience modules for centered DXF export.
module a1_pedestal_top_plate_cnc() {
    a1_pedestal_top_plate(plate_top_z=0);
}

module a1_pedestal_bottom_plate_cnc() {
    a1_pedestal_bottom_plate();
}
