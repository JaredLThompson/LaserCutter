// =================================================================
// PARAMETRIC MGN12H LINEAR RAIL & CARRIAGE MODEL
// Dimensions based on standard HIWIN MGN12 specifications.
// =================================================================

$fn = 32; // Smoothness for rendered cylinders

// --- PARAMETERS ---
rail_length      = 250; // Change this to your desired rail length in mm
carriage_offset  = 100; // Position of the carriage along the rail (from 0)

// --- CHOOSE WHAT TO RENDER ---
render_rail     = true;
render_carriage = true;

// --- ASSEMBLY EXECUTION ---
if (render_rail) {
    color("Silver") mgn12_rail(rail_length);
}

if (render_carriage) {
    translate([0, carriage_offset, 13 - 4.3]) // Align carriage height to top of rail
    color("DimGray") mgn12h_carriage();
}

// =================================================================
// MODULES
// =================================================================

// 1. MGN12 Rail Module
module mgn12_rail(length) {
    rail_w = 12;
    rail_h = 8;
    hole_pitch = 25;   // Standard distance between mounting hole centers
    first_hole = 10;   // Distance to the first hole center
    
    difference() {
        // Main Rail Body Profile
        translate([-rail_w/2, 0, 0])
        cube([rail_w, length, rail_h]);
        
        // Inner Side V-Groove cuts for carriage alignment
        groove_w = 1.5;
        groove_h = 2;
        translate([-(rail_w/2 + 0.1), -1, 3.5]) cube([groove_w, length + 2, groove_h]);
        translate([rail_w/2 - groove_w + 0.1, -1, 3.5]) cube([groove_w, length + 2, groove_h]);
        
        // Parametric Counterbore Mounting Holes (M3 Screws)
        num_holes = floor((length - first_hole) / hole_pitch) + 1;
        for (i = [0 : num_holes - 1]) {
            y_pos = first_hole + (i * hole_pitch);
            if (y_pos < length - 5) { // Ensure hole isn't too close to the end
                translate([0, y_pos, -0.1]) {
                    // Screw Shaft (Clearance for M3)
                    cylinder(d = 3.5, h = rail_h + 0.2);
                    // Counterbore Cap Head (6mm diameter, 4.5mm depth)
                    translate([0, 0, rail_h - 4.5 + 0.1])
                    cylinder(d = 6.0, h = 4.5);
                }
            }
        }
    }
}

// 2. MGN12H Long Carriage Block Module
module mgn12h_carriage() {
    block_w = 27;
    block_l = 45.4; // Standard H-type long block length
    block_h = 10;   // Height of block itself (Total assembly height is 13mm)
    
    hole_w_pitch = 20; // 20mm horizontal spacing
    hole_l_pitch = 20; // 20mm longitudinal spacing
    
    difference() {
        // Main Block Body
        translate([-block_w/2, -block_l/2, 0])
        cube([block_w, block_l, block_h]);
        
        // Bottom Rail Slot Cutout (12.2mm wide for assembly clearance)
        translate([-12.2/2, -(block_l + 2)/2, -0.1])
        cube([12.2, block_l + 2, 4.4]);
        
        // M3 Mounting Hole Matrix (4 Threads)
        // Back Left
        translate([-hole_w_pitch/2, -hole_l_pitch/2, block_h - 4.5]) 
        cylinder(d = 3, h = 5);
        // Back Right
        translate([hole_w_pitch/2, -hole_l_pitch/2, block_h - 4.5]) 
        cylinder(d = 3, h = 5);
        // Front Left
        translate([-hole_w_pitch/2, hole_l_pitch/2, block_h - 4.5]) 
        cylinder(d = 3, h = 5);
        // Front Right
        translate([hole_w_pitch/2, hole_l_pitch/2, block_h - 4.5]) 
        cylinder(d = 3, h = 5);
    }
}
