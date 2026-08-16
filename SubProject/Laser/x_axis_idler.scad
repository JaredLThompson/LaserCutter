//X Axis Idler Assembly
use <gt2_gears.scad>;
use <bhcs.scad>;
use <nuts_and_washers.scad>;

$fn=64;

x_axis_idler_assembly();

module x_axis_idler_assembly() {
   x_axis_idler_block();
   // The idler pulley is rendered at Z=17, matching your setup
   translate([0,0,21+4])rotate([90,0,0])gt2_toothed_idler(teeth=20, bore=5, width=6, center=true);
   translate([0,-10,21+4])rotate([90,0,0])m5_bhcs(25);
   translate([0,11,21+4])rotate([90,0,0])m5_washer();   
   translate([0,11,21+4])rotate([-90,0,0])m5_lock_nut();   
   
}

module x_axis_idler_block(){
  _width = 30;
  _depth = 20;
  _height = 32;
  
  // Standard M3 SHCS Dimensions
  shcs_screw_dia = 3.4;   // Loose clearance for M3 threads
  shcs_head_dia = 6.5;    // Counterbore hole outer diameter
  shcs_head_depth = 3.3;  // Recess depth to submerge the screw head
  
  color("crimson")difference(){
    // Main mounting block structure
    translate([0,0,_height/2])cube([_width,_depth,_height], center=true);
    
    // Idler pulley cutout pocket
    translate([0,0,_height/2+16])cube([32,9,_height], center=true);
    
    // Smooth 5.2mm center pivot shaft pin hole
    translate([0,0,25])rotate([90,0,0])cylinder(d=5.2, h=_depth+2, center=true);
    
    // Dual M3 SHCS Counterbore Mounting Holes
    // Placed symmetrically on the left (-10mm) and right (+10mm) sides of the block base
    for(x_offset = [-10, 10]) {
        translate([x_offset, 0, 0]) {
            // 1. Through-hole for the M3 screw shank
            translate([0, 0, -1])
                cylinder(d=shcs_screw_dia, h=_height + 2);
                
            // 2. Counterbore shoulder recess to hide the cylindrical head
            // Placed at the top surface pointing downward
            translate([0, 0, 16 - shcs_head_depth])
                cylinder(d=shcs_head_dia, h=shcs_head_depth + 1);
        }
    }
  }
}


