/*
   =============================================================================
   PRODUCTION SUITE: DUAL-ENDED "SHOESTRING" BELT TENSIONER
   - MASTER RELEASE: Rotated to anchor on an X-axis parallel 2020 rail.
   - WIDENED CHASSIS: Expanded width to 32mm for a massive stability upgrade.
   - COUNTERSUNK MOUNTING BORES: Completely buries M5 bolt heads below the tracks.
   =============================================================================
*/

$fn = 80;

// --- GLOBAL METRIC CONFIGURATION ---
HOUSING_W     = 32.0; // WIDENED from 24mm to 32mm for clearance and stability
HOUSING_L     = 40.0; // Total track length
HOUSING_H     = 12.0; // Total housing block thickness
COVER_H       = 3.5;  // Heavy duty clamp lid thickness

BELT_PITCH    = 2.0;  // Standard GT2 2mm timing belt pitch
TOOTH_H       = 0.75; // GT2 tooth depth
BELT_CH_W     = 7.0;  // Fits standard 6mm width timing belts cleanly

PULL_BOLT_DIA = 3.4;  // M3 clearance hole
NUT_HEX_W     = 5.6;  // M3 nut flat-to-flat width
NUT_HEX_H     = 2.4;  // M3 nut thickness
SCREW_Z       = 4.5;  // Core tensioning height axis

CLAMP_SCREW_D = 2.4;  // M2.5 binding cover screws
BRACKET_WALL  = 3.0;  // Structural frame walls
FRAME_BOLT_D  = 5.5;  // M5 T-slot mounting clearance
FRAME_HEAD_D  = 10.0; // Diameter for standard M5 socket/low-profile cap head
FRAME_HEAD_H  = 5.0;  // Depth to sink the bolt head below the track floor

// =============================================================================
// PART 1: THE WIDENED X-AXIS HOUSING FRAME WITH COUNTERSUNKS
// =============================================================================
module dual_track_housing() {
    difference() {
        union() {
            // Main widened chassis block
            translate([-HOUSING_W/2, -HOUSING_L/2, 0])
                cube([HOUSING_W, HOUSING_L, HOUSING_H]);
                
            // Left-to-right 2020 Slot Alignment Rail underneath the floor
            translate([-HOUSING_W/2, -2.9, -1.5])
                cube([HOUSING_W, 5.8, 1.5]);
        }
        
        // LEFT TRACK: Fixed anchor bay pocket
        translate([-HOUSING_W/2 + 3, -HOUSING_L/2 - 1, 3.5])
            cube([BELT_CH_W, HOUSING_L + 2, HOUSING_H + 1]);
            
        // RIGHT TRACK: Main slider channel
        translate([HOUSING_W/2 - 3 - BELT_CH_W - 1.0, -HOUSING_L/2 + 3, 3.5])
            cube([BELT_CH_W + 1.0, HOUSING_L + 2, HOUSING_H + 1]);
            
        // FIXED LEFT SIDE TOOTH BED
        for (y_pos = [-HOUSING_L/2 + 4 : BELT_PITCH : HOUSING_L/2 - 4]) {
            translate([-HOUSING_W/2 + 3, y_pos - (BELT_PITCH/4), 3.5 - TOOTH_H])
                cube([BELT_CH_W, BELT_PITCH/2, TOOTH_H + 0.1]);
        }

        // THE FIXED ANCHOR HOLE (Centered perfectly behind the right sliding track)
        translate([HOUSING_W/2 - 3 - (BELT_CH_W/2) - 0.5, -HOUSING_L/2 - 1, SCREW_Z + 3.5]) 
            rotate([-90, 0, 0])
                cylinder(h = 6, d = PULL_BOLT_DIA);

        // COUNTERSUNK M5 FASTENER HOLES: Shifted left and right along the X-axis rail line
        // Left Track Mount
        translate([-11, 0, -5]) {
            cylinder(h = 30, d = FRAME_BOLT_D); // Main threads pass-through
            translate([0, 0, 8.5]) 
                cylinder(h = FRAME_HEAD_H + 1, d = FRAME_HEAD_D); // Deep head recess
        }
        // Right Track Mount
        translate([11, 0, -5]) {
            cylinder(h = 30, d = FRAME_BOLT_D); // Main threads pass-through
            translate([0, 0, 8.5]) 
                cylinder(h = FRAME_HEAD_H + 1, d = FRAME_HEAD_D); // Deep head recess
        }
        
        // Lid Mounting Holes (Columns moved out to the wide corners)
        translate([-HOUSING_W/2 + 1.5, -HOUSING_L/2 + 3, 2]) cylinder(h = HOUSING_H, d = CLAMP_SCREW_D - 0.2);
        translate([ HOUSING_W/2 - 1.5, -HOUSING_L/2 + 3, 2]) cylinder(h = HOUSING_H, d = CLAMP_SCREW_D - 0.2);
        translate([-HOUSING_W/2 + 1.5,  HOUSING_L/2 - 3, 2]) cylinder(h = HOUSING_H, d = CLAMP_SCREW_D - 0.2);
        translate([ HOUSING_W/2 - 1.5,  HOUSING_L/2 - 3, 2]) cylinder(h = HOUSING_H, d = CLAMP_SCREW_D - 0.2);
    }
}



// =============================================================================
// PART 2: THE SLIDING PULL-JACK (With Reconstructed Independent Wrap Pin)
// =============================================================================
module right_tension_slider() {
    slider_l = 18.0;
    
    // 1. Cut channels and holes out of the core slider block first
    difference() {
        // Slider runner core block
        translate([0, -slider_l/2, 0])
            cube([BELT_CH_W, slider_l, HOUSING_H - 4.5]);
        
        // Slider belt channel runway
        translate([0.5, -slider_l/2 - 1, HOUSING_H - 7.5])
            cube([BELT_CH_W - 1.0, slider_l + 2, 4]);
            
        // Slider floor lock teeth
        for (y_pos = [-slider_l/2 + 2 : BELT_PITCH : slider_l/2 - 2]) {
            translate([0.5, y_pos - (BELT_PITCH/4), HOUSING_H - 7.5 - TOOTH_H])
                cube([BELT_CH_W - 1.0, BELT_PITCH/2, TOOTH_H + 0.1]);
        }

        // Center thread tunnel for the M3 jack screw
        translate([BELT_CH_W/2, -slider_l/2 - 1, SCREW_Z])
            rotate([-90, 0, 0])
                cylinder(h = slider_l + 2, d = PULL_BOLT_DIA);
                
        // HORIZONTAL NUT POCKET 
        translate([BELT_CH_W/2, -slider_l/2 + 6, SCREW_Z])
            cylinder(h = NUT_HEX_H, d = NUT_HEX_W * 1.15, $fn=6, center=true);
                
        // DROP-SLOT ENTRY
        translate([BELT_CH_W/2 - (NUT_HEX_W/2), -slider_l/2 + 6 - (NUT_HEX_H/2), -1])
            cube([NUT_HEX_W, NUT_HEX_H, SCREW_Z + 0.5]);
    }
    
    // 2. ADD THE PIN AFTER THE CUTS: Spans horizontally across the track mouth safely
    color("DarkOrange")
    translate([BELT_CH_W/2, slider_l/2 - 1.5, HOUSING_H - 5.5])
        rotate([0, 90, 0]) // Correct horizontal axis rotation vector
            cylinder(h = BELT_CH_W, d = 3.0, center = true);
}




// =============================================================================
// PART 3: TOP DUAL-PRESSURE CLAMP & SLIP-GUIDE COVER
// =============================================================================
module dual_clamp_cover() {
    difference() {
        union() {
            // Main cover backing slab
            translate([-HOUSING_W/2 + 0.5, -HOUSING_L/2 + 0.5, 0])
                *cube([HOUSING_W - 1.0, HOUSING_L - 1.0, COVER_H]);
            
            // LEFT SIDE: Downward tooth pressure vise
            for (y_pos = [-HOUSING_L/2 + 6 : BELT_PITCH : HOUSING_L/2 - 6]) {
                translate([-HOUSING_W/2 + 3.5, y_pos - (BELT_PITCH/4), -TOOTH_H])
                    *cube([BELT_CH_W - 1.0, BELT_PITCH/2, TOOTH_H]);
            }
            
            // RIGHT SIDE: Smooth captive anti-skip slip extension
            translate([HOUSING_W/2 - 3 - BELT_CH_W - 0.5, -HOUSING_L/2 + 4, -2.0])
                *cube([BELT_CH_W - 0.5, HOUSING_L - 8, 2.0]);
        }
            
        // Lid screw holes
        translate([-HOUSING_W/2 + 1.5, -HOUSING_L/2 + 3, -1]) cylinder(h = COVER_H + 2, d = CLAMP_SCREW_D + 0.3);
        translate([ HOUSING_W/2 - 1.5, -HOUSING_L/2 + 3, -1]) cylinder(h = COVER_H + 2, d = CLAMP_SCREW_D + 0.3);
        translate([-HOUSING_W/2 + 1.5,  HOUSING_L/2 - 3, -1]) cylinder(h = COVER_H + 2, d = CLAMP_SCREW_D + 0.3);
        translate([ HOUSING_W/2 - 1.5,  HOUSING_L/2 - 3, -1]) cylinder(h = COVER_H + 2, d = CLAMP_SCREW_D + 0.3);
    }
}

// =============================================================================
// MECHANICAL ASSEMBLY VIEW
// =============================================================================

// 1. Structural Fixed Housing Frame (Widen to 32mm with M5 Countersinks)
dual_track_housing();

// 2. Sliding Tension Core (Shifted to match the new wide track coordinate alignment)
translate([HOUSING_W/2 - 3 - BELT_CH_W - 1.0, -3, 3.5])
    color("LightGray")
        right_tension_slider();

// 3. Dual-Action Clamping Lid (Floating 6mm above for review)
translate([0, 0, HOUSING_H + 6.0])
    color("LightBlue")
        dual_clamp_cover();
