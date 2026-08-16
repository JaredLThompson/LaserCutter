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

// Minimum-tension motor datum for the stocked 158 mm GT2 reduction belt.
// The motor can move only toward +X from here to add belt tension.
x_motor_min_x = 38.21;
x_motor_center_z = 29;
x_motor_tension_travel = 4;

// 1. MASTER RENDER CALLS (Preserving your exact layout numbers)
//x_axis_drive_block();
x_axis_drive_assembly();

//temporary block to keep the edge aligned
//translate([-28,0,0])cube ([10,10,10]);

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
   // F625 bearings install from the accessible exterior faces. Their 18 mm
   // flanges sit in the outer counterbores and their 5 mm bodies extend
   // inward through the two 5.5 mm housing walls.
   translate([0, -17, 17+8]) rotate([-90, 0, 0]) bearing_f625();
   translate([0,  10, 17+8]) rotate([ 90, 0, 0]) bearing_f625();

   x_axis_drive_block();
   
   color("silver") translate([0, 1.5, 17+8]) rotate([90,0,0]) 
       cylinder(d=5, h=51, center=true);
       
    //Parts in addition to mount
    // Hardware visually populated onto the brackets
    translate([x_motor_min_x, -35.5, x_motor_center_z])
        rotate([-90, 0, 0]) nema17_stepper();
    translate([x_motor_min_x, 11, x_motor_center_z])
        rotate([-90, 0, 0])
            gt2_toothed_pulley(teeth=16, bore=5, width=6, center=false);

    // Run your new belt seamlessly between the 60T gear and the 16T stepper pulley!
    color("black") translate([0,4,0])
        gt2_belt(p1=[0, 11, 25],
                 p2=[x_motor_min_x, 11, x_motor_center_z],
                 r1=19.10, r2=5.09, width=6);

    // --- 3D VISUAL TIMING BELT INTEGRATION ---
    //color("black") translate([0,4,0]) gt2_loop_belt(width=6, thickness=1.5);

    // Four M3 BHCS motor screws and washers. The current motor position is
    // the minimum-tension end of each slot, and the heads must share the
    // exact 31 x 31 mm NEMA-17 hole centers (no former +/-1.5 mm Z error).
    for (x_space = [-15.5, 15.5])
        for (z_space = [-15.5, 15.5]) {
            translate([x_motor_min_x + x_space, 10,
                       x_motor_center_z + z_space])
                rotate([-90, 0, 0]) m3_washer();
            translate([x_motor_min_x + x_space, 10.6,
                       x_motor_center_z + z_space])
                rotate([-90, 0, 0]) m3_bhcs(length=10);
        }


    // --- FOUR NATIVE BOTTOM BASE MOUNTING SCREWS (M3 SHCS - FLIPPED POINTING DOWN) ---
    // Placed at the top floor deck surface (Z=8) and flipped 180 degrees 
    // so the heads countersink upward into the pockets and the shafts point down.
    translate([-13, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([13,  0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([26, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);
    translate([53, 0, 4]) rotate([0, 180, 0]) m3_shcs(length=10);

}


// =======================================================================
// PRINTABLE HARDWARE COMPONENT MODULE 
// =======================================================================
module x_axis_drive_block(){
  _width = 35;
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

  // Widen the NEMA plate to preserve edge material around the horizontal
  // tension slots. The motor/output shaft centerline runs along X, so useful
  // belt adjustment must also run along X rather than vertically along Z.
  // Four millimetres of one-way travel changes the modeled belt path by
  // about 7.5 mm, which is ample for tensioning a nominal 158 mm loop.  The
  // compact plate restores the clearance lost to the former 8 mm slots.
  m_w = 50;  m_d = 5.5;  m_h = 42;
  motor_plate_center_x = 40;
  plate_y_pos = 10.8 - 3.55; 

  color("crimson") difference() {
    union() {
        translate([-_width/2, -17, 0]) cube([_width, _depth, _height], center=false);
        // Carry the widened, +X-biased motor plate all the way down to the
        // print bed.  Matching its width and center removes the unsupported
        // ledge created by the one-direction tension adjustment.
        translate([motor_plate_center_x, -3.5, 4])
            cube([m_w, 27, 8], center=true);
        // Asymmetric toward +X because the installed motor is already at its
        // minimum center distance and can only move right to add tension.
        translate([motor_plate_center_x, plate_y_pos, 29])
            rotate([-90, 0, 0]) cube([m_w, m_h, m_d], center=true);

    }
    
    // subtract back of pulley drive
    //translate([-30,-20,38])cube([60,10,15]);

    // --- MASTER SUBTRACTION TUNNELS ---
    translate([0, -3.5, _height/2+8+8]) cube([38, 16, _height + 2], center=true);
    // Continuous M5 output-axle bore through both housing walls.  This must
    // share the housing's Y datum (-3.5); the former -5 mm center left a
    // 0.5 mm membrane on one face that became visible after mirroring.
    translate([0, -3.5, 17+8])
        rotate([90,0,0])
            cylinder(d=5.2, h=_depth + 4, center=true);
    
    // Negative-Y wall: exterior flange seat at Y=-17, bearing body toward +Y.
    translate([0, -17, 17+8]) rotate([-90, 0, 0]) {
        cylinder(d=bearing_od + fit_pad, h=bearing_thick, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=flange_od + fit_pad, h=flange_thick + 0.1, $fn=64);
    }

    // Positive-Y wall: exterior flange seat at Y=10, bearing body toward -Y.
    translate([0, 10, 17+8]) rotate([90, 0, 0]) {
        cylinder(d=bearing_od + fit_pad, h=bearing_thick, $fn=64);
        translate([0, 0, -0.1]) cylinder(d=flange_od + fit_pad, h=flange_thick + 0.1, $fn=64);
    }
    
    translate([x_motor_min_x, plate_y_pos, x_motor_center_z])
      rotate([90, 0, 0]) {
        // Horizontal boss clearance lets the complete motor translate toward
        // +X, away from the 60T output pulley. The current location is the
        // minimum-tension endpoint, not the middle of the adjustment range.
        hull() {
            translate([0, 0, 0])
                cylinder(d=22.2, h=m_d + 2, center=true, $fn=64);
            translate([x_motor_tension_travel, 0, 0])
                cylinder(d=22.2, h=m_d + 2, center=true, $fn=64);
        }
        for(x_space = [-15.5, 15.5]) {
            for(z_space = [-15.5, 15.5]) {
                translate([x_space, z_space, 0]) {
                    // NEMA-17 holes remain on their 31 x 31 mm pattern; each
                    // slot begins at the current/minimum-tension position and
                    // provides 4 mm of adjustment only toward +X.
                    hull() {
                        translate([0, 0, 0])
                            cylinder(d=3.4, h=m_d + 2, center=true, $fn=32);
                        translate([x_motor_tension_travel, 0, 0])
                            cylinder(d=3.4, h=m_d + 2, center=true, $fn=32);
                    }
                }
            }
        }
    }

    for(x_offset = [-12, 11]) {
        translate([x_offset, 0, 0]) {
            translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=_height + 2);
            translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 9);
        }
    }
    
    translate([26, 0, 0]) {
        translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=8 + 2);
        translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 1);
    }
    translate([60, 0, 0]) {
        translate([0, 0, -1]) cylinder(d=shcs_screw_dia, h=8 + 2);
        translate([0, 0, 8 - shcs_head_depth]) cylinder(d=shcs_head_dia, h=shcs_head_depth + 1);
    }
  }
}
