// =================================================================
// ASSEMBLY MODULE INTEGRATION & TESTING
// =================================================================

// --- TESTING PARAMETERS ---
rail_len_test = 200; // Total length of your linear axis rail
car_pos_test  = "center"; // Use "center" or a number like 45

// --- NEW TOGGLE FLAG ---
// Set to true to show stops, or false to completely hide them:
show_stops_test = true; 

// --- EXECUTE TEST ASSEMBLY ---
mgn12h_with_rail(
    rail_length   = rail_len_test, 
    carriage_pos  = car_pos_test, 
    include_stops = show_stops_test
);



// =================================================================
// 1. COMBINED AXIS ASSEMBLY MODULE (FIXED ORIENTATION)
// =================================================================
module mgn12h_with_rail(rail_length=150, carriage_pos="center", include_stops=true)
{
    // If carriage_pos is set to "center", force it to 0. Otherwise use the number.
    actual_y_pos = (carriage_pos == "center") ? 0 : carriage_pos;

    // 1. Render the physical rail with mounting holes
    mgn_rail(rail_length);
    
    // 2. Render the sliding carriage block
    translate([0, actual_y_pos, 3]) //3mm under carriage, 13mm at top
    mgn12h();
    
    // 3. Render safety physical endstops facing inward correctly
    if (include_stops == true) {
        // Rear Endstop Limit Stop (Rotated 180 to face the center)
        translate([0, (rail_length/2) +2, 0])
        rotate([0, 0, 0]) 
        bottom_stop();
        
        // Front Endstop Limit Stop (Facing the center from the opposite side)
        translate([0, (-rail_length/2) - 2, 0])
        rotate([0, 0, 180])
        bottom_stop();
    }
}

// =================================================================
// 2. UPDATED CARRIAGE BLOCK MODULE
// =================================================================
module mgn12h()
{
    // The local origin (0,0,0) is now the center base floor of the block
    difference()
    {
        union()
        {
            translate([0, 0, 9.4/2]) color("red") cube([26.4, 45.4, 9.4], center=true);
            translate([0, 0, 9.5/2]) color("green") cube([26.5, 42.0, 9.5], center=true);
            translate([0, 0, 10.0/2]) color("silver") cube([27.0, 32.0, 10.0], center=true);
        }
        
        // M3 Mounting Holes (20mm x 20mm grid pattern)
        translate([10, 10, 5])  cylinder(d=3, h=12, $fn=32, center=true);
        translate([10, -10, 5]) cylinder(d=3, h=12, $fn=32, center=true);
        translate([-10, 10, 5]) cylinder(d=3, h=12, $fn=32, center=true);
        translate([-10,-10, 5]) cylinder(d=3, h=12, $fn=32, center=true);
        
        // Cutout pocket profile matches rail head envelope
        translate([0, 0, 0]) mgn_rail_noscrews(55); 
    }
}


// =================================================================
// 3. RAIL PROFILE CUTOUT (NO HOLES)
// =================================================================
module mgn_rail_noscrews(length)
{
    color("silver"){
        difference(){
            // Base floor sits flush at Z=0 and climbs up to Z=8
            translate([0, 0, 4]) cube([12, length, 8], center=true);
            
            // Side grooves for carriage retention guides
            translate([6, 0, 6])  cube([2, length + 2, 1], center=true);
            translate([-6, 0, 6]) cube([2, length + 2, 1], center=true);
        }
    }
}


// =================================================================
// 4. TRUE PHYSICAL RAIL (WITH COUNTERBORE SCREWS)
// =================================================================
module mgn_rail(length)
{
    hole_space = 25;
    min_y = (floor((length / 2) / hole_space) * -hole_space);
    max_y = (floor((length / 2) / hole_space) * hole_space);
    
    color("silver"){
        difference(){
            translate([0, 0, 4]) cube([12, length, 8], center=true);
            
            // Side grooves
            translate([6, 0, 6])  cube([2, length + 2, 1], center=true);
            translate([-6, 0, 6]) cube([2, length + 2, 1], center=true);
            
            // Counterbore Mounting Holes Loop
            for (y = [min_y : hole_space : max_y]){
                if (y > -length/2 + 5 && y < length/2 - 5) {
                    translate([0, y, 0]) {
                        // M3 Pass-through shaft
                        cylinder(d=3.5, h=15, $fn=32, center=true);
                        // Counterbore Cap Head (6mm wide clearance pocket)
                        translate([0, 0, 3.5]) cylinder(d=6, h=5, $fn=32);
                    }
                }
            }
        }
    }
}


// =================================================================
// 5. PHYSICAL ENDSTOP LIMIT BLOCK
// =================================================================
module bottom_stop()
{
    $fn=50;
    extra_space = 0.2;
    screw_diameter_hole = 3.0 + extra_space;
    screw_head_diameter_hole = 5.8 + extra_space;
    rail_width = 12.0 + extra_space;

    // Grounding origin baseline to track on top of the rail surface
    translate([0, 0, 7/2]) {
        difference() {
            hull() {
                translate([-9, -5, 0]) cylinder(h=7, d=2, center = true);
                translate([9, -5, 0])  cylinder(h=7, d=2, center = true);
                translate([-7, 3, 0])  cylinder(h=7, d=6, center = true);
                translate([7, 3, 0])   cylinder(h=7, d=6, center = true);
            }
            union() {
                // Cutout pocket profile mating to the outer rail tracks
                translate([0, -4.5, 0]) cube([rail_width, 5, 9], center = true);

                // Counterbore and screw core drops
                translate([0, 2, 2.1]) cylinder(h=3, d=screw_head_diameter_hole, center = true);
                translate([0, 2, 0])   cylinder(h=7.2, d=screw_diameter_hole, center = true);
            }
        }
    }
}



