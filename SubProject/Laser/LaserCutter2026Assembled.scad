// ============================================================================
// Dependencies
// ============================================================================
use <Laser_Tube.scad>;
use <LaserTubeMount.scad>;
use <A1-RearMirrorMount.scad>;
use <A2-FrontMirrorMount.scad>;
use <focuser-assembly.scad>;
use <MGN12H-Adapter-Plate.scad>;
use <lib_mgn12.scad>;
use <extrusion-20xx.scad>;
use <x_axis_idler.scad>;
use <x_axis_drive.scad>;
use <gt2-belt.scad>;
use <mgn12h_2020_adapter.scad>;
use <y_axis_idler.scad>;
use <y_axis_belt_tension_anchor.scad>;
use <kp08_pillow_block_bearing.scad>;
use <gt2_gears.scad>;
use <../../laser_parts.scad>;


// ============================================================================
// Display controls
// ============================================================================
$fn = 64;
show_lid = true;
show_laser_beams = true;
show_leveling_feet = true;
lid_angle = 40;
leveling_foot_adjustment = 12; // Exposed 3/8-16 stud below socket: 0–22.86 mm

// ============================================================================
// Machine dimensions
// ============================================================================
frame_width = 1219.2; // One full 48-inch 2020 extrusion
frame_depth = 650;
frame_height = 360;

lid_height = 100;
lid_width = 1040;
lid_depth = 495;

// ============================================================================
// Interactive positioning
// ============================================================================
X_Pos = 345; // Laser head position; approximately 345 max
Y_Pos = 0;   // Gantry position; approximately -45 min

// ============================================================================
// Assembly offsets
// ============================================================================
laser_tube_y = 450;
laser_offset = 70 + 88;
y_belt_offset = 429;

// =======================================================================
// FIXED STATIC FRAME PARTS (Laser Tube & Rear Mirror 1)
// =======================================================================
// Laser Tube (Stationary on rear frame)
translate([0, laser_tube_y, laser_offset]) rotate([90, 0, 0]) laser_tube(800);

// Tube Mounts (Stationary)
translate([-280, laser_tube_y, 74]) tubeMountAssembled(z_offset=14);
translate([280, laser_tube_y, 74]) tubeMountAssembled(z_offset=14);

// A1 Fixed Mirror Mount (Turned laser=false so it doesn't draw static lines!)
translate([-465, laser_tube_y + 5, -52])
  AssembledRearMirrorMount(zOffset=52, laser=false);


// Y Axis Idlers
//translate([410,-85, 74])y_axis_idler_assembly();
color("green") 
        gt2_belt(p1=[y_belt_offset, -85, 89], p2=[y_belt_offset, 365, 89], width=6);

//translate([-410,-85, 74])y_axis_idler_assembly();
color("green") 
        gt2_belt(p1=[-y_belt_offset, -85, 89], p2=[-y_belt_offset, 365, 89], width=6);
        
        
if (show_lid)
    translate([0, 380, frame_height - 82]) lid_assembly(lid_angle);

 
  
// Y axis drive
translate([410,365,74])
  kp08_pillow_block_assembly();

translate([-410,365,74])
  kp08_pillow_block_assembly();
  
// Y Drive Axle
translate([0,365,89])
  rotate([0,90,0])cylinder(d=8,h=870, center=true);
  
translate([425,365,89])
  rotate([0,-90,0]) 
    gt2_toothed_pulley(teeth=20, bore=8, width=9, center=true);

translate([-425,365,89])
  rotate([0,90,0]) 
    gt2_toothed_pulley(teeth=20, bore=8, width=9, center=true);





  
// =======================================================================
// DYNAMIC WIREFRAME LASER BEAM PREVIEW (REALIGNED MATRICES)
// =======================================================================
if (show_laser_beams) {
    color("blue", 0.6) {
        
        // --- BEAM Segment 1: Tube Exit to A1 Fixed Corner Mirror ---
        translate([0, laser_tube_y, 158]) 
            rotate([0, -90, 0]) 
                cylinder(d=2, h=465);

        // --- BEAM Segment 2: A1 Fixed Mirror to Moving A2 Gantry Mirror ---
        translate([-465, laser_tube_y, 158]) 
            rotate([90, 0, 0]) 
                cylinder(d=2, h=(laser_tube_y - (Y_Pos - 35)));

        // --- BEAM Segment 3: Moving A2 Mirror to Sliding A3 Laser Focuser Head ---
        translate([-465, Y_Pos-35, 158]) 
            rotate([0, 90, 0]) 
                cylinder(d=2, h=(X_Pos - (-465)));
                
        // --- BEAM Segment 4: Downward Cut Path (Nozzle Tip to Honeycomb Bed) ---
        // Pushes straight down to meet the new metal honeycomb mesh grid top line
        translate([X_Pos, Y_Pos - 35, 158])
            rotate([180, 0, 0])
                cylinder(d=1, h=190);
    }
}


// =======================================================================
// LASER CUTTER HONEYCOMB WORK BED MATRIX
// =======================================================================
// Centered on the machine footprint, resting cleanly underneath the rails
translate([0, 130, -32]) 
    laser_honeycomb_bed(w=750, d=400, h=12);


// =======================================================================
// DYNAMIC Y-AXIS STAGE (Moves entire crossbar assembly along Y_Pos)
// =======================================================================
translate([0, Y_Pos, 0]) {

    // A2 Front Left Flying Mirror Mount
    translate([-465 + 5, 20, 114]) 
      AssembledFrontMirrorMount(laser=false);
        
    // 2020 X-Axis Aluminum Structural Frame Crossbar
    translate([0, 130 - 130, 104])
        rotate([0, 90, 0]) aluminum_extrusion_2020(length=975, center=true, black=true);
       
    // X-Axis Linear Profile Guide Rail
    translate([0, 130 - 130, 114])
      rotate([0, 0, -90])
         mgn12h_with_rail(rail_length = 800, carriage_pos = X_Pos, include_stops = false);  
         
    // X-Axis Belt Tension Idler Bracket (Far Left Side)
    translate([-415, 130 - 130, 114])
        x_axis_idler_assembly();
        
    // X-Axis Stepper Drive Assembly Block (Far Right Side)
    translate([420, 130 - 130, 115])
        x_axis_drive_assembly();
        
    // X-Axis Visual Timing Belt Loop
    color("green") translate([0, 0, 135 + 4])
        gt2_belt(p1=[-415, 0, 0], p2=[420, 0, 0], width=6); 

    // MGN12 Gantry Frame Interface Adapter Plates (Left & Right Ends)
    translate([410, 130 - 130, 87]) rotate([0,0,180])mgn12h_to_2020_adapter();
    translate([-410, 130 - 130, 87]) mgn12h_to_2020_adapter();


    // ===================================================================
    // DYNAMIC X-AXIS CARRIAGE STAGE (Moves with BOTH X_Pos and Y_Pos)
    // ===================================================================
    translate([X_Pos, 0, 0]) {
        
        // A3 Final Mirror & Laser Focus Lens Assembly 
        translate([0, -35, 133]) 
          focuser_assembly();
          
        // A4 Focuser Carriage Interface Plate
        translate([0, -35, 127])
          MGN12HAdapterPlateAssembly();
    }
}


// =======================================================================
// FIXED Y-AXIS GUIDE RAILS (Main Frame Base Tunnels)
// =======================================================================
translate([410, 130, 74]) mgn12h_with_rail(rail_length = 400, carriage_pos = Y_Pos - 130, include_stops = false);
translate([410, 145, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=500, center=true, black=true);

translate([-410, 130, 74]) mgn12h_with_rail(rail_length = 400, carriage_pos = Y_Pos - 130, include_stops = false);
translate([-410, 145, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=500, center=true, black=true);


// Front of Gantry
translate([0, -115, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);
// Back of Gantry
translate([0, 400, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);
// back of CO2 Tube
translate([-500, 500, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width-40);

//Right side of gantry
translate([510, 192+10, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-60, center=true);
//Left side of gantry
translate([-510, 192, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true, black=true);


// Cross supports
translate([303, 450, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
translate([257, 450, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
// Cross supports
translate([-303, 450, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
translate([-257, 450, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);



// =======================================================================
// Outside uprights
// =======================================================================

// right front
translate([689.2, -115, -52])aluminum_extrusion_2020(length=frame_height-20);
// right front (gantry)
translate([510, -105, -52])rotate([0,0,90])aluminum_extrusion_2040(length=frame_height-20);
// left front
translate([-510, -115, -52])aluminum_extrusion_2020(length=frame_height-20);
// right back 
translate([689.2, 500, -52])aluminum_extrusion_2020(length=frame_height-20);
// right back (gantry)
// color("silver")translate([510, 500, -42-10])rotate([0,0,90])aluminum_extrusion_2020(length=frame_height-40,  black=true);
translate([510, 500, 74])rotate([0,0,90])aluminum_extrusion_2020(length=195);
translate([510, 500, -54])rotate([0,0,90])aluminum_extrusion_2020(length=108);

//Rails to mount electronics panel
color("orange")translate([510, 480, 74])rotate([0,0,90])aluminum_extrusion_2020(length=175);
color("orange")translate([510, 480, -54])rotate([0,0,90])aluminum_extrusion_2020(length=108);
color("orange")translate([510, 192, -42]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-80, center=true);


// left back
translate([-510, 500, -52])aluminum_extrusion_2020(length=frame_height-20);



//Bottom front
translate([-520, -115, -62]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width);
//Bottom left
translate([-510, 192, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true);
//Bottom back
translate([-520, 500, -62]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width);
//Bottom right of gantry
translate([510, 192, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true);
//Bottom right
translate([689.2, 192, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true);

if (show_leveling_feet)
    leveling_feet_assembly();



//top front main
color("silver")translate([0, -115, frame_height-82-20-lid_height]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);
//top back
color("silver")translate([-520, 500, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width, black=true);

//top Right side of gantry
color("silver")translate([510, 192+10, frame_height-82-10]) rotate([0, 90, 90]) aluminum_extrusion_2040(length=635-60, center=true, black=true);
//top Left side 
color("silver")translate([-510, 192, frame_height-82]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true, black=true);
//Bottom right
color("silver")translate([689.2, 192, frame_height-82]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=635-40, center=true, black=true);

//top right electronics bay
color("silver")translate([600, -115, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=160, center=true, black=true);

//Lid-mating peice
translate([0, 400, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true);


e_panel_thickness = 4;

translate([520, -105, -52]) electronics_panel_vertical();

module electronics_panel_vertical() {
    color("SteelBlue")
        cube([e_panel_thickness, frame_depth - 55, frame_height - 40]);
}

// ============================================================================
// Reusable assemblies
// ============================================================================
module leveling_feet_assembly() {
    outer_left = -510;
    outer_right = 689.2;
    front_y = -115;
    rear_y = 500;
    gusset_center_z = -74;

    // Mirror one inward-facing corner plate and foot into each frame corner.
    for (sx = [-1, 1], sy = [-1, 1]) {
        corner_x = sx < 0 ? outer_left : outer_right;
        corner_y = sy < 0 ? front_y : rear_y;

        translate([corner_x, corner_y, gusset_center_z])
            scale([-sx, -sy, 1]) {
                corner_gusset_2020_60();
                translate([20, 20, -2])
                    rotate([0, 0, -45])
                        leveling_foot_3_8_16(
                            adjustment=leveling_foot_adjustment,
                            mount_hole_half_spacing=sqrt(200));
            }
    }
}

module lid_assembly(rotate_angle) {
    glass_thickness = 4;

    translate([0, 0, 20])
        rotate([-rotate_angle, 0, 0]) {
            // Aluminum frame
            translate([0, 0, -20])
                rotate([0, 90, 0])
                    aluminum_extrusion_2020(length=lid_width - 40, center=true);

            translate([0, -lid_depth, -20])
                rotate([0, 90, 0])
                    aluminum_extrusion_2020(length=lid_width - 40, center=true);

            translate([0, -lid_depth, -20 - lid_height])
                rotate([0, 90, 0])
                    aluminum_extrusion_2020(length=lid_width - 40, center=true);

            translate([-lid_width / 2 + 30, -lid_depth, -20 - lid_height + 10])
                aluminum_extrusion_2020(length=lid_height - 20);

            translate([lid_width / 2 - 30, -lid_depth, -20 - lid_height + 10])
                aluminum_extrusion_2020(length=lid_height - 20);

            translate([-lid_width / 2 + 30, -lid_depth + 10, -20])
                rotate([-90, 0, 0])
                    aluminum_extrusion_2020(length=lid_depth - 20);

            translate([lid_width / 2 - 30, -lid_depth + 10, -20])
                rotate([-90, 0, 0])
                    aluminum_extrusion_2020(length=lid_depth - 20);

            // Four-millimeter tinted acrylic panels
            color([1, 0.15, 0.0, 0.1]) {
                translate([0, -lid_depth / 2, -10 + glass_thickness / 2])
                    cube([lid_width - 40, lid_depth, glass_thickness], center=true);

                rotate([90, 0, 0])
                    translate([0, -lid_height + 30, lid_depth + 10 + glass_thickness / 2])
                        cube([lid_width - 40, lid_height, glass_thickness], center=true);
            }
        }
}


// =======================================================================
// PARAMETRIC HONEYCOMB BED MODULE (FAST RENDER MATRIX)
// =======================================================================
module laser_honeycomb_bed(w=600, d=400, h=12) {
    cell_s = 9;   // Cell pattern spacing size
    wall_t = 1.2; // Honeycomb iron wall thickness
    
    // 1. External Aluminum U-Channel Protective Border
    color("silver") difference() {
        cube([w + 20, d + 20, h], center=true);
        cube([w, d, h + 2], center=true);
    }
    
    // 2. High-Performance Geometric Mesh Screen Core
    color("DarkSlateGray") intersection() {
        // Limit mesh footprint exactly to the inside of the frame channel
        cube([w - 0.2, d - 0.2, h - 1], center=true);
        
        // Extrude a quick 2D crossed diagonal array
        linear_extrude(height=h, center=true) {
            difference() {
                square([w, d], center=true);
                
                // Row and column diamond loop lines
                for (x = [-w/2 : cell_s : w/2]) {
                    for (y = [-d/2 : cell_s : d/2]) {
                        // Alternate shifts per row to weave hex shapes together
                        y_alt = ((x / cell_s) % 2 == 0) ? 0 : cell_s/2;
                        
                        translate([x, y + y_alt])
                            rotate([0, 0, 45])
                                square([cell_s - wall_t, cell_s - wall_t], center=true);
                    }
                }
            }
        }
    }
}
