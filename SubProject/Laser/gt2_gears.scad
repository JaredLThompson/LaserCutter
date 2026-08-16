// =======================================================================
// PARAMETRIC GT2 PULLEY, IDLER, AND GEAR LIBRARY (ACCURATE MECHANICAL MATH)
// =======================================================================

/* [Global Dimensions] */
// Diameter of the center hole (e.g., 5 for NEMA 17, 3 for M3 screw/bearing)
bore_size = 5; 
// Width of the belt tracking surface in mm (standard is 6 or 10)
belt_width = 6; 

/* [Hidden] */
GT2_PITCH = 2; // Fixed 2mm pitch for GT2 profile
$fn = 64;      // Global rendering smoothness


    
// =======================================================================
// EXAMPLES / TESTING ASSEMBLY
// =======================================================================

// 1. Standard 20-Tooth Drive Pulley (~16.2mm Flange)
translate([-30, 20, 0]) gt2_toothed_pulley(teeth=20, bore=bore_size, width=belt_width, center=true);

// 2. Smooth Idler (Uses standard 20T outer diameter for matching geometry)
translate([0, 20, 0]) gt2_smooth_idler(equivalent_teeth=20, bore=bore_size, width=belt_width, center=true);

// 3. Toothed Idler (20T with dual flanges)
translate([30, 20, 0]) gt2_toothed_idler(teeth=20, bore=bore_size, width=belt_width, center=true);

// 4. Common Alternative Sizes
translate([-35, -20, 0]) gt2_toothed_pulley(teeth=16, bore=bore_size, width=belt_width, center=true); // 16T Pulley
translate([0, -20, 0])   gt2_toothed_pulley(teeth=36, bore=bore_size, width=belt_width, center=true); // 36T Gear

// 5. Corrected 60T Gear (~41.7mm track, ~45.7mm Flange)
translate([40, -20, 0])   gt2_toothed_pulley(teeth=60, bore=bore_size, width=belt_width, center=true, m_shaft_lock_dia=25); 

// =======================================================================
// LIBRARY MODULE DEFINITIONS
// =======================================================================

// Module: Standard Toothed Drive Pulley (Includes dual 90° locking grub screws)
module gt2_toothed_pulley(teeth=20, bore=5, width=6, center=false, m_shaft_lock_dia=0) {
    pitch_dia = (teeth * GT2_PITCH) / PI;
    outer_dia = pitch_dia - 0.508; 
    flange_dia = outer_dia + 4; // Adds standard 2mm lip radially
    collar_dia = (m_shaft_lock_dia > 0) ? (m_shaft_lock_dia + 2) : (outer_dia + 2);
    
    // Ensure grub screws cut all the way through the collar regardless of size
    max_radius = max(flange_dia, collar_dia) / 2;
    screw_length = max_radius + 5; 
    
    total_ht = width + 2 + 7;      // Belt width + flange thickness + collar height
    
    z_offset = center ? -(total_ht / 2) : 0;
    
    translate([0, 0, z_offset]) {
        difference() {
            union() {
                // Main Toothed Body
                gt2_raw_gear_body(teeth, width + 2);
                
                // Bottom Flange
                cylinder(h=1, r=flange_dia/2);
                
                // Top Flange
                translate([0, 0, width + 1]) 
                    cylinder(h=1, r=flange_dia/2);
                    
                // Motor Shaft Locking Collar
                translate([0, 0, width + 2]) 
                    cylinder(h=7, r=collar_dia/2);
            }
            // Center Bore
            translate([0, 0, -1]) 
                cylinder(h=total_ht + 2, r=bore/2, $fn=40);
                
            // Grub Screw 1 (0 Degrees)
            translate([0, 0, width + 5.5])
                rotate([0, 90, 0])
                    cylinder(h=screw_length, r=1.5, $fn=20);
                    
            // Grub Screw 2 (90 Degrees)
            translate([0, 0, width + 5.5])
                rotate([0, 90, 90])
                    cylinder(h=screw_length, r=1.5, $fn=20);
        }
    }
}

// Module: Toothed Idler (Flanged pulley without a motor shaft collar)
module gt2_toothed_idler(teeth=20, bore=5, width=6, center=false) {
    pitch_dia = (teeth * GT2_PITCH) / PI;
    outer_dia = pitch_dia - 0.508;
    flange_dia = outer_dia + 4;
    total_ht = width + 2; 
    
    z_offset = center ? -(total_ht / 2) : 0;
    
    translate([0, 0, z_offset]) {
        difference() {
            union() {
                gt2_raw_gear_body(teeth, total_ht);
                
                // Bottom Flange
                cylinder(h=1, r=flange_dia/2);
                
                // Top Flange
                translate([0, 0, total_ht - 1]) 
                    cylinder(h=1, r=flange_dia/2);
            }
            // Center Bore
            translate([0, 0, -1]) 
                cylinder(h=total_ht + 2, r=bore/2, $fn=40);
        }
    }
}

// Module: Smooth Idler (Matches equivalent tooth diameters)
module gt2_smooth_idler(equivalent_teeth=20, bore=5, width=6, center=false) {
    pitch_dia = (equivalent_teeth * GT2_PITCH) / PI;
    outer_dia = pitch_dia - 0.508;
    flange_dia = outer_dia + 4;
    total_ht = width + 2;
    
    z_offset = center ? -(total_ht / 2) : 0;
    
    translate([0, 0, z_offset]) {
        difference() {
            union() {
                // Smooth rolling surface
                cylinder(h=total_ht, r=outer_dia/2);
                
                // Bottom Flange
                cylinder(h=1, r=flange_dia/2);
                
                // Top Flange
                translate([0, 0, total_ht - 1]) 
                    cylinder(h=1, r=flange_dia/2);
            }
            // Center Bore
            translate([0, 0, -1]) 
                cylinder(h=total_ht + 2, r=bore/2, $fn=40);
        }
    }
}

// Low-level Module: Generates the raw tooth mesh via geometric subtraction
module gt2_raw_gear_body(teeth, height) {
    pitch_dia = (teeth * GT2_PITCH) / PI;
    outer_dia = pitch_dia - 0.508;
    
    difference() {
        cylinder(h=height, r=outer_dia/2);
        
        for (i = [0 : teeth - 1]) {
            rotate([0, 0, i * (360 / teeth)])
                translate([pitch_dia / 2, 0, -1])
                    cylinder(h=height + 2, r=0.555, $fn=20);
        }
    }
}
