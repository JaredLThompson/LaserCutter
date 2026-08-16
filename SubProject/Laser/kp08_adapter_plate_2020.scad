/*
   =============================================================================
   ADAPTER PLATE: 2020 SIDE-MOUNT TO KP08 BEARING
   Features:
   - Drops shaft centerline below top frame surface for laser optical clearance
   - Vertical tension adjustment slots for the 2020 extrusion frame mounts
   - Structural 4.0mm plate thickness to prevent high-tension belt twist
   =============================================================================
*/

$fn = 80; // Smooth curve resolution

// --- METRIC ARCHITECTURE VARIABLES ---
PLATE_THICKNESS = 4.0;   // Sturdy aluminum/steel plate stock width
PLATE_HEIGHT    = 42.0;  // Total vertical plate drop dimension
PLATE_WIDTH     = 55.0;  // Matches the exact width of the KP08 base span

KP08_HOLE_SPACING = 42.0;  // Center-to-center KP08 holes
KP08_BOLT_DIA     = 4.5;   // Clearance for M4 hardware into the bearing ears
KP08_MOUNT_Y      = 8.0;   // Vertical placement of the bearing flange holes

FRAME_HOLE_SPACING = 30.0; // Spacing for twin 2020 T-slot drops
FRAME_BOLT_DIA     = 5.5;  // Clearance for M5 T-nuts/screws into the 2020 frame
SLOT_LENGTH        = 6.0;  // Length of vertical belt tensioning slots

module side_mount_plate() {
    difference() {
        // 1. Core Solid Backing Plate (With slightly rounded lower corners)
        linear_extrude(height = PLATE_THICKNESS) {
            hull() {
                // Top robust mounting bar
                translate([-PLATE_WIDTH/2, 0]) 
                    square([PLATE_WIDTH, 10]);
                // Left lower rounded corner
                translate([-PLATE_WIDTH/2 + 4, -PLATE_HEIGHT + 4]) 
                    circle(r = 4);
                // Right lower rounded corner
                translate([PLATE_WIDTH/2 - 4, -PLATE_HEIGHT + 4]) 
                    circle(r = 4);
            }
        }
        
        // ==========================================
        // CARVING A: FRAME HARDWARE (2020 MOUNTS)
        // ==========================================
        // Vertical slots allow the plate to slide up/down to tension the Y-axis belt
        for(side = [-1, 1]) {
            translate([side * FRAME_HOLE_SPACING / 2, -10, -1]) {
                hull() {
                    translate([0,  SLOT_LENGTH/2, 0]) cylinder(h = PLATE_THICKNESS + 2, d = FRAME_BOLT_DIA);
                    translate([0, -SLOT_LENGTH/2, 0]) cylinder(h = PLATE_THICKNESS + 2, d = FRAME_BOLT_DIA);
                }
            }
        }
        
        // ==========================================
        // CARVING B: BEARING HARDWARE (KP08 MOUNTS)
        // ==========================================
        // Threaded or pass-through holes to receive your final KP08 base ears
        translate([-KP08_HOLE_SPACING/2, -PLATE_HEIGHT + KP08_MOUNT_Y, -1])
            cylinder(h = PLATE_THICKNESS + 2, d = KP08_BOLT_DIA);
            
        translate([KP08_HOLE_SPACING/2, -PLATE_HEIGHT + KP08_MOUNT_Y, -1])
            cylinder(h = PLATE_THICKNESS + 2, d = KP08_BOLT_DIA);
    }
}

// Render the structural adapter stencil
side_mount_plate();
