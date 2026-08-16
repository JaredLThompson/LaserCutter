// 2020 Aluminum Extrusion Module
// Standard 20mm x 20mm T-slot profile


mgn12h_rail_assembly();



module 2020_extrusion(length=100) {
    color("LightGray")
    linear_extrude(height=length)
        2020_profile();
}

module 2020_profile() {
    difference() {
        square([20,20], center=true);
        square([17,17], center=true);
        square([40,5.26], center=true);
        rotate([0,0,90]) square([40,5.26], center=true);
    }

    difference() {
        union() {
            square([7.32,7.32], center=true);
            rotate([0,0,45]) square([1.5,25], center=true);
            rotate([0,0,-45]) square([1.5,25], center=true);
        }
        circle(d=5, $fn=16);
    }

    translate([7.9975,7.9975,0]) square([4.005,4.005], center=true);
    translate([-7.9975,7.9975,0]) square([4.005,4.005], center=true);
    translate([7.9975,-7.9975,0]) square([4.005,4.005], center=true);
    translate([-7.9975,-7.9975,0]) square([4.005,4.005], center=true);
}

// MGN12H Linear Rail
// Cross-section profile based on HIWIN/generic specs
module mgn12_rail_profile() {
    polygon(points=[
        [-6, 0], [6, 0],
        [6, 3.5],
        [3.5, 7], [2.5, 7],
        [2.5, 8], [-2.5, 8],
        [-2.5, 7], [-3.5, 7],
        [-6, 3.5]
    ]);
}

module mgn12_rail(length=100) {
    color("DarkGray")
    linear_extrude(height=length)
        mgn12_rail_profile();
}

// MGN12H Carriage Block
module mgn12h_carriage() {
    // Origin at top-center of carriage (mounting surface)
    // Carriage body: 27mm wide (X), 40mm long (Y), 13mm tall (Z)
    // Mounting holes on top face: 20mm x 20mm pattern
    // Rail channel runs through the bottom portion
    
    color("SlateGray")
    difference() {
        // Carriage body - top face at Z=0, body goes down
        translate([-13.5, -20, -13])
            cube([27, 40, 13]);
        
        // Rail channel (bottom center) - 12.2mm wide, 8.5mm tall
        translate([-6.1, -21, -13.1])
            cube([12.2, 42, 8.5]);
        
        // Mounting holes - 20mm x 20mm pattern, M3 from top
        for (x = [-10, 10])
            for (y = [-10, 10])
                translate([x, y, -13.1])
                    cylinder(d=3.2, h=14, $fn=24);
    }
}

// Assembly: Rail mounted on 2020 extrusion with carriage
// Everything runs along X axis. Y=0 centered. Z up.
module mgn12h_rail_assembly(rail_length=100) {
    rail_offset = 15;
    
    // 2020 Extrusion along X
    rotate([0, 90, 0])
        2020_extrusion(rail_length);
    
    // MGN12 Rail along X, sitting on extrusion top face (Z=10)
    translate([rail_offset, 0, 10])
    rotate([90, 0, 90])
        mgn12_rail(rail_length - 2*rail_offset);
    
    // Carriage centered on rail at midpoint
    translate([rail_length/2, 0, 22.5])
      rotate([0,0,90])
        mgn12h_carriage();
}
