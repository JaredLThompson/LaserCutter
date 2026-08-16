// =======================================================================
// UNIFIED X-AXIS DRIVE & STEPPER ASSEMBLY (AXLE, GUSSET & BOTTOM HARDWARE)
// =======================================================================
use <gt2_gears.scad>;
use <bhcs.scad>;
use <nuts_and_washers.scad>;
use <m5_bearings.scad>;
use <nema17_motor.scad>;
use <shcs.scad>;
use <gt2-belt.scad>;

$fn=64;

// 1. MASTER RENDER CALLS (Preserving your exact layout numbers)
x_axis_drive_assembly();



// =======================================================================
// TIMING BELT GENERATOR MODULE (CORRECTED TRANSFORM STACK)
// =======================================================================
module gt2_loop_belt(width=6, thickness=1.5) {
    dx = 39 - 0;   
    dz = 29 - 17;  
    
    r1 = ((60 * 2) / PI) / 2; 
    r2 = ((16 * 2) / PI) / 2; 
    
    translate([0, 11, 17]) {
        rotate([90, 0, 0]) {
            linear_extrude(height=width, center=true) {
                difference() {
                    hull() {
                        circle(r=r1 + thickness, $fn=64);
                        translate([dx, dz]) circle(r=r2 + thickness, $fn=64);
                    }
                    hull() {
                        circle(r=r1, $fn=64);
                        translate([dx, dz]) circle(r=r2, $fn=64);
                    }
                }
            }
        }
    }
}

// =======================================================================
// MASTER ASSEMBLY MODULE
// =======================================================================
module x_axis_drive_assembly() {

   translate([0,4,17+8]) rotate([90,0,0]) 
       gt2_toothed_pulley(teeth=20, bore=5, width=6, center=false);
   
   translate([0,11,17+8]) rotate([-90, 0, 0]) 
       gt2_toothed_pulley(teeth=60, bore=5, width=6, center=false, m_shaft_lock_dia=25);

   translate([0, -23, 17+8]) rotate([-90, 0, 0]) m5_set_screw_collar();
   translate([0, -11.5, 17+8]) rotate([90, 0, 0]) bearing_f625();
   translate([0, 4.5, 17+8])   rotate([-90, 0, 0]) bearing_f625();

   x_axis_drive_block();
   
   color("silver") translate([0, 1.5, 17+8]) rotate([90,0,0]) 
       cylinder(d=5, h=51, center=true);
       
    //Parts in addition to mount
    // Hardware visually populated onto the brackets
    translate([39, -35.5, 29]) rotate([-90, 0, 0])  nema17_stepper();
    translate([39, 11, 29])  rotate([-90, 0, 0])  gt2_toothed_pulley(teeth=16, bore=5, width=6, center=false);

    // Run your new belt seamlessly between the 60T gear and the 16T stepper pulley!
    color("black") translate([0,4,0]) gt2_belt(p1=[0, 11, 25], p2=[39, 11, 29], r1=19.10, r2=5.09, width=6);

    // --- 3D VISUAL TIMING BELT INTEGRATION ---
    //color("black") translate([0,4,0]) gt2_loop_belt(width=6, thickness=1.5);

    // Four M3 BHCS Motor Mounting Screws & Washers
    translate([39 - 15.5, 10, 29 + 15.5 + 1.5]) rotate([-90, 0, 0]) m3_washer();
    translate([39 - 15.5, 10.6, 29 + 15.5 + 1.5]) rotate([-90, 0, 0]) m3_bhcs(length=10);
    translate([39 + 15.5, 10, 29 + 15.5 + 1.5]) rotate([-90, 0, 0]) m3_washer();
    translate([39 + 15.5, 10.6, 29 + 15.5 + 1.5]) rotate([-90, 0, 0]) m3_bhcs(length=10);
    translate([39 - 15.5, 10, 29 - 15.5 - 1.5]) rotate([-90, 0, 0]) m3_washer();
    translate([39 - 15.5, 10.6, 29 - 15.5 - 1.5]) rotate([-90, 0, 0]) m3_bhcs(length=10);
    translate([39 + 15.5, 10, 29 - 15.5 - 1.5]) rotate([-90, 0, 0]) m3_washer();
    translate([39 + 15.5, 10.6, 29 - 15.5 - 1.5]) rotate([-90, 0, 0]) m3_bhcs(length=10);


    // --- FOUR NATIVE BOTTOM BASE MOUNTING SCREWS (M3 SHCS - FLIPPED POINTING DOWN) ---
    // Placed at the top floor deck surface (Z=8) and flipped 180 degrees 
    // so the heads countersink upward into the pockets and the shafts point down.
    translate([-13, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([13,  0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([26, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([46, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);

}


// =======================================================================
// PRINTABLE HARDWARE COMPONENT MODULE 
// =======================================================================
module x_axis_drive_block(){
  _width = 36;   
  _depth = 27;   
  _height = 30+8;  
  shcs_screw_dia = 3.4;   
  shcs_head_dia = 6.5;    
  shcs_head_depth = 3.3;  
  bearing_od = 16.0;      
  bearing_thick = 5.0;   
  flange_od = 18.0;       
  flange_thick = 1.0;    
  fit_pad = 0.15;         
  
  m_w = 42;  m_d = 5.5;  m_h = 42;  
  plate_y_pos = 10.8 - 3.55; 

  color("crimson") difference() {
    union() {
        translate([0, -_depth/2+10, _height/2]) cube([_width, _depth, _height], center=true);
        translate([39, -3.5, 4]) cube([42, 27, 8], center=true);
        translate([39, plate_y_pos, 29]) rotate([-90, 0, 0]) cube([m_w, m_h, m_d], center=true);
    }
    
    // --- MASTER SUBTRACTION TUNNELS ---
    translate([0, -3.5, _height/2+8+8]) cube([38, 16, _height + 2], center=true);
    translate([0, -5, 17+8]) rotate([90,0,0]) cylinder(d=5.2, h=_depth + 2, center=true);
    
    translate([0, -11.51, 17+8]) rotate([-90, 0, 0]) {
        cylinder(d=bearing_od + fit_pad, h=bearing_thick, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=flange_od + fit_pad, h=flange_thick + 0.1, $fn=64);
    }
    translate([0, 4.51, 17+8]) rotate([-90, 0, 0]) {
        cylinder(d=bearing_od + fit_pad, h=bearing_thick, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=flange_od + fit_pad, h=flange_thick + 0.1, $fn=64);
    }
    
    translate([39, plate_y_pos, 29]) rotate([90, 0, 0]) {
        hull() {
            translate([0, -3, 0]) cylinder(d=22.2, h=m_d + 2, center=true, $fn=64);
            translate([0, 3, 0])  cylinder(d=22.2, h=m_d + 2, center=true, $fn=64);
        }
        for(x_space = [-15.5, 15.5]) {
            for(z_space = [-15.5, 15.5]) {
                translate([x_space, z_space, 0]) {
                    hull() {
                        translate([0, -3, 0]) cylinder(d=3.4, h=m_d + 2, center=true, $fn=32);
                        translate([0, 3, 0])  cylinder(d=3.4, h=m_d + 2, center=true, $fn=32);
                    }
                }
            }
        }
    }
    
    for(x_offset = [-13, 13]) {
        translate([x_offset, 0, 0]) {
            translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=_height + 2);
            translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 9);
        }
    }
    
    translate([26, 0, 0]) {
        translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=8 + 2);
        translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 1);
    }
    translate([46, 0, 0]) {
        translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=8 + 2);
        translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 1);
    }
  }
}


