// NEMA 17 Stepper Motor Mount Plate Library
// Save this file as: nema17_plate.scad

use <nema17_motor.scad>;
use <bhcs.scad>;
use <gt2_gears.scad>;

$fn = 60; 

plate_width       = 39.50; // Dimension A
plate_length      = 82.00; // Dimension B
plate_thickness   = 3.00;  // Dimension C
nema_hole_dist_x  = 26.00; // Dimension D
nema_hole_dist_y  = 31.00; // Dimension E
row_spacing_y     = 20.00; // Dimension F
hole_spacing_x    = 10.00; // Dimension G
center_hole_dia   = 25.00; // Dimension H
nema_hole_dia     = 3.10;  // Dimension I
grid_hole_dia     = 5.10;  // Dimension J
corner_radius     = 4.00;   // Rounded corners
motor_center_y = plate_length - 20.00; 


nema_17_mount_plate_assembly();

module nema_17_mount_plate_assembly(pulley_axial_adjustment=0){

   translate([-plate_width/2,-motor_center_y,0])nema_17_mount_plate();
   translate([0,0,-40])nema17_stepper();
   
   // Axial adjustment slides only the pulley along the motor shaft; the
   // motor and mounting plate remain fixed on their support.
   translate([0,0,6 + pulley_axial_adjustment])
      rotate([0,0,0]) gt2_toothed_pulley();
   
    // 3. Four shcs mount screws
    screw_positions = [
        [ - nema_hole_dist_x / 2, - nema_hole_dist_y / 2],
        [nema_hole_dist_x / 2, - nema_hole_dist_y / 2],
        [- nema_hole_dist_x / 2, nema_hole_dist_y / 2],
        [nema_hole_dist_x / 2, nema_hole_dist_y / 2]
    ];
    for (pos = screw_positions) {
        translate([pos[0], pos[1], 3])
            m3_bhcs();
    }

}

module nema_17_mount_plate(
    plate_width       = 39.50, // Dimension A
    plate_length      = 82.00, // Dimension B
    plate_thickness   = 3.00,  // Dimension C
    nema_hole_dist_x  = 26.00, // Dimension D
    nema_hole_dist_y  = 31.00, // Dimension E
    row_spacing_y     = 20.00, // Dimension F
    hole_spacing_x    = 10.00, // Dimension G
    center_hole_dia   = 25.00, // Dimension H
    nema_hole_dia     = 3.10,  // Dimension I
    grid_hole_dia     = 5.10,  // Dimension J
    corner_radius     = 4.00   // Rounded corners
) {
    // --- DERIVED POSITIONS ---
    motor_center_y = plate_length - 20.00; 
    bottom_row_y   = 10.00; 

    // --- MAIN ASSEMBLY ---
    difference() {
        // 1. Base Plate Shape
        linear_extrude(height = plate_thickness) {
            hull() {
                translate([corner_radius, corner_radius, 0]) circle(r = corner_radius);
                translate([plate_width - corner_radius, corner_radius, 0]) circle(r = corner_radius);
                translate([corner_radius, plate_length - corner_radius, 0]) circle(r = corner_radius);
                translate([plate_width - corner_radius, plate_length - corner_radius, 0]) circle(r = corner_radius);
            }
        }
        
        // 2. Large Center Hole (H)
        translate([plate_width / 2, motor_center_y, -0.5])
            cylinder(h = plate_thickness + 1, d = center_hole_dia);
        
        // 3. Four NEMA Mounting Holes (I)
        nema_holes = [
            [plate_width / 2 - nema_hole_dist_x / 2, motor_center_y - nema_hole_dist_y / 2],
            [plate_width / 2 + nema_hole_dist_x / 2, motor_center_y - nema_hole_dist_y / 2],
            [plate_width / 2 - nema_hole_dist_x / 2, motor_center_y + nema_hole_dist_y / 2],
            [plate_width / 2 + nema_hole_dist_x / 2, motor_center_y + nema_hole_dist_y / 2]
        ];
        for (pos = nema_holes) {
            translate([pos[0], pos[1], -0.5])
                cylinder(h = plate_thickness + 1, d = nema_hole_dia);
        }
        
        // 4. Bottom Grid Rows of Holes (J)
        for (y_pos = [bottom_row_y, bottom_row_y + row_spacing_y]) {
            for (i = [-1, 0, 1]) {
                translate([plate_width / 2 + (i * hole_spacing_x), y_pos, -0.5])
                    cylinder(h = plate_thickness + 1, d = grid_hole_dia);
            }
        }
    }
}
