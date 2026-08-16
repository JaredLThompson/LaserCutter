// =======================================================================
// FILENAME: mgn12h_2020_adapter.scad
// PARAMETRIC INTERFACE PLATE WITH DOUBLE-SIDED COUNTERBORES
// =======================================================================

$fn = 64; // Smooth holes for high-quality printing

/* [Hardware Notes & Compatibility] */
// -> RAIL MOUNTING: Designed explicitly for M5 Button Head Cap Screws (BHCS).
//    M5 is the industrial standard for 2020 aluminum extrusions.
//    Requires standard 20-Series M5 drop-in T-nuts or sliding roll-in slot nuts.
// -> CARRIAGE MOUNTING: Designed for standard M3 Socket Head Cap Screws (SHCS)
//    to secure the adapter plate directly to the MGN12H linear block threads.

/* [Bracket Dimensions] */
thickness = 7;    // Increased thickness to handle dual-depth counterbores safely
plate_width = 32;   // Clearance width for 27mm MGN12H block
plate_length = 75;  // Extended length to keep 2020 rail mounts clear of the carriage

/* [Hardware Hole Clearances] */
m3_clear_dia = 3.4;   // Slip-fit shaft for M3 carriage bolts
m3_head_dia = 6.5;    // Fits standard M3 socket head cap screws (SHCS)
m3_head_depth = 3.3;  // Recess depth to completely hide the M3 bolt head

m5_clear_dia = 5.4;   // Slip-fit shaft for M5 extrusion T-bolts
m5_head_dia = 9.5;    // Fits standard M5 low-profile button head screws (BHCS)
m5_head_depth = 3.5;  // Countersink depth for flush frame mounting

// Run the master render call
mgn12h_to_2020_adapter();

module mgn12h_to_2020_adapter() {
    translate([0,0,thickness/2])rotate([0,180,90])color("crimson") difference() {
        // 1. MAIN SOLID BRACKET BODY
        cube([plate_width, plate_length, thickness], center=true);
        
        // 2. MGN12H CARRIAGE BLOCK HOLE PATTERN (20mm x 20mm Grid)
        // Countersunk from the BOTTOM face (pointing up into the carriage)
        for (x = [-10, 10]) {
            for (y = [-10, 10]) {
                translate([x, y, 0]) {
                    // Main bolt shaft tunnel going all the way through
                    translate([0, 0, -thickness])
                        cylinder(d=m3_clear_dia, h=thickness * 2);
                    
                    // Counterbore pocket cut from the bottom face (Z negative zone)
                    translate([0, 0, -thickness/2 - 0.1])
                        cylinder(d=m3_head_dia, h=m3_head_depth + 0.1);
                }
            }
        }
        
        // 3. 2020 ALUMINUM EXTRUSION MOUNTING HOLES (M5 BHCS ONLY)
        // Countersunk from the TOP face (pointing down into the extrusion rail)
        for (y_offset = [-26, 26]) {
            translate([0, y_offset, 0]) {
                // Main bolt shaft tunnel going all the way through
                translate([0, 0, -thickness])
                    cylinder(d=m5_clear_dia, h=thickness * 2);
                
                // Counterbore pocket cut from the top face (Z positive zone)
                translate([0, 0, thickness/2 - m5_head_depth])
                    cylinder(d=m5_head_dia, h=m5_head_depth + 0.1);
            }
        }
        
        // 4. Notch for belt loop ends
        
        for (belt_offset = [-12, 12]) {
            translate([belt_offset, 20, 0]) {
                // Main bolt shaft tunnel going all the way through
                translate([0, 0, -thickness])
                   hull(){
                    translate([0,-4,0])cylinder(d=3, h=thickness * 2);
                    translate([0,4,0])cylinder(d=3, h=thickness * 2);
                   } //hull
            }
        }
    }
}
