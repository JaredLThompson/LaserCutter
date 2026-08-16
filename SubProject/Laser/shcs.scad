module m3_shcs(length=8) {
    // M3 Socket Head Cap Screw
    // head: 5.5mm dia, 3mm height (cylindrical)
    // shaft: 3mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Cylindrical head (sits above surface)
            translate([0, 0, -3])
                cylinder(d=5.5, h=3, $fn=32);
            // Shaft (goes up)
            cylinder(d=3, h=length, $fn=32);
        }
        // Hex socket recess (from top of head)
        translate([0, 0, -3.1])
            cylinder(d=2.5, h=2, $fn=6);
    }
}

module m4_shcs(length=10) {
    // M4 Socket Head Cap Screw
    // head: 7mm dia, 4mm height (cylindrical)
    // shaft: 4mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Cylindrical head (sits above surface)
            translate([0, 0, -4])
                cylinder(d=7, h=4, $fn=32);
            // Shaft (goes up)
            cylinder(d=4, h=length, $fn=32);
        }
        // Hex socket recess (from top of head)
        translate([0, 0, -4.1])
            cylinder(d=3, h=2.5, $fn=6);
    }
}

module m5_shcs(length=12) {
    // M5 Socket Head Cap Screw
    // head: 8.5mm dia, 5mm height (cylindrical)
    // shaft: 5mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Cylindrical head (sits above surface)
            translate([0, 0, -5])
                cylinder(d=8.5, h=5, $fn=32);
            // Shaft (goes up)
            cylinder(d=5, h=length, $fn=32);
        }
        // Hex socket recess (from top of head)
        translate([0, 0, -5.1])
            cylinder(d=4, h=3, $fn=6);
    }
}

module m5_bhcs(length=12) {
    // M5 Button Head Cap Screw
    // head: 9.5mm dia, 2.75mm height (low dome)
    // shaft: 5mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Button head (low dome)
            translate([0, 0, -2.75])
                cylinder(d=9.5, h=2.75, $fn=32);
            // Shaft
            cylinder(d=5, h=length, $fn=32);
        }
        // Hex socket recess
        translate([0, 0, -2.8])
            cylinder(d=3.5, h=1.8, $fn=6);
    }
}
