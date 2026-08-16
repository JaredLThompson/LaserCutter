/*
   =============================================================================
   CAD LIBRARY: KP08 PILLOW BLOCK BEARING ASSEMBLY
   Final Master Release - Clean Parameter Architecture & Hardware Fasteners
   =============================================================================
*/

$fn = 120; // High-fidelity curve rendering resolution

// --- USER CUSTOMIZABLE PARAMETERS (METRIC MM) ---
BEARING_BORE_DIA  = 8.0;   // Inner shaft diameter (Φ8mm)
TOTAL_BASE_WIDTH  = 55.0;  // End-to-end mounting flange span (55mm)
TOTAL_ASSEMBLY_H  = 30.0;  // Absolute peak height of cast ring (30mm)
HOUSING_MAX_DEPTH = 14.0;  // Maximum depth of the central barrel (14mm)
MOUNT_HOLE_SPAC   = 42.0;  // Center-to-center fastener alignment (42mm)
SHAFT_CENTER_H    = 15.0;  // Distance from floor to shaft centerline (15mm)

// --- INDEPENDENT CASTING PROFILES ---
BARREL_OUTER_DIA  = 29.0;  // Outer ring profile dimension
FLANGE_WING_DEPTH = 11.5;  // Flange feet are narrower than center block
FLANGE_THICKNESS  = 4.5;   // Base plate floor thickness
FASTENER_HOLE_DIA = 4.8;   // Clearance hole for M4 mounting bolts

module kp08_cast_housing() {
    difference() {
        union() {
            // 1. Central Barrel Housing Block
            translate([0, 0, SHAFT_CENTER_H])
                rotate([90, 0, 0])
                    cylinder(h = HOUSING_MAX_DEPTH - 1, d = BARREL_OUTER_DIA, center = true);
            
            // 2. Raised Front and Back Cast Face Lips
            translate([0, 0, SHAFT_CENTER_H])
                rotate([90, 0, 0])
                    cylinder(h = HOUSING_MAX_DEPTH, d = BARREL_OUTER_DIA - 2, center = true);
            
            // 3. Structural Flange Base Plate
            translate([-MOUNT_HOLE_SPAC/2, -FLANGE_WING_DEPTH/2, 0])
                cube([MOUNT_HOLE_SPAC, FLANGE_WING_DEPTH, FLANGE_THICKNESS]);
            
            // 4. Rounded Flange Foot Ears
            for(side = [-1, 1]) {
                translate([side * MOUNT_HOLE_SPAC/2, 0, 0])
                    cylinder(h = FLANGE_THICKNESS, d = FLANGE_WING_DEPTH, center = false);
            }
            
            // 5. Flared Bottom Rib Webbing (Controls hull pull)
            hull() {
                translate([-BARREL_OUTER_DIA/2 - 2, -FLANGE_WING_DEPTH/2, 0])
                    cube([BARREL_OUTER_DIA + 4, FLANGE_WING_DEPTH, FLANGE_THICKNESS]);
                
                translate([0, 0, SHAFT_CENTER_H])
                    rotate([90, 0, 0])
                        cylinder(h = FLANGE_WING_DEPTH, d = BARREL_OUTER_DIA, center = true);
            }
            
            // 6. Embossed Zinc Foundry Part Number "P08"
            translate([15, FLANGE_WING_DEPTH/2, FLANGE_THICKNESS/2 - 1])
                rotate([90, 0, 0])
                    linear_extrude(height = 1)
                        text("P08", size = 2.8, font = "Liberation Sans:style=Bold", halign = "center");
        }
        
        // 7. Internal Core Spherical Seat Cavity
        translate([0, 0, SHAFT_CENTER_H])
            rotate([90, 0, 0])
                cylinder(h = HOUSING_MAX_DEPTH + 2, d = BARREL_OUTER_DIA - 6, center = true);
                
        // 8. LEFT Concentric Machined Fastener Shelf
        translate([-MOUNT_HOLE_SPAC/2, 0, FLANGE_THICKNESS - 1.5])
            cylinder(h = 5, d = FLANGE_WING_DEPTH - 2.5, center = false);
            
        // 9. RIGHT Concentric Machined Fastener Shelf
        translate([MOUNT_HOLE_SPAC/2 + 0.5, 0, FLANGE_THICKNESS - 1.5])
            cylinder(h = 5, d = FLANGE_WING_DEPTH - 2.5, center = false);

        // 10. Left & Right Through-Holes for Mounting
        translate([-MOUNT_HOLE_SPAC/2, 0, -2]) cylinder(h = FLANGE_THICKNESS + 5, d = FASTENER_HOLE_DIA);
        translate([MOUNT_HOLE_SPAC/2, 0, -2])  cylinder(h = FLANGE_THICKNESS + 5, d = FASTENER_HOLE_DIA);
    }
}

module kp08_rubber_seals() {
    translate([0, 0, SHAFT_CENTER_H])
        rotate([90, 0, 0])
            difference() {
                cylinder(h = HOUSING_MAX_DEPTH - 0.5, d = BARREL_OUTER_DIA - 5.8, center = true);
                cylinder(h = HOUSING_MAX_DEPTH + 2, d = BEARING_BORE_DIA + 3, center = true);
            }
}

module kp08_steel_collar_assembly() {
    collar_protrusion_depth = HOUSING_MAX_DEPTH + 3;
    lock_ring_width = 3.0;
    lock_ring_diameter = BEARING_BORE_DIA + 5.0;
    
    difference() {
        union() {
            // 1. Extended Bearing Inner Race Core Sleeve
            translate([0, 0, SHAFT_CENTER_H])
                rotate([90, 0, 0])
                    cylinder(h = collar_protrusion_depth, d = BEARING_BORE_DIA + 3, center = true);
            
            // 2. Raised Mechanical Lock Collar Ring (Front Protrusion face)
            translate([0, (HOUSING_MAX_DEPTH/2) + 0.5, SHAFT_CENTER_H])
                rotate([90, 0, 0])
                    cylinder(h = lock_ring_width, d = lock_ring_diameter, center = true);
        }
        
        // 3. Clear Open Shaft Bore Axis
        translate([0, 0, SHAFT_CENTER_H])
            rotate([90, 0, 0])
                cylinder(h = HOUSING_MAX_DEPTH + 10, d = BEARING_BORE_DIA, center = true);
                
        // 4. M3 Set Screw Shaft Clearances (Twin 90° Taps cut into collar)
        translate([0, (HOUSING_MAX_DEPTH/2) + 0.5, SHAFT_CENTER_H])
            rotate([0, 0, 0]) // Vertical machine hole
                cylinder(h = BARREL_OUTER_DIA, d = 1.2, center = true);
                
        translate([0, (HOUSING_MAX_DEPTH/2) + 0.5, SHAFT_CENTER_H])
            rotate([0, 90, 0]) // Horizontal machine hole
                cylinder(h = BARREL_OUTER_DIA, d = 1.2, center = true);
    }
    
    // =========================================================================
    // TWIN M3 GRUB SCREW HARDWARE (Protruding slightly into collar sockets)
    // =========================================================================
    grub_offset = (HOUSING_MAX_DEPTH/2) + 0.5;
    grub_height_radius = (lock_ring_diameter / 2) - 0.4;
    
    color("DarkSlateGray") {
        // Screw 1: Vertical Top Locking Position
        translate([0, grub_offset, SHAFT_CENTER_H + grub_height_radius])
            rotate([0, 0, 0])
                cylinder(h = 1.5, d = 2.5, center = true);
                
        // Screw 2: Horizontal Right Locking Position (90-Degree Offset)
        translate([grub_offset, grub_offset, SHAFT_CENTER_H])
            rotate([0, 90, 0])
                cylinder(h = 1.5, d = 2.5, center = true);
    }
}

// =============================================================================
// MAIN ASSEMBLY COMPILER EXECUTION
// =============================================================================
module kp08_pillow_block_assembly() {
  rotate([0,0,90]){
    kp08_cast_housing();
    
    color("DimGray") 
        kp08_rubber_seals();
        
    color("LightSteelBlue") 
        kp08_steel_collar_assembly();
  }//rotate
}

// Call the fully combined assembly module
kp08_pillow_block_assembly();
