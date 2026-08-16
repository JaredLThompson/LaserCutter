// =======================================================================
// DEDICATED METRIC HARDWARE LIBRARY: NUTS, LOCKNUTS, AND WASHERS
// File Name Recommendation: nuts_and_washers.scad
// =======================================================================

// Clean render display setup for all options
translate([-30, 20, 0])  m3_nut();
translate([0, 20, 0])    m4_nut();
translate([30, 20, 0])   m5_nut();

translate([-30, 0, 0])   m3_lock_nut();
translate([0, 0, 0])     m4_lock_nut();
translate([30, 0, 0])    m5_lock_nut();

translate([-30, -20, 0]) m3_washer();
translate([0, -20, 0])   m4_washer();
translate([30, -20, 0])  m5_washer();


// =======================================================================
// STANDARD HEX NUTS (ISO 4032 Profile)
// Orientation: Bottom face sits flat at Z=0, extends UPWARD into +Z space
// =======================================================================

module m3_nut() {
    // Flat-to-Flat width: 5.5mm, Total Thickness: 2.4mm
    color("darkgray")
    difference() {
        cylinder(d=5.5 / cos(30), h=2.4, $fn=6);
        translate([0, 0, -0.5]) cylinder(d=3.2, h=3.4, $fn=32);
    }
}

module m4_nut() {
    // Flat-to-Flat width: 7.0mm, Total Thickness: 3.2mm
    color("darkgray")
    difference() {
        cylinder(d=7.0 / cos(30), h=3.2, $fn=6);
        translate([0, 0, -0.5]) cylinder(d=4.2, h=4.2, $fn=32);
    }
}

module m5_nut() {
    // Flat-to-Flat width: 8.0mm, Total Thickness: 4.7mm
    color("darkgray")
    difference() {
        cylinder(d=8.0 / cos(30), h=4.7, $fn=6);
        translate([0, 0, -0.5]) cylinder(d=5.2, h=5.7, $fn=32);
    }
}


// =======================================================================
// NYLOC LOCK NUTS (ISO 7040 / DIN 985 Profile)
// Orientation: Bottom face sits flat at Z=0, extends UPWARD into +Z space
// =======================================================================

module m3_lock_nut() {
    // Flat-to-Flat width: 5.5mm, Total Height: 4.0mm
    // Hex base height: 2.4mm, Nylon ring collar diameter: 5.0mm
    color("darkgray")
    difference() {
        union() {
            cylinder(d=5.5 / cos(30), h=2.4, $fn=6);
            translate([0, 0, 2.4]) cylinder(d=5.0, h=1.6, $fn=32);
        }
        translate([0, 0, -0.5]) cylinder(d=3.2, h=5.0, $fn=32);
    }
}

module m4_lock_nut() {
    // Flat-to-Flat width: 7.0mm, Total Height: 5.0mm
    // Hex base height: 3.2mm, Nylon ring collar diameter: 6.5mm
    color("darkgray")
    difference() {
        union() {
            cylinder(d=7.0 / cos(30), h=3.2, $fn=6);
            translate([0, 0, 3.2]) cylinder(d=6.5, h=1.8, $fn=32);
        }
        translate([0, 0, -0.5]) cylinder(d=4.2, h=6.0, $fn=32);
    }
}

module m5_lock_nut() {
    // Flat-to-Flat width: 8.0mm, Total Height: 5.0mm
    // Hex base height: 3.2mm, Nylon ring collar diameter: 7.5mm
    color("darkgray")
    difference() {
        union() {
            cylinder(d=8.0 / cos(30), h=3.2, $fn=6);
            translate([0, 0, 3.2]) cylinder(d=7.5, h=1.8, $fn=32);
        }
        translate([0, 0, -0.5]) cylinder(d=5.2, h=6.0, $fn=32);
    }
}


// =======================================================================
// FLAT WASHERS (ISO 7089 Profile)
// Orientation: Bottom face sits flat at Z=0, extends UPWARD into +Z space
// =======================================================================

module m3_washer() {
    // Inner: 3.2mm, Outer: 7.0mm, Thickness: 0.5mm
    color("silver") 
    difference() {
        cylinder(d=7.0, h=0.5, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=3.2, h=0.7, $fn=32);
    }
}

module m4_washer() {
    // Inner: 4.3mm, Outer: 9.0mm, Thickness: 0.8mm
    color("silver") 
    difference() {
        cylinder(d=9.0, h=0.8, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=4.3, h=1.0, $fn=32);
    }
}

module m5_washer() {
    // Inner: 5.3mm, Outer: 10.0mm, Thickness: 1.0mm
    color("silver") 
    difference() {
        cylinder(d=10.0, h=1.0, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=5.3, h=1.2, $fn=32);
    }
}
