// =======================================================================
// FILENAME: y_axis_idler_assembly.scad
// TALL VERTICAL CLEARANCE IDLER ASSEMBLY FOR LONGITUDINAL Y-DRIVE
// =======================================================================
use <gt2_gears.scad>;
use <bhcs.scad>;
use <nuts_and_washers.scad>;

$fn=64;

// Seating axis for the horizontal M5 axle pin
axle_z_pos = 46; 
  
  
y_axis_idler_assembly();

module y_axis_idler_assembly() {
   rotate([0,0,90]) y_axis_idler_block();
   
   // TALL UPDATE: Pulley axle raised from Z=25 to Z=46 to ride completely over the gantry plates
   translate([0,0,axle_z_pos]) rotate([90,0,90]) gt2_toothed_idler(teeth=20, bore=5, width=6, center=true);
   translate([10,0,axle_z_pos]) rotate([90,0,90]) m5_bhcs(25);
   translate([10,0,axle_z_pos]) rotate([90,0,90]) m5_washer();   
   translate([-10,0,axle_z_pos]) rotate([-90,0,90]) m5_lock_nut();   
}

module y_axis_idler_block(){
  _width = 30;
  _depth = 20;
  
  // TALL UPDATE: Extended total height from 32mm to 55mm to reach up into open space
  _height = 55; 
  

  
  shcs_screw_dia = 3.4;   
  shcs_head_dia = 6.5;    
  shcs_head_depth = 3.3;  
  
  color("crimson") difference(){
    // 1. Solid Extended Housing Body Frame
    translate([0,0,_height/2]) cube([_width,_depth,_height], center=true);
    
    // 2. Pulley Cleaving Cutout Pocket (Clears the wheel profile up high)
    translate([0,0,axle_z_pos + 8]) cube([32,9,_height], center=true);
    
    // 3. Smooth Center Pivot Shaft Hole (Perfect alignment at Z=46)
    translate([0,0,axle_z_pos]) rotate([90,0,0]) cylinder(d=5.2, h=_depth+2, center=true);
    
    // 4. Dual M3 Base Mounting Holes (Keeps your exact table footprint constraints)
    for(x_offset = [-10, 10]) {
        translate([x_offset, 0, 0]) {
            // Main tool access shaft tunnel going straight out the bottom floor
            translate([0, 0, -1])
                cylinder(d=shcs_screw_dia, h=_height + 2);
                
            // Counterbore shoulder pocket (Recessed down from the deep inner pocket floor)
            translate([0, 0, 6 - shcs_head_depth])
                cylinder(d=shcs_head_dia, h=_height);
        }
    }
  }
}
