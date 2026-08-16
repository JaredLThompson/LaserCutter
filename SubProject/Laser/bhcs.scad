// =======================================================================
// FIXED PARAMETRIC BUTTON HEAD CAP SCREW (BHCS) LIBRARY
// =======================================================================

// Clean render display setup
translate([-25, 0, 0]) m3_bhcs(length=8);
translate([0, 0, 0])   m4_bhcs(length=10);
translate([25, 0, 0])  m5_bhcs(length=12);

// =======================================================================
// FIXED HARDWARE MODULE DEFINITIONS (ISO 7380 Standard)
// =======================================================================

module m3_bhcs(length=8) {
    // head: 5.7mm dia, 1.65mm height dome profile
    // shaft: 3mm dia, variable length
    color("silver")
    difference() {
        union() {
            // 1. Create the rounded dome head profile
            difference() {
                scale([1, 1, 1.65 / (5.7 / 2)]) 
                    sphere(d=5.7, $fn=32);
                
                // Cut away ONLY the bottom half of the sphere
                translate([0, 0, -5]) 
                    cube([15, 15, 10], center=true);
            }
            
            // 2. Threaded shaft extending DOWNWARD from the head base
            translate([0, 0, -length])
                cylinder(d=3, h=length, $fn=32);
        }
        
        // 3. Hex drive recess socket cut out from the top center
        translate([0, 0, 1.65 - 1.3])
            cylinder(d=2.0 / cos(30), h=1.5, $fn=6);
    }
}

module m4_bhcs(length=10) {
    // head: 7.6mm dia, 2.2mm height dome profile
    // shaft: 4mm dia, variable length
    color("silver")
    difference() {
        union() {
            difference() {
                scale([1, 1, 2.2 / (7.6 / 2)]) 
                    sphere(d=7.6, $fn=32);
                translate([0, 0, -5]) 
                    cube([15, 15, 10], center=true);
            }
            translate([0, 0, -length])
                cylinder(d=4, h=length, $fn=32);
        }
        translate([0, 0, 2.2 - 1.6])
            cylinder(d=2.5 / cos(30), h=1.8, $fn=6);
    }
}

module m5_bhcs(length=12) {
    // head: 9.5mm dia, 2.75mm height dome profile
    // shaft: 5mm dia, variable length
    color("silver")
    difference() {
        union() {
            difference() {
                scale([1, 1, 2.75 / (9.5 / 2)]) 
                    sphere(d=9.5, $fn=32);
                translate([0, 0, -5]) 
                    cube([15, 15, 10], center=true);
            }
            translate([0, 0, -length])
                cylinder(d=5, h=length, $fn=32);
        }
        translate([0, 0, 2.75 - 2.1])
            cylinder(d=3.0 / cos(30), h=2.3, $fn=6);
    }
}
