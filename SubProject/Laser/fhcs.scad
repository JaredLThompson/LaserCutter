// =======================================================================
// PARAMETRIC FLAT HEAD COUNTERSUNK SCREW (FHCS) LIBRARY
// =======================================================================

// 1. Render Example Setup
translate([-20, 0, 0]) m3_fhcs(length=8);
translate([0, 0, 0])   m4_fhcs(length=10);
translate([20, 0, 0])  m5_fhcs(length=12); // New M5 Option Added Below

// =======================================================================
// HARDWARE MODULE DEFINITIONS
// =======================================================================

module m3_fhcs(length=8) {
    // M3 Flat Head Countersunk Screw
    // head: 6mm dia at top (wide end flush with surface), tapers to 3mm at shaft
    // shaft: 3mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Conical head (wide end at top, narrows toward shaft)
            translate([0, 0, -1.7])
                cylinder(d1=6, d2=3, h=1.7, $fn=32);
            // Shaft (goes up)
            cylinder(d=3, h=length, $fn=32);
        }
        // Hex drive recess (from the wide/top end)
        translate([0, 0, -1.8])
            cylinder(d=2, h=1.2, $fn=6);
    }
}

module m4_fhcs(length=10) {
    // M4 Flat Head Countersunk Screw
    // head: 8mm dia at top (wide end flush with surface), tapers to 4mm at shaft
    // shaft: 4mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Conical head (wide end at top, narrows toward shaft)
            translate([0, 0, -2.3])
                cylinder(d1=8, d2=4, h=2.3, $fn=32);
            // Shaft (goes up)
            cylinder(d=4, h=length, $fn=32);
        }
        // Hex drive recess (from the wide/top end)
        translate([0, 0, -2.4])
            cylinder(d=2.5, h=1.5, $fn=6);
    }
}

module m5_fhcs(length=12) {
    // M5 Flat Head Countersunk Screw (ISO 10642 / DIN 7991 Standard)
    // head: 11.2mm dia at top (wide end flush with surface), tapers to 5mm at shaft
    // shaft: 5mm dia, variable length
    color("silver")
    difference() {
        union() {
            // Conical head (wide end at top, narrows toward shaft)
            translate([0, 0, -3.1])
                cylinder(d1=11.2, d2=5, h=3.1, $fn=32);
            // Shaft (goes up)
            cylinder(d=5, h=length, $fn=32);
        }
        // Hex drive recess (fits a standard 3mm hex allen key drive)
        translate([0, 0, -3.2])
            cylinder(d=3, h=1.9, $fn=6);
    }
}
