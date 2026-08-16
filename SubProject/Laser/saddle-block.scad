// X Beam Saddle Block
// Mounts the 2020 X beam extrusion to the MGN12H Y-axis carriages
// Bottom: MGN12H bolt pattern (20mm x 20mm, M3)
// Top: 20mm x 20mm channel for X beam to sit in
// Secured with M4 set screw from the side

use <shcs.scad>;

$fn=48;


saddle_block();


module saddle_block() {
    block_w = 30;       // X width (along Y rail direction)
    block_d = 40;       // Y depth (along X beam direction - open ends)
    block_h = 28;       // Z total height (taller to enclose 2020)
    channel_size = 20.2; // slightly oversized for 2020
    channel_depth = 20;  // full 2020 height sits in channel
    
    color("DarkOrange")
    difference() {
        // Main block
        translate([-block_w/2, -block_d/2, 0])
            cube([block_w, block_d, block_h]);
        
        // Through-channel on top (X beam passes through along Y axis)
        translate([-channel_size/2, -block_d/2 - 1, block_h - channel_depth])
            cube([channel_size, block_d + 2, channel_depth + 1]);
        
        // MGN12H mounting holes (through, M3)
        for (x = [-10, 10])
            for (y = [-10, 10])
                translate([x, y, -1])
                    cylinder(d=3.2, h=block_h + 2);
        
        // M3 SHCS counterbore from top (flush with channel floor)
        for (x = [-10, 10])
            for (y = [-10, 10])
                translate([x, y, block_h - channel_depth - 3])
                    cylinder(d=5.8, h=4);
        
        // Set screw hole from side (M4, aligns with 2020 T-slot center)
        translate([-block_w/2 - 1, 0, block_h - channel_depth + 10])
            rotate([0, 90, 0])
                cylinder(d=4, h=block_w + 2);
    }
}

module saddle_block_assembly() {
    saddle_block();
    
    // Show M4 set screws
    translate([-block_w/2, 0, 20 - 6])
        rotate([0, 90, 0])
            m3_shcs(8);
}

saddle_block();
