// =======================================================================
// FIXED PARAMETRIC M5 BEARING & SHAFT COLLAR HARDWARE LIBRARY
// File Name: m5_bearings.scad
// =======================================================================

// 1. Fixed Layout Preview Setup (Cleans up the translate(undef) parameter issues)
translate([-25, 30, 0]) m5_set_screw_collar(); 
translate([0, 30, 0])   m5_clamping_collar();  

// Fixed reference positions
translate([-25, 0, 0]) bearing_mr105();  
translate([0, 0, 0]) bearing_625();    
translate([25, 0, 0]) bearing_f625();   


// =======================================================================
// M5 SHAFT COLLAR MODULE DEFINITIONS
// =======================================================================

module m5_set_screw_collar() {
    // M5 Solid Set-Screw Shaft Collar
    color("darkgray")
    difference() {
        cylinder(d=10, h=6, $fn=64);
        translate([0, 0, -0.5]) 
            cylinder(d=5, h=6 + 1, $fn=40);
        translate([0, 0, 3])
            rotate([90, 0, 0])
                cylinder(d=3, h=6, $fn=20);
    }
}

module m5_clamping_collar() {
    // M5 Single-Split Clamping Shaft Collar
    color("gray")
    difference() {
        union() {
            cylinder(d=16, h=9, $fn=64);
            translate([0, 5, 4.5])
                cube([10, 6, 9], center=true);
        }
        translate([0, 0, -0.5]) 
            cylinder(d=5, h=9 + 1, $fn=40);
        translate([0, 5, 4.5])
            cube([1.2, 12, 10], center=true);
        translate([-6, 5, 4.5])
            rotate([0, 90, 0])
                cylinder(d=3.2, h=14, $fn=20);
        translate([3, 5, 4.5])
            rotate([0, 90, 0])
                cylinder(d=5.7, h=6, $fn=20);
    }
}


// =======================================================================
// FIXED BEARING MODULE DEFINITIONS (No longer starting with numbers)
// =======================================================================

module bearing_mr105() {
    // MR105 ZZ / 2RS Ball Bearing (5x10x4mm)
    color("silver")
    difference() {
        cylinder(d=10, h=4, $fn=64);
        translate([0, 0, -0.5]) 
            cylinder(d=5, h=4 + 1, $fn=40);
        translate([0, 0, 0.3])
            difference() {
                cylinder(d=9.0, h=3.4, $fn=64);
                translate([0, 0, -0.1]) cylinder(d=6.0, h=3.6, $fn=64);
            }
    }
}

module bearing_625() {
    // 625 ZZ / 2RS Ball Bearing (5x16x5mm)
    color("silver")
    difference() {
        cylinder(d=16, h=5, $fn=64);
        translate([0, 0, -0.5]) 
            cylinder(d=5, h=5 + 1, $fn=40);
        translate([0, 0, 0.4])
            difference() {
                cylinder(d=14.2, h=4.2, $fn=64);
                translate([0, 0, -0.1]) cylinder(d=7.2, h=4.4, $fn=64);
            }
    }
}

module bearing_f625() {
    // F625ZZ Flanged Ball Bearing (5x16x5mm, 18mm flange)
    color("lightgray")
    difference() {
        union() {
            cylinder(d=16, h=5, $fn=64);
            cylinder(d=18, h=1, $fn=64);
        }
        translate([0, 0, -0.5]) 
            cylinder(d=5, h=5 + 1, $fn=40);
        translate([0, 0, 0.4])
            difference() {
                cylinder(d=14.2, h=4.2, $fn=64);
                translate([0, 0, -0.1]) cylinder(d=7.2, h=4.4, $fn=64);
            }
    }
}
