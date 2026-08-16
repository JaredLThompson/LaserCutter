// =======================================================================
// REALISTIC NEMA 17 STEPPER MOTOR LIBRARY
// File Name Recommendation: nema17_motor.scad
// =======================================================================

// Example Render Call
// Bottom face sits at Z=0, shaft points straight UP (+Z) for easy local positioning
nema17_stepper(body_length=40, shaft_length=24);


// =======================================================================
// LIBRARY MODULE DEFINITIONS
// =======================================================================

module nema17_stepper(body_length=40, shaft_length=24) {
    // Standard NEMA 17 Dimensions (42.3mm x 42.3mm faceplate)
    width = 42.3;
    corner_radius = 5.0;
    
    color("DarkSlateGray") {
        difference() {
            // 1. MAIN MOTOR BODY
            // Generates a smooth, rounded square body shape
            linear_extrude(height=body_length) {
                offset(r=corner_radius, $fn=32) {
                    square([width - corner_radius*2, width - corner_radius*2], center=true);
                }
            }
            
            // 2. CORNER PROFILE NOTCHES
            // Cuts out the 4 shiny metallic corner steps seen on real steppers
            for(x = [-width/2, width/2]) {
                for(y = [-width/2, width/2]) {
                    translate([x, y, body_length/2])
                        cube([4, 4, body_length + 2], center=true);
                }
            }
            
            // 3. FRONT FACE M3 MOUNTING THREADS (31mm x 31mm square spacing)
            for(x = [-15.5, 15.5]) {
                for(y = [-15.5, 15.5]) {
                    translate([x, y, body_length - 4.5])
                        cylinder(d=3, h=5, $fn=16);
                }
            }
            
            // 4. REAR JST ELECTRICAL PLUG PORT
            translate([0, -width/2 + 2, 8])
                cube([16, 6, 10], center=true);
        }
    }
    
    // 5. METALLIC FRONT REGISTRATION BOSS (22mm standard diameter locator ring)
    color("silver") 
        translate([0, 0, body_length - 0.01])
            cylinder(d=22, h=2, $fn=64);
            
    // 6. PRECISION STEEL D-PROFILE DRIVE SHAFT
    color("lightgray") {
        translate([0, 0, body_length + 2]) {
            difference() {
                // Main 5mm diameter steel shaft cylinder
                cylinder(d=5, h=shaft_length, $fn=40);
                
                // Flat D-cut slice (Shaves off 0.5mm from the side, starting 4mm up from the base)
                translate([2, -5, 4])
                    cube([5, 10, shaft_length + 1]);
            }
        }
    }
}
