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
use <iec_fused_inlet.scad>;
use <../../laser_parts.scad>;


// ============================================================================
// Display controls
// ============================================================================
$fn = 64;

show_laser_beams = true;
show_leveling_feet = true;

show_all_panels = true; // Master switch for every sheet-metal/acrylic panel
show_outer_panels = true;
show_front_panel = true;
show_front_cutting_panel = true;
show_front_electronics_panel = true;
show_rear_panel = true;
show_rear_service_connections = true;
show_iec_power_inlet = true;
show_air_assist_bulkhead = true;
show_water_cooling_bulkheads = true;
show_right_panel = true;
show_bottom_panel = true;
show_tube_top_panel = true;
show_electronics_top_panel = true;
show_tube_front_bulkhead = true;
show_tube_floor_panel = true;
show_tube_access_door = true;
show_electronics_access_door = true;
show_electronics_mounting_panel = true;
show_electronics_components = true;
show_laser_power_supply = true;
show_stepper_drivers = true;
show_din_rails = true;
show_left_lower_access_panel = true;
show_left_upper_access_panel = true;
show_left_panel_overlap_strip = true;

leveling_foot_adjustment = 12; // Exposed 3/8-16 stud below socket: 0–22.86 mm
outer_panel_thickness = 2;
//outer_panel_color = [0.24, 0.28, 0.32]; // RGB values from 0 to 1
outer_panel_color = [0.84, 0.88, 0.92]; // RGB values from 0 to 1
outer_panel_opacity = 0.62;

// Opaque sheet-metal floor (separate from the acrylic enclosure panels)
bottom_panel_thickness = 25.4 / 16; // 1/16 inch = 1.5875 mm
bottom_panel_color = [0.55, 0.57, 0.59];
bottom_panel_opacity = 1.0;

// Lid attributes
show_lid = true;
lid_panel_color = [0.35, 0.35, 0.35]; // RGB values from 0 to 1
lid_panel_opacity = 0.10;
lid_angle = 90;

tube_access_door_angle = 90;       // 0=closed; positive opens outward/upward
electronics_door_angle = 30;       // 0=closed; positive opens outward/right
left_lower_panel_pull = 0;        // Pull outward in -X; hide to remove completely
left_upper_panel_pull = 0;
tube_floor_panel_drop = 0;        // Positive value lowers floor for inspection

show_honeycomb=true;


// ============================================================================
// Machine dimensions
// ============================================================================
frame_width = 1219.2; // One full 48-inch 2020 extrusion
frame_depth = 650;
frame_height = 360;

// Shared chassis datums. Panel dimensions are derived from these structural
// member centerlines so enclosure changes track future frame revisions.
extrusion_profile = 20;
left_frame_x = -510;
electronics_divider_x = 510;
right_frame_x = left_frame_x + frame_width - extrusion_profile;
front_frame_y = -115;
rear_frame_y = 500;
lower_frame_z = -62;
upper_frame_z = frame_height - 82;

lid_height = 100;
lid_width = 1040;
lid_depth = 495;

// ============================================================================
// Interactive positioning
// ============================================================================
X_Pos = 345; // Laser head position; approximately 345 max
Y_Pos = 0;   // Gantry position; approximately -45 min
gantry_z_adjustment = 60; // Raise/lower complete moving gantry for clearance checks

// ============================================================================
// Assembly offsets
// ============================================================================
laser_tube_y = 450;
laser_offset = 70 + 88;
y_belt_offset = 429;
e_panel_thickness = 4;

// The original assembly was modeled with the underside of the bottom 2020
// frame members at Z=-72. Apply one datum correction to the complete machine
// so the chassis bottom is Z=0 without changing any relative dimensions.
chassis_bottom_z = 0;
assembly_z_offset = chassis_bottom_z + 72;

translate([0, 0, assembly_z_offset]) {

// =======================================================================
// FIXED STATIC FRAME PARTS (Laser Tube & Rear Mirror 1)
// =======================================================================
translate([0, 0, gantry_z_adjustment]) {

// Laser Tube (Stationary on rear frame)
translate([0, laser_tube_y, laser_offset]) rotate([90, 0, 0]) laser_tube(800);

// Tube Mounts (Stationary)
translate([-280, laser_tube_y, 74]) tubeMountAssembled(z_offset=14);
translate([280, laser_tube_y, 74]) tubeMountAssembled(z_offset=14);

// A1 Fixed Mirror Mount (Turned laser=false so it doesn't draw static lines!)
// Counteract the outer motion-plane translation so the mounting base remains
// fixed to the chassis; only the adjustable upright follows the optical axis.
translate([0, 0, -gantry_z_adjustment])
  translate([-465, laser_tube_y + 5, -52])
    AssembledRearMirrorMount(
        zOffset=52 + gantry_z_adjustment,
        laser=false);


// Y Axis Idlers
//translate([410,-85, 74])y_axis_idler_assembly();
color("green") 
        gt2_belt(p1=[y_belt_offset, -85, 89], p2=[y_belt_offset, 365, 89], width=6);

//translate([-410,-85, 74])y_axis_idler_assembly();
color("green") 
        gt2_belt(p1=[-y_belt_offset, -85, 89], p2=[-y_belt_offset, 365, 89], width=6);

} // Fixed optics, Y belts, and tube move with the complete gantry plane
        
        

  
// Y axis drive
translate([0, 0, gantry_z_adjustment]) {

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

} // Y-axis drive plane




  
// =======================================================================
// DYNAMIC WIREFRAME LASER BEAM PREVIEW (REALIGNED MATRICES)
// =======================================================================
if (show_laser_beams) {
    translate([0, 0, gantry_z_adjustment])
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
                cylinder(d=1, h=190 + gantry_z_adjustment);
    }
}


// =======================================================================
// LASER CUTTER HONEYCOMB WORK BED MATRIX
// =======================================================================
// Centered on the machine footprint, resting cleanly underneath the rails
if (show_honeycomb)
  translate([0, 130, -32])
    laser_honeycomb_bed(w=750, d=400, h=12);

    
if (show_lid)
    translate([0, 380, frame_height - 82]) lid_assembly(lid_angle);

 

// =======================================================================
// DYNAMIC Y-AXIS STAGE (Moves entire crossbar assembly along Y_Pos)
// =======================================================================
translate([0, Y_Pos, gantry_z_adjustment]) {

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
translate([0, 0, gantry_z_adjustment]) {

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

} // Y rails, their 2020 supports, and the tube-support deck


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

// Split rear posts terminate at the moving gantry rail. Their outside ends
// stay fixed while the lower segment grows and the upper segment shrinks.
split_post_bottom_z = -52;
gantry_rail_bottom_z = 54 + gantry_z_adjustment;
gantry_rail_top_z = 74 + gantry_z_adjustment;
rear_post_top_z = 269;
electronics_post_top_z = 249;

// Right back gantry post
translate([510, 500, gantry_rail_top_z])
  rotate([0,0,90])
    aluminum_extrusion_2020(length=rear_post_top_z-gantry_rail_top_z);
translate([510, 500, split_post_bottom_z])
  rotate([0,0,90])
    aluminum_extrusion_2020(length=gantry_rail_bottom_z-split_post_bottom_z);

//Rails to mount electronics panel
color("orange")
  translate([510, 480, gantry_rail_top_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=electronics_post_top_z-gantry_rail_top_z);
          
color("orange")
  translate([510, 410, gantry_rail_top_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=electronics_post_top_z-gantry_rail_top_z);
          
color("orange")
  translate([510, 480, split_post_bottom_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=gantry_rail_bottom_z-split_post_bottom_z);
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


// A1 mirror supports
translate([-465+20, 192, -62]) rotate([90, 0, 0]) aluminum_extrusion_2020(length=635-40, center=true, black=true);
translate([-465-20, 192, -62]) rotate([90, 0, 0]) aluminum_extrusion_2020(length=635-40, center=true, black=true);


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


if (show_all_panels && show_electronics_mounting_panel)
    translate([520, -105, -52]) electronics_panel_vertical();

if (show_electronics_components)
    electronics_bay_assembly();

if (show_all_panels && show_outer_panels)
    outer_panels_assembly();

} // Complete machine datum correction

module electronics_panel_vertical() {
    color("SteelBlue")
        cube([e_panel_thickness, frame_depth - 55, frame_height - 40]);
}

module electronics_bay_assembly() {
    // Clear X envelope between the blue backplate and right perimeter rail.
    // The 139.7 mm PSU leaves approximately 8 mm clearance on either side.
    backplate_face_x = 520 + e_panel_thickness;
    right_rail_inner_x = right_frame_x - extrusion_profile / 2;
    bay_center_x = (backplate_face_x + right_rail_inner_x) / 2;

    electronics_front_y = front_frame_y + extrusion_profile / 2;
    electronics_rear_y = rear_frame_y - extrusion_profile / 2;
    electronics_center_y =
        (electronics_front_y + electronics_rear_y) / 2;

    // Put the high-voltage supply toward the rear, close to the laser tube and
    // its feedthrough. Terminals face -Y and the fan faces the backplate.
    power_supply_y = electronics_rear_y - 125;
    if (show_laser_power_supply)
        translate([bay_center_x, power_supply_y, -52])
            vevor_laser_power_supply_50w(show_cable=false);

    din_mount_x = backplate_face_x + 1;
    din_length = electronics_rear_y - electronics_front_y - 40;
    din_lower_z = 70;
    din_upper_z = 180;

    if (show_din_rails)
        for (din_z = [din_lower_z, din_upper_z])
            translate([din_mount_x, electronics_center_y, din_z])
                rotate([0, 90, -90])
                    din_rail_ts35(length=din_length);

    // Purchased drivers and printable DIN carriers bridge the paired rails.
    driver_center_z = (din_lower_z + din_upper_z) / 2;
    if (show_stepper_drivers)
        for (driver_y = [-35, 70]) {
            translate([din_mount_x + 8, driver_y, driver_center_z])
                rotate([0, 0, 90])
                    din_driver_adapter(width=64, height=106);
            translate([din_mount_x + 13, driver_y, driver_center_z])
                rotate([0, 90, 0])
                    rotate([0, 0, 90])
                        microstep_driver_4a();
    }
}

// Generic threaded panel feedthrough. Local XY is the panel face; local +Z
// points inward. The colored barb and retaining flange remain outside.
module rear_bulkhead_fitting(tube_od=8, bore_d=6,
                             accent=[0.15, 0.55, 0.90]) {
    body_d = tube_od + 6;
    body_depth = 24;
    flange_d = body_d + 10;
    flange_t = 3;
    barb_length = 18;

    color([0.68, 0.69, 0.70]) {
        difference() {
            translate([0, 0, body_depth / 2])
                cylinder(d=body_d, h=body_depth, center=true, $fn=48);
            translate([0, 0, body_depth / 2])
                cylinder(d=bore_d, h=body_depth + 2, center=true, $fn=36);
        }
        translate([0, 0, -flange_t / 2])
            difference() {
                cylinder(d=flange_d, h=flange_t, center=true, $fn=48);
                cylinder(d=bore_d, h=flange_t + 2, center=true, $fn=36);
            }
    }

    color(accent)
        translate([0, 0, -flange_t - barb_length / 2])
            difference() {
                union() {
                    cylinder(d=tube_od, h=barb_length, center=true, $fn=40);
                    for (z = [-barb_length / 3, 0, barb_length / 3])
                        translate([0, 0, z])
                            cylinder(d1=tube_od + 2, d2=tube_od,
                                     h=2.5, center=true, $fn=40);
                }
                cylinder(d=bore_d, h=barb_length + 2, center=true, $fn=32);
            }
}

// ============================================================================
// Reusable assemblies
// ============================================================================
module outer_panels_assembly() {
    panel_color = [outer_panel_color[0], outer_panel_color[1],
                   outer_panel_color[2], outer_panel_opacity];
    bottom_color = [bottom_panel_color[0], bottom_panel_color[1],
                    bottom_panel_color[2], bottom_panel_opacity];

    // Panel edges intentionally land on extrusion centerlines. This preserves
    // the corrected fit while replacing the former +10/-30 compensation math.
    panel_left_x = left_frame_x;
    panel_right_x = right_frame_x;
    panel_front_y = front_frame_y - extrusion_profile / 2
                    - outer_panel_thickness / 2;
    panel_rear_y = rear_frame_y + extrusion_profile / 2
                   + outer_panel_thickness / 2;
    panel_bottom_z = lower_frame_z;
    panel_top_z = upper_frame_z;
    panel_center_z = (panel_bottom_z + panel_top_z) / 2;
    panel_height = panel_top_z - panel_bottom_z;
    side_center_y = (front_frame_y + rear_frame_y) / 2;
    side_depth = rear_frame_y - front_frame_y;

    cutting_panel_width = electronics_divider_x - panel_left_x;
    cutting_panel_center_x = (panel_left_x + electronics_divider_x) / 2;
    electronics_panel_width = panel_right_x - electronics_divider_x;
    electronics_panel_center_x =
        (electronics_divider_x + panel_right_x) / 2;

    // The cutting panel stops at the optical/tube shelf datum, leaving the
    // upper service opening clear. The electronics panel remains full height.
    cutting_panel_top_z = laser_offset;
    cutting_panel_height = cutting_panel_top_z - panel_bottom_z;
    cutting_panel_center_z = (panel_bottom_z + cutting_panel_top_z) / 2;

    // Opaque sheet-metal floor mounts beneath the lower 2020 members with its
    // top face flush to the Z=0 chassis datum. Its plan dimensions follow the
    // four perimeter-upright centerlines.
    if (show_bottom_panel)
        color(bottom_color)
            translate([(panel_left_x + panel_right_x) / 2,
                       side_center_y,
                       lower_frame_z - extrusion_profile / 2
                       - bottom_panel_thickness / 2])
                cube([panel_right_x - panel_left_x, side_depth,
                      bottom_panel_thickness], center=true);

    // Sealed rear laser-tube compartment. A1 remains inside this bay; only its
    // outgoing beam passes through the front bulkhead toward the moving A2.
    tube_bay_front_y = 400;
    tube_top_width = electronics_divider_x - panel_left_x;
    tube_top_depth = rear_frame_y - tube_bay_front_y;
    tube_panel_center_x = (panel_left_x + electronics_divider_x) / 2;
    tube_panel_thickness = bottom_panel_thickness;

    if (show_tube_top_panel)
        color(bottom_color)
            translate([tube_panel_center_x,
                       (tube_bay_front_y + rear_frame_y) / 2,
                       upper_frame_z + extrusion_profile / 2
                       + tube_panel_thickness / 2])
                cube([tube_top_width, tube_top_depth,
                      tube_panel_thickness], center=true);

    // Top cover for the isolated right-side electronics bay. Its left edge
    // starts at the outside face of the divider so it does not overlap the lid.
    electronics_top_left_x = electronics_divider_x + extrusion_profile / 2;
    electronics_top_right_x = right_frame_x;
    electronics_top_width =
        electronics_top_right_x - electronics_top_left_x;
    electronics_top_center_x =
        (electronics_top_left_x + electronics_top_right_x) / 2;

    if (show_electronics_top_panel)
        color(panel_color)
            translate([electronics_top_center_x,
                       (front_frame_y + rear_frame_y) / 2,
                       upper_frame_z + extrusion_profile / 2
                       + outer_panel_thickness / 2])
                cube([electronics_top_width,
                      rear_frame_y - front_frame_y,
                      outer_panel_thickness], center=true);

    // Floor sits directly beneath the tube-support cross rails. The round
    // clearance surrounds A1's fixed upright without opening the beam chamber
    // to the cutting area.
    tube_floor_edge_clearance = 10;
    tube_floor_left_x = panel_left_x + extrusion_profile / 2
                        + tube_floor_edge_clearance;
    // The electronics divider is a rotated 2040 with 40 mm across X.
    tube_floor_right_x = electronics_divider_x
                         - tube_floor_edge_clearance;
    // Extend beneath both Y-boundary rails to close the full tube-bay depth.
    tube_floor_front_y = tube_bay_front_y;
    tube_floor_rear_y = rear_frame_y;
    tube_floor_width = tube_floor_right_x - tube_floor_left_x;
    tube_floor_depth = tube_floor_rear_y - tube_floor_front_y;
    tube_floor_center_x = (tube_floor_left_x + tube_floor_right_x) / 2;
    tube_floor_center_y = (tube_floor_front_y + tube_floor_rear_y) / 2;
    tube_floor_mount_clearance = 10;
    tube_floor_z = 64 + gantry_z_adjustment - extrusion_profile / 2
                   - tube_floor_mount_clearance
                   - tube_panel_thickness / 2;
    tube_floor_installed_z = tube_floor_z - tube_floor_panel_drop + 10;
    if (show_tube_floor_panel)
        color(bottom_color)
            difference() {
                translate([tube_floor_center_x, tube_floor_center_y,
                           tube_floor_installed_z])
                    cube([tube_floor_width, tube_floor_depth,
                          tube_panel_thickness], center=true);
                translate([-465, laser_tube_y + 5,
                           tube_floor_installed_z])
                    cylinder(d=34, h=tube_panel_thickness + 4,
                             center=true, $fn=48);
            }

    // Front smoke/light bulkhead mounts on the tube side of the Y=400 rail.
    // A short pass-through sleeve provides a controlled aperture for the beam
    // from A1 to A2 and follows the selected optical-plane elevation.
    tube_bulkhead_bottom_z = 74 + gantry_z_adjustment;
    tube_bulkhead_top_z = upper_frame_z - extrusion_profile / 2;
    tube_bulkhead_height = tube_bulkhead_top_z - tube_bulkhead_bottom_z;
    tube_bulkhead_center_z =
        (tube_bulkhead_bottom_z + tube_bulkhead_top_z) / 2;
    beam_aperture_z = laser_offset + gantry_z_adjustment;
    beam_aperture_d = 18;
    tube_bulkhead_y = tube_bay_front_y + extrusion_profile / 2
                      + tube_panel_thickness / 2;

    if (show_tube_front_bulkhead) {
        color(bottom_color)
            difference() {
                translate([tube_floor_center_x, tube_bulkhead_y,
                           tube_bulkhead_center_z])
                    cube([tube_floor_width, tube_panel_thickness,
                          tube_bulkhead_height], center=true);
                translate([-465, tube_bulkhead_y, beam_aperture_z])
                    rotate([90, 0, 0])
                        cylinder(d=beam_aperture_d,
                                 h=tube_panel_thickness + 4,
                                 center=true, $fn=48);
            }

        color([0.06, 0.065, 0.07])
            translate([-465, tube_bulkhead_y, beam_aperture_z])
                rotate([90, 0, 0])
                    difference() {
                        cylinder(d=beam_aperture_d + 8, h=8,
                                 center=true, $fn=48);
                        cylinder(d=beam_aperture_d, h=10,
                                 center=true, $fn=48);
                    }
    }

    if (show_front_panel && show_front_cutting_panel)
        color(panel_color)
            translate([cutting_panel_center_x, panel_front_y,
                       cutting_panel_center_z])
                cube([cutting_panel_width, outer_panel_thickness,
                      cutting_panel_height], center=true);

    if (show_front_panel && show_front_electronics_panel)
        color(panel_color)
            translate([electronics_panel_center_x, panel_front_y,
                       panel_center_z])
                cube([electronics_panel_width, outer_panel_thickness,
                      panel_height], center=true);

    // Rear skin with a genuine opening behind the tube service hatch.
    tube_hatch_width = 1000;
    tube_hatch_height = 136;
    tube_hatch_center_x = 0;
    tube_hatch_center_z = laser_offset + gantry_z_adjustment;
    tube_hatch_hinge_z = tube_hatch_center_z + tube_hatch_height / 2;

    // Rear service connections occupy the fixed electronics strip to the
    // right of the tube hatch, clear of its hinges and swing envelope.
    iec_inlet_x = 610;
    iec_inlet_z = 30;
    air_bulkhead_x = 550;
    air_bulkhead_z = 95;
    water_supply_x = 610;
    water_return_x = 660;
    water_bulkhead_z = 105;

    if (show_rear_panel)
        color(panel_color)
            difference() {
                translate([(panel_left_x + panel_right_x) / 2,
                           panel_rear_y, panel_center_z])
                    cube([panel_right_x - panel_left_x,
                          outer_panel_thickness, panel_height], center=true);
                translate([tube_hatch_center_x, panel_rear_y,
                           tube_hatch_center_z])
                    cube([tube_hatch_width, outer_panel_thickness + 4,
                          tube_hatch_height], center=true);
                if (show_rear_service_connections && show_iec_power_inlet)
                    translate([iec_inlet_x, panel_rear_y, iec_inlet_z])
                        cube([48, outer_panel_thickness + 4, 28], center=true);
                if (show_rear_service_connections && show_air_assist_bulkhead)
                    translate([air_bulkhead_x, panel_rear_y, air_bulkhead_z])
                        rotate([90, 0, 0])
                            cylinder(d=14, h=outer_panel_thickness + 4,
                                     center=true, $fn=40);
                if (show_rear_service_connections && show_water_cooling_bulkheads)
                    for (water_x = [water_supply_x, water_return_x])
                        translate([water_x, panel_rear_y, water_bulkhead_z])
                            rotate([90, 0, 0])
                                cylinder(d=16, h=outer_panel_thickness + 4,
                                         center=true, $fn=40);
            }

    if (show_rear_panel && show_rear_service_connections) {
        rear_service_face_y = panel_rear_y + outer_panel_thickness / 2;

        if (show_iec_power_inlet)
            // User IEC model is referenced from its 47 x 27 mm body center;
            // its faceplate points outward (+Y) and body extends inward (-Y).
            translate([iec_inlet_x - 23.5,
                       rear_service_face_y,
                       iec_inlet_z - 13.5])
                iec_fused_inlet_model();

        if (show_air_assist_bulkhead)
            translate([air_bulkhead_x, rear_service_face_y, air_bulkhead_z])
                rotate([90, 0, 0])
                    rear_bulkhead_fitting(
                        tube_od=8, bore_d=6, accent=[0.15, 0.55, 0.90]);

        if (show_water_cooling_bulkheads) {
            translate([water_supply_x, rear_service_face_y, water_bulkhead_z])
                rotate([90, 0, 0])
                    rear_bulkhead_fitting(
                        tube_od=10, bore_d=8, accent=[0.15, 0.45, 0.95]);
            translate([water_return_x, rear_service_face_y, water_bulkhead_z])
                rotate([90, 0, 0])
                    rear_bulkhead_fitting(
                        tube_od=10, bore_d=8, accent=[0.90, 0.20, 0.15]);
        }
    }

    if (show_rear_panel && show_tube_access_door)
        translate([tube_hatch_center_x,
                   panel_rear_y + outer_panel_thickness,
                   tube_hatch_hinge_z])
            rotate([tube_access_door_angle, 0, 0]) {
                color(panel_color)
                    translate([0, 0, -tube_hatch_height / 2])
                        cube([tube_hatch_width, outer_panel_thickness,
                              tube_hatch_height], center=true);
                // Two exterior pull/latch blocks travel with the hatch.
                color([0.08, 0.09, 0.10])
                    for (x = [-350, 350])
                        translate([x, outer_panel_thickness + 4,
                                   -tube_hatch_height + 18])
                            cube([38, 10, 24], center=true);
            }

    // Right wall and service opening. A fixed 25 mm border remains around the
    // door opening for stiffness, gasket compression, hinges, and a latch.
    electronics_bay_rear_y = rear_frame_y;
    electronics_opening_border = 25;
    electronics_door_overlap = 10;
    electronics_opening_front_y = front_frame_y + electronics_opening_border;
    electronics_opening_rear_y =
        electronics_bay_rear_y - electronics_opening_border;
    electronics_opening_bottom_z = panel_bottom_z + electronics_opening_border;
    electronics_opening_top_z = panel_top_z - electronics_opening_border;
    electronics_opening_depth =
        electronics_opening_rear_y - electronics_opening_front_y;
    electronics_opening_height =
        electronics_opening_top_z - electronics_opening_bottom_z;
    electronics_opening_center_y =
        (electronics_opening_front_y + electronics_opening_rear_y) / 2;
    electronics_opening_center_z =
        (electronics_opening_bottom_z + electronics_opening_top_z) / 2;

    right_panel_x = panel_right_x + extrusion_profile / 2
                    + outer_panel_thickness / 2;

    if (show_right_panel)
        color(panel_color)
            difference() {
                translate([right_panel_x, side_center_y, panel_center_z])
                    cube([outer_panel_thickness, side_depth,
                          panel_height], center=true);
                translate([right_panel_x, electronics_opening_center_y,
                           electronics_opening_center_z])
                    cube([outer_panel_thickness + 4,
                          electronics_opening_depth,
                          electronics_opening_height], center=true);
            }

    // Door overlaps the opening by 10 mm on every edge. Its rear vertical
    // hinge is anchored in the fixed panel border; positive angle opens +X.
    electronics_door_front_y =
        electronics_opening_front_y - electronics_door_overlap;
    electronics_door_rear_y =
        electronics_opening_rear_y + electronics_door_overlap;
    electronics_door_bottom_z =
        electronics_opening_bottom_z - electronics_door_overlap;
    electronics_door_top_z =
        electronics_opening_top_z + electronics_door_overlap;
    electronics_door_depth = electronics_door_rear_y - electronics_door_front_y;
    electronics_door_height = electronics_door_top_z - electronics_door_bottom_z;
    electronics_door_center_z =
        (electronics_door_bottom_z + electronics_door_top_z) / 2;

    if (show_electronics_access_door) {
        translate([right_panel_x + outer_panel_thickness,
                   electronics_door_rear_y, electronics_door_center_z])
            rotate([0, 0, electronics_door_angle]) {
                color(panel_color)
                    translate([0, -electronics_door_depth / 2, 0])
                        cube([outer_panel_thickness, electronics_door_depth,
                              electronics_door_height], center=true);
                // Recessed pull/latch at the free edge.
                color([0.08, 0.09, 0.10])
                    translate([outer_panel_thickness + 5,
                               -electronics_door_depth + 22, 0])
                        cube([10, 32, 76], center=true);
            }

        // Three simple hinge barrels remain fixed to the rear door jamb.
        color([0.60, 0.61, 0.62])
            for (hinge_z = [electronics_door_bottom_z + 35,
                            electronics_door_center_z,
                            electronics_door_top_z - 35])
                translate([right_panel_x + outer_panel_thickness + 3,
                           electronics_door_rear_y, hinge_z])
                    cylinder(d=8, h=30, center=true, $fn=32);
    }

    // Parent-assembly-style two-piece lift-off left wall. Either half may be
    // pulled outward for an exploded view or hidden to remove it completely.
    left_panel_split_z = (panel_bottom_z + panel_top_z) / 2;
    panel_seam = 4;
    lower_top_z = left_panel_split_z - panel_seam / 2;
    upper_bottom_z = left_panel_split_z + panel_seam / 2;
    lower_height = lower_top_z - panel_bottom_z;
    upper_height = panel_top_z - upper_bottom_z;

    if (show_left_lower_access_panel)
        lift_off_left_panel(
            x=panel_left_x - extrusion_profile / 2
              - outer_panel_thickness / 2 - left_lower_panel_pull,
            y=side_center_y,
            z=(panel_bottom_z + lower_top_z) / 2,
            depth=side_depth,
            height=lower_height);

    // Aluminum backing strip is fixed to the lower removable panel and
    // projects behind the upper panel to close the light/smoke seam. It moves
    // with the lower panel and leaves no permanent bar across the opening.
    if (show_left_lower_access_panel && show_left_panel_overlap_strip) {
        overlap_strip_thickness = 2;
        overlap_strip_height = 32;
        overlap_strip_end_clearance = 20;
        left_frame_outer_x = panel_left_x - extrusion_profile / 2;

        color([0.60, 0.62, 0.64])
            translate([left_frame_outer_x + overlap_strip_thickness / 2
                       - left_lower_panel_pull,
                       side_center_y, left_panel_split_z])
                cube([overlap_strip_thickness,
                      side_depth - 2 * overlap_strip_end_clearance,
                      overlap_strip_height], center=true);
    }

    if (show_left_upper_access_panel)
        lift_off_left_panel(
            x=panel_left_x - extrusion_profile / 2
              - outer_panel_thickness / 2 - left_upper_panel_pull,
            y=side_center_y,
            z=(upper_bottom_z + panel_top_z) / 2,
            depth=side_depth,
            height=upper_height);
}

module lift_off_left_panel(x, y, z, depth, height) {
    color([outer_panel_color[0], outer_panel_color[1],
           outer_panel_color[2], outer_panel_opacity])
        translate([x, y, z])
            cube([outer_panel_thickness, depth, height], center=true);

    // Horizontal pull handle leaves with each removable panel.
    color([0.08, 0.09, 0.10]) {
        for (handle_y = [y - 45, y + 45])
            translate([x - 9, handle_y, z])
                rotate([0, 90, 0]) cylinder(d=12, h=15, center=true, $fn=32);
        translate([x - 17, y, z])
            rotate([90, 0, 0]) cylinder(d=12, h=90, center=true, $fn=32);
    }
}

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
    glass_color = [lid_panel_color[0], lid_panel_color[1],
                   lid_panel_color[2], lid_panel_opacity];

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
            if (show_all_panels)
                color(glass_color) {
                    translate([0, -lid_depth / 2, -10 + glass_thickness / 2])
                        cube([lid_width - 40, lid_depth, glass_thickness], center=true);

                    rotate([90, 0, 0])
                        translate([0, -lid_height + 30,
                                   lid_depth + 10 + glass_thickness / 2])
                            cube([lid_width - 40, lid_height,
                                  glass_thickness], center=true);
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
