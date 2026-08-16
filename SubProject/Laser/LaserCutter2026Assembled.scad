// ============================================================================
// Dependencies
// ============================================================================
use <Laser_Tube.scad>;
use <LaserTubeMount.scad>;
use <A1-RearMirrorMount.scad>;
use <A1-MirrorPedestal.scad>;
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
use <kp08_pillow_block_bearing.scad>;
use <gt2_gears.scad>;
use <iec_fused_inlet.scad>;
use <../../laser_parts.scad>;
use <nema17_motor_plate.scad>;
use <parametric_drag_chain.scad>;
use <x_drag_chain_carriage_bracket.scad>;
use <x_drag_chain_fixed_bracket.scad>;
use <y_drag_chain_brackets.scad>;



// ============================================================================
// Interactive positioning
// ============================================================================
X_Pos = -375; // Laser head position; approximately -375 min, 345 max
Y_Pos = 100;   // Gantry position; approximately -43 min, +307 max
y_axis_y_adjustment = 15; // Fine alignment: positive moves both Y rails and X gantry toward +Y
Y_Stage_Pos = Y_Pos + y_axis_y_adjustment;
y_rail_center_y = 130 + y_axis_y_adjustment;
y_rail_support_length = 515;
y_rail_support_front_y = -105; // Preserve the original front endpoint
y_rail_support_center_y =
    y_rail_support_front_y + y_rail_support_length/2;
y_axis_drive_offset = 7; // Fine Y adjustment for the complete drive axle
y_drive_axle_y = 365 + y_axis_drive_offset;
gantry_z_adjustment = 60; // Raise/lower complete moving gantry for clearance checks
y_idler_tension = 7.5;    // 0-15 mm; larger values increase Y-belt tension
show_y_idler_tensioners = true;
show_y_idler_support_rails = true;
show_y_motor_belt = true;
show_x_drag_chain = true;
show_x_drag_chain_bracket = true;
show_x_drag_chain_fixed_bracket = true;
show_y_drag_chain = true;
show_y_drag_chain_brackets = true;
x_drive_flip_y = true; // Put the X stepper on the drag-chain side of the gantry
x_drive_y_offset = 0; // Belt [-3,+3] sits inside pulley tooth track [-4,+4]
show_a1_mirror_pedestal = true;
y_motor_z_adjustment = 11.43; // Positions the Y motor for a 200 mm / 100T GT2 belt
y_motor_pulley_axial_adjustment = 1.5;
x_drag_chain_fixed_x = 460;
x_drag_chain_y = 45;
x_drag_chain_base_z = 175; // Clears the flipped X motor and remains above the X belt
x_drag_chain_links = 68; // 986 mm pitch length; full X span plus margin
x_drag_chain_carriage = x_drag_chain_fixed_x - X_Pos;
y_drag_chain_x = 468; // Clears the gantry plate with added edge margin on the crossbar
y_drag_chain_fixed_y = 350; // Stationary attachment on the right chassis rail
y_drag_chain_base_z = 5; // Entire chain envelope stays beneath the Y rail
y_drag_chain_links = 36; // 522 mm pitch length for the complete Y travel
y_drag_chain_carriage = y_drag_chain_fixed_y - Y_Stage_Pos;


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
show_exhaust_shroud = true;
exhaust_shroud_diameter = 152; // Nominal 6-inch cutting-chamber duct
exhaust_shroud_depth = 30;
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
show_electronics_operator_controls = true;
show_laser_power_supply = true;
show_stepper_drivers = true;
show_din_rails = true;
show_left_lower_access_panel = true;
show_left_upper_access_panel = true;
show_left_panel_overlap_strip = true;

leveling_foot_adjustment = 12; // Exposed 3/8-16 stud below socket: 0–22.86 mm
outer_panel_thickness = 2;
outer_panel_color = [0.24, 0.28, 0.32]; // RGB values from 0 to 1
//outer_panel_color = [0.84, 0.88, 0.92]; // RGB values from 0 to 1
outer_panel_opacity = 0.92;

// Opaque sheet-metal floor (separate from the acrylic enclosure panels)
bottom_panel_thickness = 25.4 / 16; // 1/16 inch = 1.5875 mm
bottom_panel_color = [0.55, 0.57, 0.59];
bottom_panel_opacity = 1.0;

// Lid attributes
show_lid = true;
show_lid_panels = true; // Acrylic only; the lid extrusion frame remains visible
show_lid_handle = true;
lid_handle_width = 180;
lid_handle_projection = 34;
lid_panel_color = [0.35, 0.35, 0.35]; // RGB values from 0 to 1
lid_panel_opacity = 0.10;
lid_angle = 120;


//Tube Access
tube_access_door_angle = 120;       // 0=closed; positive opens outward/upward
electronics_door_angle = 120;       // 0=closed; positive opens outward/right

// Left panel doors
left_upper_panel_pull = 200;
left_lower_panel_pull = 100;        // Pull outward in -X; hide to remove completely


// Tube Floor
tube_floor_panel_drop = 0;        // Positive value lowers floor for inspection


show_honeycomb=true;


// ============================================================================
// Machine dimensions
// ============================================================================
cabinet_y_extension = 15;
frame_width = 1219.2; // One full 48-inch 2020 extrusion
frame_depth = 650 + cabinet_y_extension;
frame_height = 360;

// Shared chassis datums. Panel dimensions are derived from these structural
// member centerlines so enclosure changes track future frame revisions.
extrusion_profile = 20;
left_frame_x = -510;
electronics_divider_x = 510;
right_frame_x = left_frame_x + frame_width - extrusion_profile;
front_frame_y = -115;
rear_frame_y = 500 + cabinet_y_extension;
gantry_rear_y = 400 + cabinet_y_extension;
lower_frame_z = -62;
upper_frame_z = frame_height - 82;

lid_height = 90;
lid_width = 1040;
lid_depth = 495 + cabinet_y_extension;



// ============================================================================
// Assembly offsets
// ============================================================================
laser_tube_y = 450 + cabinet_y_extension;
laser_offset = 70 + 88;
a1_mount_x = -465;
a1_mount_y = laser_tube_y + 5;
a1_base_lift = 50;
a1_base_z = -52 + a1_base_lift;
y_belt_offset = 429;
y_idler_mount_y = front_frame_y + 10;
e_panel_thickness = 4;

// Y-drive reduction-belt datums.  gt2_toothed_pulley(center=true) centers its
// complete body including the asymmetric collar, so the toothed belt plane is
// offset from the module origin.  The 60T and motor pulley tooth faces are
// aligned here at X=21.5 rather than at their shaft/collar centers.
y_drive_belt_plane_x = 21.5;
y_drive_pulley_center = [y_drive_belt_plane_x,
                         y_drive_axle_y,
                         89 + gantry_z_adjustment];
// Base Z=20 preserves the current motor position when gantry_z_adjustment=60.
// Motor and drive axle now rise/fall together, keeping belt length constant.
y_motor_mount_origin = [10,
                        gantry_rear_y-32,
                        20 + gantry_z_adjustment + y_motor_z_adjustment];
y_motor_pulley_center = [y_drive_belt_plane_x,
                         y_motor_mount_origin[1],
                         y_motor_mount_origin[2]];
y_drive_pulley_teeth = 60;
y_motor_pulley_teeth = 20;
y_motor_belt_pitch = 2;
y_drive_pitch_diameter = y_drive_pulley_teeth * y_motor_belt_pitch / PI;
y_motor_pitch_diameter = y_motor_pulley_teeth * y_motor_belt_pitch / PI;
y_motor_pulley_distance = norm(y_drive_pulley_center-y_motor_pulley_center);
y_motor_belt_length =
    2*y_motor_pulley_distance
    + PI/2*(y_drive_pitch_diameter+y_motor_pitch_diameter)
    + pow(y_drive_pitch_diameter-y_motor_pitch_diameter, 2)
      /(4*y_motor_pulley_distance);
y_motor_nearest_belt_teeth = round(y_motor_belt_length/y_motor_belt_pitch);
y_motor_nearest_belt_length =
    y_motor_nearest_belt_teeth*y_motor_belt_pitch;

echo(str("Approximate Y motor GT2 belt pitch length: ",
         y_motor_belt_length,
         " mm; nearest pitch length is ",
         y_motor_nearest_belt_length,
         " mm / ",
         y_motor_nearest_belt_teeth,
         " teeth"));

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
translate([0, 0, -gantry_z_adjustment + a1_base_lift])
  translate([a1_mount_x, a1_mount_y, -52])
    AssembledRearMirrorMount(
        zOffset=52 + gantry_z_adjustment-a1_base_lift,
        laser=false);


// Y-axis idlers. Their mounting datum and belt axis follow the complete
// gantry-height adjustment together with the Y rails and drive hardware.
if (show_y_idler_tensioners)
    translate([y_belt_offset, y_idler_mount_y, 64])
        y_axis_idler_tensioner_assembly(
            tension=y_idler_tension,
            mirrored=false);
color("green") 
        gt2_belt(
            p1=[y_belt_offset, y_idler_mount_y + 30 - y_idler_tension, 89],
            p2=[y_belt_offset, y_drive_axle_y, 89],
            width=6);

if (show_y_idler_tensioners)
    translate([-y_belt_offset, y_idler_mount_y, 64])
        y_axis_idler_tensioner_assembly(
            tension=y_idler_tension,
            mirrored=true);
color("green") 
        gt2_belt(
            p1=[-y_belt_offset, y_idler_mount_y + 30 - y_idler_tension, 89],
            p2=[-y_belt_offset, y_drive_axle_y, 89],
            width=6);

} // Fixed optics, Y belts, and tube move with the complete gantry plane

// Fixed structural support for the A1 base.  The optical upright continues to
// follow gantry_z_adjustment, but this pedestal remains tied to the chassis.
if (show_a1_mirror_pedestal)
    translate([a1_mount_x,
               a1_mount_y,
               lower_frame_z + extrusion_profile/2])
        a1_mirror_pedestal(
            height=a1_base_z
                   - (lower_frame_z + extrusion_profile/2));
        
        

// Y axis drive
translate([0, 0, gantry_z_adjustment]) {

translate([410,y_drive_axle_y,74])
  kp08_pillow_block_assembly();

translate([-410,y_drive_axle_y,74])
  kp08_pillow_block_assembly();
  
// Y Drive Axle
translate([0,y_drive_axle_y,89])
  rotate([0,90,0])cylinder(d=8,h=870, center=true);
  
// Y drive gear
translate([18,y_drive_axle_y,89])
  rotate([0,-90,0])
    gt2_toothed_pulley(teeth=60, bore=8, width=9, center=true, m_shaft_lock_dia=25);

// Y Pulleys
translate([425,y_drive_axle_y,89])
  rotate([0,-90,0]) 
    gt2_toothed_pulley(teeth=20, bore=8, width=9, center=true);

translate([-425,y_drive_axle_y,89])
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
                cylinder(d=2, h=(laser_tube_y - (Y_Stage_Pos - 35)));

        // --- BEAM Segment 3: Moving A2 Mirror to Sliding A3 Laser Focuser Head ---
        translate([-465, Y_Stage_Pos-35, 158])
            rotate([0, 90, 0]) 
                cylinder(d=2, h=(X_Pos - (-465)));
                
        // --- BEAM Segment 4: Downward Cut Path (Nozzle Tip to Honeycomb Bed) ---
        // Pushes straight down to meet the new metal honeycomb mesh grid top line
        translate([X_Pos, Y_Stage_Pos - 35, 158])
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
    translate([0, gantry_rear_y - extrusion_profile,
               frame_height - 82])
        lid_assembly(lid_angle);

 

// =======================================================================
// DYNAMIC Y-AXIS STAGE (Moves entire crossbar assembly along Y_Pos)
// =======================================================================
translate([0, Y_Stage_Pos, gantry_z_adjustment]) {

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
    translate([-415, 0, 114])
        x_axis_idler_assembly();
        
    // X-Axis Stepper Drive Assembly Block (Far Right Side)
    translate([420, x_drive_y_offset, 115])
        if (x_drive_flip_y)
            mirror([0, 1, 0]) x_axis_drive_assembly();
        else
            x_axis_drive_assembly();
        
    // X-Axis Visual Timing Belt Loop
    color("green") translate([0, 0, 135 + 4])
        gt2_belt(p1=[-415, 0, 0], p2=[420, 0, 0], width=6); 

    // X-carriage cable chain. The blue end is fixed near the right drive;
    // the inverted red end follows X_Pos on the opposite (+Y) side of A4.
    if (show_x_drag_chain)
        translate([x_drag_chain_fixed_x,
                   x_drag_chain_y,
                   x_drag_chain_base_z])
            parametric_drag_chain(
                carriage=x_drag_chain_carriage,
                links=x_drag_chain_links,
                mirrored=true,
                show_ends=true,
                show_pins=true);

    // Fixed blue-end support shares the upper X-motor mounting screws and
    // bridges above the motor.  Its arms stay outside the NEMA-17 envelope.
    if (show_x_drag_chain_fixed_bracket)
        translate([420, x_drive_y_offset, 115])
            x_drag_chain_fixed_bracket(
                show_hardware=true,
                chain_x=x_drag_chain_fixed_x + 10 - 420,
                chain_y=x_drag_chain_y - x_drive_y_offset,
                shelf_top_z=x_drag_chain_base_z - 7.5 - 115);

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

        // Uses the two existing M3 tapped holes on the A4 plate's +Y end
        // face and presents an M4 shelf under the moving red chain connector.
        if (show_x_drag_chain_bracket)
            translate([0, 20, 130])
                x_drag_chain_carriage_bracket(show_hardware=true);
    }

    // Moving red end: bolts into the underside T-slot of the moving X-gantry
    // crossbar and delivers the X-motor/focuser wiring onto that gantry.
    if (show_y_drag_chain_brackets)
        // The crossbar is centered at Z=104, so its underside is Z=94.
        translate([y_drag_chain_x, 0, 94])
            y_drag_chain_moving_bracket(
                show_hardware=true,
                chain_x=0,
                shelf_top_z=y_drag_chain_base_z + 2*18 - 7.5 - 94);
}

// Right-side Y cable chain.  Rotating the proven X-chain kinematics 90 degrees
// makes its moving red end follow Y_Stage_Pos while the blue end stays at the
// stationary right-side chassis rail.  Its complete envelope remains outboard
// of the Y belt/rail; only the red endpoint follows the gantry.
if (show_y_drag_chain)
    translate([y_drag_chain_x,
               y_drag_chain_fixed_y,
               y_drag_chain_base_z + gantry_z_adjustment])
        rotate([0, 0, 90])
            parametric_drag_chain(
                carriage=y_drag_chain_carriage,
                links=y_drag_chain_links,
                mirrored=true,
                show_ends=true,
                show_pins=true);

if (show_y_drag_chain_brackets)
    // This blue-end bracket bolts to the inboard face (X=500) of the fixed
    // longitudinal 2020 centered at X=510,
    // not to the rear X-gantry crossmember.
    translate([500,
               y_drag_chain_fixed_y,
               64 + gantry_z_adjustment])
        y_drag_chain_fixed_bracket(
            show_hardware=true,
            shelf_top_z=y_drag_chain_base_z - 7.5 - 64,
            chain_x=y_drag_chain_x - 500,
            chain_y=10);


// =======================================================================
// FIXED Y-AXIS GUIDE RAILS (Main Frame Base Tunnels)
// =======================================================================
translate([0, 0, gantry_z_adjustment]) {

// Y Right
translate([410, y_rail_center_y, 74])
    mgn12h_with_rail(
        rail_length=400,
        carriage_pos=Y_Stage_Pos-y_rail_center_y,
        include_stops=false);
translate([410, y_rail_support_center_y, 64])
    rotate([0, 90, 90])
        aluminum_extrusion_2020(
            length=y_rail_support_length,
            center=true,
            black=true);

// Y Left
translate([-410, y_rail_center_y, 74])
    mgn12h_with_rail(
        rail_length=400,
        carriage_pos=Y_Stage_Pos-y_rail_center_y,
        include_stops=false);
translate([-410, y_rail_support_center_y, 64])
    rotate([0, 90, 90])
        aluminum_extrusion_2020(
            length=y_rail_support_length,
            center=true,
            black=true);


// Front of Gantry
translate([0, -115, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);

// Dedicated longitudinal supports for the two Y-belt tensioners.  Each rail
// lies directly below the tensioner's 56 mm base and crosses the existing
// front member, allowing both M5 saddle fasteners to engage a 2020 T-slot.
if (show_y_idler_support_rails)
    for (idler_x=[-y_belt_offset, y_belt_offset])
        translate([idler_x, y_idler_mount_y + 8, 64])
            rotate([0, 90, 90])
                aluminum_extrusion_2020(
                    length=56,
                    center=true,
                    black=true);
// Back of Gantry
translate([0, gantry_rear_y, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);
// back of CO2 Tube
translate([-500, rear_frame_y, 64]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width-40);


//Right side of gantry
translate([510, 202 + cabinet_y_extension/2, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=575 + cabinet_y_extension, center=true);
//Left side of gantry
translate([-510, 192 + cabinet_y_extension/2, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true, black=true);


// Cross supports
translate([303, laser_tube_y, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
translate([257, laser_tube_y, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
// Cross supports
translate([-303, laser_tube_y, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);
translate([-257, laser_tube_y, 64]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=80, center=true, black=true);

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
translate([689.2, rear_frame_y, -52])aluminum_extrusion_2020(length=frame_height-20);

// Split rear posts terminate at the moving gantry rail. Their outside ends
// stay fixed while the lower segment grows and the upper segment shrinks.
split_post_bottom_z = -52;
gantry_rail_bottom_z = 54 + gantry_z_adjustment;
gantry_rail_top_z = 74 + gantry_z_adjustment;
rear_post_top_z = 269;
electronics_post_top_z = 249;


// Back bottom of gantry
translate([0, gantry_rear_y, -62]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);

// Y Motor Support
translate([0, gantry_rear_y, split_post_bottom_z])
  rotate([0,0,90])
    aluminum_extrusion_2020(length=gantry_rail_bottom_z-split_post_bottom_z);

// Y Motor Assembly()
translate(y_motor_mount_origin)
  rotate([180,-90,0])
    nema_17_mount_plate_assembly(
        pulley_axial_adjustment=y_motor_pulley_axial_adjustment);

// 60T axle pulley to 20T motor pulley reduction belt.  Its upper endpoint
// follows gantry_z_adjustment while the chassis-mounted motor remains fixed.
if (show_y_motor_belt)
    color("DimGray", 0.9)
        gt2_belt(
            p1=y_motor_pulley_center,
            p2=y_drive_pulley_center,
            r1=y_motor_pitch_diameter/2,
            r2=y_drive_pitch_diameter/2,
            width=6);

// Right back gantry post
translate([510, rear_frame_y, gantry_rail_top_z])
  rotate([0,0,90])
    aluminum_extrusion_2020(length=rear_post_top_z-gantry_rail_top_z);
translate([510, rear_frame_y, split_post_bottom_z])
  rotate([0,0,90])
    aluminum_extrusion_2020(length=gantry_rail_bottom_z-split_post_bottom_z);

//Rails to mount electronics panel
color("orange")
  translate([510, rear_frame_y-20, gantry_rail_top_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=electronics_post_top_z-gantry_rail_top_z);

//bulkhead right
  translate([510, gantry_rear_y, gantry_rail_top_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=electronics_post_top_z-gantry_rail_top_z);

//bulkhead left
  translate([-510, gantry_rear_y, gantry_rail_top_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=electronics_post_top_z-gantry_rail_top_z+20);

//color("orange")
  translate([510, rear_frame_y-20, split_post_bottom_z])
    rotate([0,0,90])
      aluminum_extrusion_2020(
          length=gantry_rail_bottom_z-split_post_bottom_z);
//color("orange")translate([510, 192 + cabinet_y_extension/2, -42]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=555 + cabinet_y_extension, center=true);


// left back
translate([-510, rear_frame_y, -52])aluminum_extrusion_2020(length=frame_height-20);



//Bottom front
translate([-520, -115, -62]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width);
//Bottom left
translate([-510, 192 + cabinet_y_extension/2, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true);
//Bottom back
translate([-520, rear_frame_y, -62]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width);
//Bottom right of gantry
translate([510, 192 + cabinet_y_extension/2, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true);
//Bottom right
translate([689.2, 192 + cabinet_y_extension/2, -62]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true);


// A1 mirror supports
//translate([-465+20, 192, -62]) rotate([90, 0, 0]) aluminum_extrusion_2020(length=635-40, center=true, black=true);
//translate([-465-20, 192, -62]) rotate([90, 0, 0]) aluminum_extrusion_2020(length=635-40, center=true, black=true);


if (show_leveling_feet)
    leveling_feet_assembly();



//top front main
color("silver")translate([0, -115, frame_height-82-20-lid_height]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true, black=true);
//top back
color("silver")translate([-520, rear_frame_y, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=frame_width, black=true);

//top Right side of gantry
color("silver")translate([510, 202 + cabinet_y_extension/2, frame_height-82-10]) rotate([0, 90, 90]) aluminum_extrusion_2040(length=575 + cabinet_y_extension, center=true, black=true);
//top Left side 
color("silver")translate([-510, 192 + cabinet_y_extension/2, frame_height-82]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true, black=true);
//Bottom right
color("silver")translate([689.2, 192 + cabinet_y_extension/2, frame_height-82]) rotate([0, 90, 90]) aluminum_extrusion_2020(length=595 + cabinet_y_extension, center=true, black=true);

//top right electronics bay
color("silver")translate([600, -115, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=160, center=true, black=true);

//Lid-mating peice
translate([0, gantry_rear_y, frame_height-82]) rotate([0, 90, 0]) aluminum_extrusion_2020(length=1000, center=true);


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
    operator_panel_x = electronics_panel_center_x;
    galvanometer_x = operator_panel_x;
    galvanometer_z = 220;
    estop_x = electronics_divider_x + 45;
    key_switch_x = panel_right_x - 45;
    operator_control_z = 110;
    pendant_connector_x = operator_panel_x;
    pendant_connector_z = 45;

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
    tube_bay_front_y = gantry_rear_y;
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
    electronics_top_panel_z = upper_frame_z + extrusion_profile / 2
                              + outer_panel_thickness / 2;
    ruida_panel_x = electronics_top_center_x;
    ruida_panel_y = front_frame_y + 70;

    if (show_electronics_top_panel)
        color(panel_color)
            difference() {
                translate([electronics_top_center_x,
                           (front_frame_y + rear_frame_y) / 2,
                           electronics_top_panel_z])
                    cube([electronics_top_width,
                          rear_frame_y - front_frame_y,
                          outer_panel_thickness], center=true);
                if (show_electronics_operator_controls)
                    translate([ruida_panel_x, ruida_panel_y,
                               electronics_top_panel_z])
                        cube([106, 66, outer_panel_thickness + 4],
                             center=true);
            }

    // Floor sits directly beneath the tube-support cross rails. The round
    // clearance surrounds A1's fixed upright without opening the beam chamber
    // to the cutting area.
    tube_floor_edge_clearance = 10;
    // Reach the left frame extrusion centerline so the tube floor closes the
    // same side gap as the front bulkhead.
    tube_floor_left_x = panel_left_x;
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
    // Center the exhaust between the lower rear extrusion and the underside
    // of the tube floor. This keeps it in the cutting chamber as gantry height
    // changes, rather than venting the isolated tube cavity.
    exhaust_lower_limit_z = lower_frame_z + extrusion_profile / 2;
    exhaust_upper_limit_z =
        tube_floor_installed_z - tube_panel_thickness / 2;
    exhaust_shroud_x = 0;
    exhaust_shroud_z =
        (exhaust_lower_limit_z + exhaust_upper_limit_z) / 2;
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

    // Front smoke/light bulkhead mounts on the cutting-area side of the rear
    // gantry rail, leaving the tube bay side of the extrusion unobstructed.
    // A short pass-through sleeve provides a controlled aperture for the beam
    // from A1 to A2 and follows the selected optical-plane elevation.
    // Add 20 mm of mounting height, then raise the envelope 10 mm so it
    // overlaps both the lower and upper extrusion faces for fastening.
    tube_bulkhead_mount_overlap = extrusion_profile;
    tube_bulkhead_z_offset = 10;
    tube_bulkhead_bottom_z = 74 + gantry_z_adjustment
                             - tube_bulkhead_mount_overlap
                             + tube_bulkhead_z_offset;
    tube_bulkhead_top_z = upper_frame_z - extrusion_profile / 2
                          + tube_bulkhead_z_offset;
    tube_bulkhead_height = tube_bulkhead_top_z - tube_bulkhead_bottom_z;
    tube_bulkhead_center_z =
        (tube_bulkhead_bottom_z + tube_bulkhead_top_z) / 2;
    beam_aperture_z = laser_offset + gantry_z_adjustment;
    beam_aperture_d = 18;
    // Unlike the horizontal tube floor, the vertical bulkhead needs no edge
    // clearance. Extend it to the left frame extrusion centerline to seal the
    // gap while retaining the established electronics-divider-side edge.
    tube_bulkhead_left_x = panel_left_x;
    tube_bulkhead_right_x = tube_floor_right_x;
    tube_bulkhead_width = tube_bulkhead_right_x - tube_bulkhead_left_x;
    tube_bulkhead_center_x =
        (tube_bulkhead_left_x + tube_bulkhead_right_x) / 2;
    tube_bulkhead_y = tube_bay_front_y - extrusion_profile / 2
                      - tube_panel_thickness / 2;

    if (show_tube_front_bulkhead) {
        color(bottom_color)
            difference() {
                translate([tube_bulkhead_center_x, tube_bulkhead_y,
                           tube_bulkhead_center_z])
                    cube([tube_bulkhead_width, tube_panel_thickness,
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
            difference() {
                translate([electronics_panel_center_x, panel_front_y,
                           panel_center_z])
                    cube([electronics_panel_width, outer_panel_thickness,
                          panel_height], center=true);
                if (show_electronics_operator_controls) {
                    translate([galvanometer_x, panel_front_y,
                               galvanometer_z])
                        cube([82, outer_panel_thickness + 4, 59],
                             center=true);
                    translate([estop_x, panel_front_y, operator_control_z])
                        rotate([90, 0, 0])
                            cylinder(d=32,
                                     h=outer_panel_thickness + 4,
                                     center=true, $fn=48);
                    translate([key_switch_x, panel_front_y,
                               operator_control_z])
                        rotate([90, 0, 0])
                            cylinder(d=20,
                                     h=outer_panel_thickness + 4,
                                     center=true, $fn=40);
                    translate([pendant_connector_x, panel_front_y,
                               pendant_connector_z])
                        rotate([90, 0, 0])
                            cylinder(d=26,
                                     h=outer_panel_thickness + 4,
                                     center=true, $fn=40);
                }
            }

    if (show_electronics_operator_controls) {
        operator_face_y = panel_front_y - outer_panel_thickness / 2;

        // Analog galvanometer-style laser tube current meter.
        color([0.055, 0.06, 0.065])
            translate([galvanometer_x, operator_face_y - 5,
                       galvanometer_z])
                cube([88, 10, 65], center=true);
        color([0.92, 0.92, 0.88])
            translate([galvanometer_x, operator_face_y - 11,
                       galvanometer_z])
                cube([78, 2, 55], center=true);
        color([0.08, 0.08, 0.08]) {
            translate([galvanometer_x, operator_face_y - 12,
                       galvanometer_z - 7])
                rotate([0, -25, 0]) cube([2, 1, 34], center=true);
            translate([galvanometer_x, operator_face_y - 13,
                       galvanometer_z - 21])
                rotate([90, 0, 0])
                    cylinder(d=6, h=2, center=true, $fn=28);
        }

        // Emergency stop with yellow legend plate and mushroom operator.
        color([0.95, 0.73, 0.05])
            translate([estop_x, operator_face_y - 2, operator_control_z])
                rotate([90, 0, 0])
                    cylinder(d=44, h=4, center=true, $fn=48);
        color([0.75, 0.02, 0.02]) {
            translate([estop_x, operator_face_y - 9, operator_control_z])
                rotate([90, 0, 0])
                    cylinder(d=29, h=15, center=true, $fn=48);
            translate([estop_x, operator_face_y - 20, operator_control_z])
                sphere(d=32, $fn=48);
        }

        // Keyed laser-enable switch.
        color([0.08, 0.085, 0.09])
            translate([key_switch_x, operator_face_y - 3,
                       operator_control_z])
                rotate([90, 0, 0])
                    cylinder(d=25, h=7, center=true, $fn=40);
        color([0.72, 0.73, 0.74]) {
            translate([key_switch_x, operator_face_y - 11,
                       operator_control_z])
                rotate([90, 0, 0])
                    cylinder(d=9, h=16, center=true, $fn=32);
            translate([key_switch_x, operator_face_y - 21,
                       operator_control_z])
                cube([4, 3, 18], center=true);
        }

        // Locking pendant receptacle and its five visible contact sockets.
        color([0.055, 0.06, 0.065])
            translate([pendant_connector_x, operator_face_y - 5,
                       pendant_connector_z])
                rotate([90, 0, 0])
                    cylinder(d=31, h=10, center=true, $fn=48);
        color([0.72, 0.73, 0.74])
            for (a = [0 : 72 : 359])
                translate([pendant_connector_x + 7 * cos(a),
                           operator_face_y - 11,
                           pendant_connector_z + 7 * sin(a)])
                    rotate([90, 0, 0])
                        cylinder(d=2.5, h=3, center=true, $fn=20);

        // Ruida-style controller display mounted through the fixed top deck.
        color([0.04, 0.045, 0.05])
            translate([ruida_panel_x, ruida_panel_y,
                       electronics_top_panel_z + 7])
                cube([118, 78, 12], center=true);
        color([0.08, 0.38, 0.58])
            translate([ruida_panel_x, ruida_panel_y,
                       electronics_top_panel_z + 14])
                cube([104, 64, 2], center=true);
    }

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
                if (show_exhaust_shroud)
                    translate([exhaust_shroud_x, panel_rear_y,
                               exhaust_shroud_z])
                        rotate([90, 0, 0])
                            cylinder(d=exhaust_shroud_diameter,
                                     h=outer_panel_thickness + 4,
                                     center=true, $fn=96);
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

    // Exterior flanged duct collar. The inside face lands on the rear skin;
    // the collar projects outward (+Y) for a standard 6-inch hose or duct.
    if (show_rear_panel && show_exhaust_shroud)
        color([0.16, 0.17, 0.18])
            translate([exhaust_shroud_x,
                       panel_rear_y + outer_panel_thickness / 2
                       + exhaust_shroud_depth / 2,
                       exhaust_shroud_z])
                rotate([90, 0, 0])
                    difference() {
                        cylinder(d=exhaust_shroud_diameter + 12,
                                 h=exhaust_shroud_depth,
                                 center=true, $fn=96);
                        cylinder(d=exhaust_shroud_diameter,
                                 h=exhaust_shroud_depth + 2,
                                 center=true, $fn=96);
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
    rear_y = rear_frame_y;
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
            if (show_all_panels && show_lid_panels)
                color(glass_color) {
                    translate([0, -lid_depth / 2, -10 + glass_thickness / 2])
                        cube([lid_width - 40, lid_depth, glass_thickness], center=true);

                    rotate([90, 0, 0])
                        translate([0, -lid_height + 30,
                                   lid_depth + 10 + glass_thickness / 2])
                            cube([lid_width - 40, lid_height,
                                  glass_thickness], center=true);
                }

            // Centered industrial U-pull on the exterior face of the lower
            // front 2020 member. Its screws engage T-nuts instead of loading
            // the acrylic, and it remains part of the moving lid assembly.
            if (show_lid_handle)
                translate([0,
                           -lid_depth - extrusion_profile / 2,
                           -20 - lid_height])
                    lid_pull_handle(width=lid_handle_width,
                                    projection=lid_handle_projection);
        }
}

module lid_pull_handle(width=180, projection=34, bar_d=14) {
    foot_d = 24;
    fastener_d = 7;

    // Black anodized handle: two mounting feet, two stand-offs, and grip.
    color([0.08, 0.085, 0.09]) {
        for (x = [-width / 2, width / 2]) {
            translate([x, -2, 0])
                rotate([90, 0, 0])
                    cylinder(d=foot_d, h=4, center=true, $fn=40);
            translate([x, -projection / 2, 0])
                rotate([90, 0, 0])
                    cylinder(d=bar_d, h=projection, center=true, $fn=40);
        }
        translate([0, -projection, 0])
            rotate([0, 90, 0])
                cylinder(d=bar_d, h=width, center=true, $fn=48);
    }

    // Visible stainless mounting screws in the center of each foot.
    color([0.68, 0.69, 0.70])
        for (x = [-width / 2, width / 2])
            translate([x, -4.2, 0])
                rotate([90, 0, 0])
                    cylinder(d=fastener_d, h=2.5, center=true, $fn=32);
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
