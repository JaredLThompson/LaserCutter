// X Axis Drive Components
// GT2 belt system with 3:1 reduction
// NEMA 17 motor, 5mm shaft, 625ZZ bearings, 6mm belt
// For reference:
//    X = width (left-to-right / along X rail)
//    Y = depth (front-to-back)
//    Z = height (vertical)

use <shcs.scad>;
use <mgn12h-rail.scad>;


$fn=64;

translate([-100,0,-10])rotate([0,90,0])2020_extrusion(200);
x_drive_assembly();

translate([-50,0,0])x_idler_assembly();



// === X Axis Drive Assembly ===
// Direct drive: NEMA 17 + 20T pulley on flat mount plate

module x_drive_assembly() {
    motor_z = 25;
    plate_t = 3;
    
    // Motor mount plate
    translate([0,12,50])rotate([0,180,0])drive_gearbox();
    
    // NEMA 17 motor (behind plate, Y-)
    translate([0, plate_t/2+12, motor_z])
        rotate([90, 0, 0])
            nema17();
    
    // 20T pulley on motor shaft (front/belt side, Y+)
    translate([0, plate_t/2 + 2, motor_z])
        rotate([90, 0, 0])
            gt2_pulley(teeth=20, bore=5);
}


module drive_gearbox(){
    // NEMA 17 flat motor mount plate
    // Vertical plate in XZ plane, Y thickness
    // Motor behind (Y-), pulley in front (Y+)
    
    plate_w = 45;
    plate_h = 70;
    plate_t = 3;
    motor_z = 25;
    
    color("DimGray")
    difference() {
        translate([-plate_w/2, -plate_t/2, 0])
            cube([plate_w, plate_t, plate_h]);
        
        // NEMA 17 boss hole (through Y)
        translate([0, -plate_t/2-1, motor_z])
            rotate([-90, 0, 0])
                cylinder(d=nema17_boss_dia+1, h=plate_t+2);
        
        // NEMA 17 mounting holes
        for (dx = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
            for (dz = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
                translate([dx, -plate_t/2-1, motor_z+dz])
                    rotate([-90, 0, 0])
                        cylinder(d=3.4, h=plate_t+2);
        
        // Extrusion mounting slots (upper portion, through Y)
        for (dx = [-10, 10])
            translate([dx, -plate_t/2-1, 50])
                rotate([-90, 0, 0])
                    hull() {
                        cylinder(d=4.5, h=plate_t+2);
                        translate([0, 5, 0])
                            cylinder(d=4.5, h=plate_t+2);
                    }
        for (dx = [-10, 10])
            translate([dx, -plate_t/2-1, 60])
                rotate([-90, 0, 0])
                    hull() {
                        cylinder(d=4.5, h=plate_t+2);
                        translate([0, 5, 0])
                            cylinder(d=4.5, h=plate_t+2);
                    }
    }
}

// === Parameters ===

// GT2 Pulley specs (pitch diameter = teeth * 2mm / PI)
pulley_20t_pd = 20 * 2 / 3.14159;   // ~12.73mm
pulley_60t_pd = 60 * 2 / 3.14159;   // ~38.20mm
pulley_16t_pd = 16 * 2 / 3.14159;   // ~10.19mm

// Bearing: 625ZZ (5mm bore, 16mm OD, 5mm thick)
bearing_id = 5;
bearing_od = 16;
bearing_width = 5;

// Shaft
shaft_dia = 5;

// Belt
belt_width = 6;

// Reduction loop: 120mm belt, 20T motor + 60T shaft
// Center distance ~20mm
reduction_center_dist = 20;

// NEMA 17
nema17_width = 42.3;
nema17_hole_spacing = 31;  // hole-to-hole
nema17_boss_dia = 22;
nema17_boss_height = 2;
nema17_shaft_dia = 5;
nema17_shaft_length = 24;

// Block dimensions
block_width = 30;       // along shaft axis (Y)
block_depth = 30;       // perpendicular to shaft (X)
block_height = 20;      // base height (Z)
pillow_height = 12;     // bearing pillow above base
pillow_width = 20;      // bearing pillow width (Y)
pillow_thickness = 8;   // wall thickness around bearing

// === Modules ===

// GT2 Pulley (simplified - drive pulley with hub)
module gt2_pulley(teeth=20, bore=5, belt_w=6) {
    pd = teeth * 2 / 3.14159;
    od = pd + 1.5;  // tooth tip
    flange_od = od + 4;
    
    color("Silver")
    difference() {
        union() {
            // Bottom flange
            cylinder(d=flange_od, h=1);
            // Tooth section
            translate([0, 0, 1])
                cylinder(d=od, h=belt_w+1);
            // Top flange
            translate([0, 0, belt_w+2])
                cylinder(d=flange_od, h=1);
            // Hub below
            translate([0, 0, -4])
                cylinder(d=bore+6, h=4);
        }
        // Bore
        translate([0, 0, -5])
            cylinder(d=bore, h=belt_w+12);
    }
}

// GT2 Idler Pulley (smooth or toothed, no hub, just flanges + bore with bearing)
module gt2_idler(teeth=20, bore=5, belt_w=6) {
    pd = teeth * 2 / 3.14159;
    od = pd + 1.5;
    flange_od = od + 4;
    
    color("Silver")
    difference() {
        union() {
            // Bottom flange
            cylinder(d=flange_od, h=1);
            // Tooth/smooth section
            translate([0, 0, 1])
                cylinder(d=od, h=belt_w+1);
            // Top flange
            translate([0, 0, belt_w+2])
                cylinder(d=flange_od, h=1);
        }
        // Bore (bearing sits inside)
        translate([0, 0, -1])
            cylinder(d=bore, h=belt_w+5);
    }
}

// 625ZZ Bearing
module bearing_625() {
    color("LightGray")
    difference() {
        cylinder(d=bearing_od, h=bearing_width);
        translate([0, 0, -1])
            cylinder(d=bearing_id, h=bearing_width+2);
    }
}

// Shaft
module shaft(length=40) {
    color("Silver")
    cylinder(d=shaft_dia, h=length);
}

// Drive gearbox - enclosed housing with motor mount
// Inspired by the C3/C10 intermediate motor base
// Motor mounts to front face (Y-), output shaft exits back face (Y+)
// Open top for belt access
// Shafts run along Y axis, separated in X by center_dist
// Mounts to 2020 extrusion via bottom AND side
module drive_gearbox_old() {
    // Center distance between motor shaft and output shaft (along X)
    center_dist = 30;
    
    // Box dimensions based on clearances needed
    wall = 5;
    // X: needs to span both shafts + clearance for 60T pulley
    box_x = center_dist + pulley_60t_pd + 10;
    // Y: depth for pulleys + belt width
    box_y = belt_width + 16;
    // Z: height to clear 60T pulley from bottom
    box_z = pulley_60t_pd/2 + 20;
    
    // Shaft Z height (centered vertically with room below)
    shaft_z = box_z/2 + 5;
    
    // Motor center (left side)
    motor_x = -center_dist/2;
    // Output center (right side)
    output_x = center_dist/2;
    
    color("DimGray")
    difference() {
        union() {
            // Main box
            translate([-box_x/2, -box_y/2, 0])
                cube([box_x, box_y, box_z]);
        }
        
        // Hollow out (open top, leave walls and floor)
        translate([-box_x/2 + wall, -box_y/2 + wall, wall])
            cube([box_x - 2*wall, box_y - 2*wall, box_z]);
        
        // === Motor side (front face, Y-) ===
        
        // Motor boss hole
        translate([motor_x, -box_y/2 - 1, shaft_z])
            rotate([-90, 0, 0])
                cylinder(d=nema17_boss_dia + 1, h=wall+2);
        
        // Motor shaft clearance
        translate([motor_x, -box_y/2 - 1, shaft_z])
            rotate([-90, 0, 0])
                cylinder(d=shaft_dia + 2, h=box_y);
        
        // NEMA 17 mounting holes
        for (dx = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
            for (dz = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
                translate([motor_x + dx, -box_y/2 - 1, shaft_z + dz])
                    rotate([-90, 0, 0])
                        cylinder(d=3.2, h=wall+2);
        
        // === Output side ===
        
        // Output bearing pocket (back wall, Y+)
        translate([output_x, box_y/2 - wall - bearing_width, shaft_z])
            rotate([-90, 0, 0])
                cylinder(d=bearing_od + 0.2, h=bearing_width + 1);
        
        // Output bearing pocket (front wall, Y-)
        translate([output_x, -box_y/2 - 1, shaft_z])
            rotate([-90, 0, 0])
                cylinder(d=bearing_od + 0.2, h=bearing_width + 1);
        
        // Output shaft through-hole (both walls)
        translate([output_x, -box_y/2 - 1, shaft_z])
            rotate([-90, 0, 0])
                cylinder(d=shaft_dia + 0.5, h=box_y+2);
        
        // === Bottom mounting (into extrusion top slot) ===
        for (x = [-15, 15])
            translate([x, 0, -1])
                cylinder(d=4.2, h=wall+2);
        
        // === Side mounting (into extrusion side slot) ===
        // Holes through left and right walls
        translate([-box_x/2 - 1, 0, shaft_z])
            rotate([0, 90, 0])
                cylinder(d=4.2, h=wall+2);
        translate([box_x/2 - wall, 0, shaft_z])
            rotate([0, 90, 0])
                cylinder(d=4.2, h=wall+2);
    }
}




// === X Axis Drive Assembly ===
// Enclosed gearbox with motor and reduction pulleys
module x_drive_assembly_duplicate() {
    center_dist = 30;
    wall = 5;
    box_y = belt_width + 16;
    box_z = pulley_60t_pd/2 + 20;
    shaft_z = box_z/2 + 5;
    motor_x = -center_dist/2;
    output_x = center_dist/2;
    
    // Gearbox housing
    drive_gearbox();
    
    // NEMA 17 motor (bolted to front face Y-)
    translate([motor_x, -box_y/2, shaft_z])
        rotate([90, 0, 0])
            nema17();
    
    // 20T pulley on motor shaft (inside box)
    translate([motor_x, -box_y/2 + wall + 2, shaft_z])
        rotate([-90, 0, 0])
            gt2_pulley(teeth=20, bore=5);
    
    // Output shaft (through back wall)
    translate([output_x, -5, shaft_z])
        rotate([-90, 0, 0])
            shaft(box_y/2 + 15);
    
    // 60T pulley on output shaft (inside box)
    translate([output_x, -box_y/2 + wall + 2, shaft_z])
        rotate([-90, 0, 0])
            gt2_pulley(teeth=60, bore=5);
    
    // 20T pulley on output shaft (outside box back, drives X belt)
    translate([output_x, box_y/2 + 2, shaft_z])
        rotate([-90, 0, 0])
            gt2_pulley(teeth=20, bore=5);
}

// Idler block - pulley spins on M5 BHCS as axle
// Mounting holes from bottom for roll-in T-nuts
module idler_block() {
    base_width = 30;        // X dimension
    base_depth = 24;        // Y dimension
    base_height = 16;       // Z height of base (raised 6mm to match belt height)
    wall_height = 18;       // bearing wall height above base
    wall_thickness = 5;     // Y thickness of each wall
    wall_gap = belt_width + 4;  // gap between walls for pulley
    
    color("DimGray")
    difference() {
        union() {
            // Flat base
            translate([-base_width/2, -base_depth/2, 0])
                cube([base_width, base_depth, base_height]);
            
            // Left wall
            translate([-base_width/2, -wall_gap/2 - wall_thickness, base_height])
                cube([base_width, wall_thickness, wall_height]);
            
            // Right wall
            translate([-base_width/2, wall_gap/2, base_height])
                cube([base_width, wall_thickness, wall_height]);
        }
        
        // M5 axle hole through both walls
        translate([0, -base_depth/2 - 1, base_height + wall_height/2])
            rotate([-90, 0, 0])
                cylinder(d=5.2, h=base_depth+2);
        
        // M5 BHCS head pocket (one side)
        translate([0, -base_depth/2 - 1, base_height + wall_height/2])
            rotate([-90, 0, 0])
                cylinder(d=10, h=4);
        
        // Mounting holes from bottom - M3 SHCS, line along X for roll-in T-nuts
        for (x = [-10, 10])
            translate([x, 0, -1])
                cylinder(d=3.2, h=base_height+2);
        
        // SHCS head recess pockets from top
        for (x = [-10, 10])
            translate([x, 0, base_height - 3])
                cylinder(d=5.8, h=4);
    }
}

// NEMA 17 Motor (simplified)
module nema17(shaft_length=24) {
    color("DimGray")
    difference() {
        // Body - 42.3mm square with chamfered corners, 48mm long
        translate([0, 0, -48])
        linear_extrude(height=48)
        offset(r=2) offset(delta=-2)
            square([nema17_width, nema17_width], center=true);
        
        // Mounting holes
        for (x = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
            for (y = [-nema17_hole_spacing/2, nema17_hole_spacing/2])
                translate([x, y, -5])
                    cylinder(d=3, h=6, $fn=24);
    }
    // Boss
    color("LightGray")
    cylinder(d=nema17_boss_dia, h=nema17_boss_height);
    // Shaft
    color("Silver")
    cylinder(d=nema17_shaft_dia, h=shaft_length);
}


// === X Axis Idler Assembly ===
module x_idler_assembly() {
    base_height = 16;
    wall_height = 18;
    wall_gap = belt_width + 4;
    wall_thickness = 5;
    base_depth = 24;
    shaft_center_z = base_height + wall_height/2;
    
    // Idler block
    idler_block();
    
    // M5 BHCS as axle (head on left side, goes through to right)
    translate([0, -wall_gap/2 - wall_thickness, shaft_center_z])
        rotate([-90, 0, 0])
            m5_bhcs(20);
    
    // Idler pulley (spins on the bolt, centered in gap)
    translate([0, -(belt_width+3)/2, shaft_center_z])
        rotate([-90, 0, 0])
            gt2_idler(teeth=20, bore=5);
}

// Render drive assembly (comment out when using as library)
//x_drive_assembly();

// Render idler at distance
//translate([200, 0, 0])
//    x_idler_assembly();
