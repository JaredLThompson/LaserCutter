/*
 * laser_cutter.scad — complete concept assembly from owned hardware
 *
 * Motion concept:
 *   - 2x MGN12H 400 mm rails: paired Y guides
 *   - 1x MGN12H 800 mm rail: horizontal X guide on the gantry
 *   - 1x NEMA 17 + cross-shaft: mechanically synchronized dual Y belts
 *   - 1x NEMA 17: X belt
 *
 * Coordinates: X=machine width, Y=front-to-back, Z=up.
 */

include <laser_parts.scad>

$fn=36;


/* [Enclosure visibility] */
show_enclosure=false;         // master enclosure switch: panels + lid
show_panels=true;            // master skin switch for an unobstructed assembly view
show_side_panels=true;       // left and right outer skins
show_left_lower_access_panel=true;
show_left_upper_access_panel=true;
show_rear_panel=true;
show_front_panel=true;
show_electronics_bulkhead=true;
show_rear_tube_hatch=true;
show_control_panel=true;
show_lid_glazing=true;
show_lid_frame=true;
show_tube_cavity_cap=true;  // fixed/removable roof over full-width tube bay
gasket_color=[0.10,0.85,0.18]; // inspection green; use [0.035,0.038,0.04] for black
panel_clip_color=[1.00,0.42,0.05]; // inspection orange; independent of extrusion color
left_lower_panel_pull=0;     // [0:10:250] outward (-X) exploded-view distance
left_upper_panel_pull=0;     // [0:10:250] outward (-X) exploded-view distance
lid_gasket_diameter=6;        // silicone tubing pressed into the lid extrusion slot
lid_angle=45; //24;                // [0:5:75] 0=closed; positive raises front edge
rear_tube_hatch_angle=90;     // [0:5:80] 0=closed; opens outward/upward
electronics_service_panel_angle=100; // [0:5:100] right-side bay access

/* [Front fascia] */
front_fascia_start_z=205;    // seam between lower service panel and slope



// Owned-hardware configuration (millimetres).
tube_diameter=50;
tube_length=800;
y_rail_length=400;
x_rail_length=800;

/* [Motion position / collision review] */
x_axis_position=0;           // [-330:5:330]
y_axis_position=0;           // [-150:5:150]
animate_motion=true;        // use View > Animate; $t sweeps the work envelope
show_motion_clearance=false; // transparent head/motor keep-out volumes
x_carriage_position=animate_motion ? -330+660*$t : x_axis_position;
y_carriage_position=animate_motion
    ? -150+300*(0.5-0.5*cos(360*$t)) : y_axis_position;

// Concept frame and working envelope.
frame_width=1219.2;           // one full 48 in 2020 stick
frame_depth=650;
frame_height=360;
// Shared enclosure-face datums. A 20 mm front/rear rail is centered 10 mm
// inside the nominal envelope. The removable 3 mm front skin mounts outside
// the extrusion: its inner face touches the rail's outer face without sharing
// any volume with it.
front_outer_y=-frame_depth/2;
rear_outer_y=frame_depth/2;
front_rail_y=front_outer_y+10;
rear_rail_y=rear_outer_y-10;
rear_panel_t=3;
// External rear-skin plane. The rear 2020 occupies Y=305..325, so the
// sheets' inner faces touch Y=325 and all rigid material extends outward.
rear_skin_y=rear_outer_y+rear_panel_t/2;
front_skin_y=front_outer_y-1.5;
// Upper chassis rail center.  A 20 mm profile therefore ends at Z=340,
// exactly 20 mm below the nominal enclosure top and 10 mm below the closed
// lid-frame bottom plane.
upper_chassis_z=frame_height-30;
// A 6 mm adapter plate joins each Y carriage to the 2040 X gantry. gantry_z is
// the resulting top face of that 40 mm-tall extrusion.
gantry_adapter_thickness=6;
gantry_z=213;
// Offset leaves real clearance between the left enclosure skin and A1/tube
// hardware while retaining the isolated electronics bay on the right.
motion_center_x=-80;
// The divider moves with the cutting-system datum correction.  This leaves a
// compact but usable electronics bay while recovering real left-wall and lid
// clearances.  The cutting chamber remains fully sealed at this datum.
electronics_divider_x=405;
// Rear tube-service opening is bounded by the inside face of the left 2040
// upright and the tube-side face of the electronics-divider 2020.  The hatch,
// rear-panel cutout, gasket, hinges, and latches all derive from these datums.
rear_tube_hatch_left=-frame_width/2+30;
rear_tube_hatch_right=electronics_divider_x-10;
rear_tube_hatch_cx=(rear_tube_hatch_left+rear_tube_hatch_right)/2;
rear_tube_hatch_w=rear_tube_hatch_right-rear_tube_hatch_left;
// The 3 mm smoke-isolation sheet is face-mounted on the cutting-chamber
// side (-X) of the divider 2020. The extrusion occupies X=395..415 and the
// sheet occupies X=392..395: tangent to the frame, never inserted into its
// slot or profile.
electronics_bulkhead_t=3;
electronics_bulkhead_x=electronics_divider_x-10-electronics_bulkhead_t/2;
// Rear electronics-bay mains-entry location.
iec_inlet_x=(electronics_divider_x+10+(frame_width/2-22.5))/2;
iec_inlet_z=112;
// Horizontal center of the exposed upper electronics-bay front panel.
// Keep the galvanometer body and its sheet-metal opening on this datum.
galvanometer_x=(electronics_divider_x+10+(frame_width-45)/2)/2;
// Front electronics controls use a compact triangular layout rather than a
// crowded single row.  These shared datums drive both panel cutouts and parts.
estop_x=465;
keyswitch_x=525;
upper_control_z=135;
pendant_x=(estop_x+keyswitch_x)/2;
pendant_z=70;
y_rail_offset=400;
estimated_work_area=[660,300];
cutting_table_z=72;           // adjustable honeycomb work-surface datum

// Shared optical datum. All three mirror centers lie on this Z plane until
// A3 reflects the beam down the lens tube.
// Rearward placement keeps the fixed A1 body clear of the gantry at Y max.
tube_shelf_y=frame_depth/2-95;
tube_shelf_z=191;
tube_holder_height=110;
optical_axis_z=tube_shelf_z+tube_holder_height-(tube_diameter/2+22);
a3_entry_above_plate=28;     // lateral aperture center above A4 mounting plane
// The complete tube assembly is biased left.  This preserves the A1 alignment
// pocket while keeping the right holder/base clear of the electronics
// bulkhead and lid boundary.
tube_center_x=-95;
// Put the complete A1/A2 assembly against the left service wall, away from
// the tube and cutting motion.  The 55 mm allowance covers the rotated A2
// foot, adjusters and A1 head; 5 mm remains between that envelope and skin.
left_skin_inner_x=-frame_width/2+12;
left_optics_envelope=55;
left_optics_wall_clearance=5;
left_optics_x=left_skin_inner_x+left_optics_envelope
              +left_optics_wall_clearance;
// The tube compartment occupies the complete 48-inch machine width.  Its
// front wall separates it from both the cutting chamber and the front-right
// electronics bay; this replaces the former small cubical terminal tunnel.
tube_cavity_front_y=145;
tube_cavity_floor_z=184;
tube_cavity_top_z=340;


/* [Assembly visibility] */
show_exhaust_port=true;
exhaust_port_d=152;          // nominal 6 in duct, cutting chamber only
exhaust_port_z=100;          // below the rear tube-service hatch
show_belts=true;
show_drag_chains=true;
show_air_tube=true;
show_electronics=true;
show_beam_path=true;
show_leveling_feet=true;
show_tube_pocket_frame=true;
leveling_foot_adjustment=12; // [0:1:22.86] exposed 3/8-16 stud below socket

module extrusion_x(length,black=true)
    rotate([0,90,0]) aluminum_extrusion_2040(length=length,center=true,black=black);

module extrusion2020_x(length,black=true)
    rotate([0,90,0]) aluminum_extrusion_2020(length=length,center=true,black=black);

module extrusion2020_y(length,black=true)
    rotate([-90,0,0]) aluminum_extrusion_2020(length=length,center=true,black=black);

module extrusion2020_z(length,black=true)
    aluminum_extrusion_2020(length=length,center=false,black=black);

module extrusion_y(length,black=true)
    rotate([-90,0,0]) aluminum_extrusion_2040(length=length,center=true,black=black);

module extrusion_z(length,black=true)
    aluminum_extrusion_2040(length=length,center=false,black=black);

module belt_segment(a,b,width=6,thickness=1.4) {
    // Slightly lighter than the black anodized extrusion so belt routing is
    // readable in assembly previews while remaining visibly black.
    color([0.14,0.14,0.15])
        hull() {
            translate(a) cube([width,width,thickness],center=true);
            translate(b) cube([width,width,thickness],center=true);
        }
}

module pulley(axis="z",d=16,width=8) {
    color([0.10,0.10,0.11])
        if (axis=="x") rotate([0,90,0]) cylinder(d=d,h=width,center=true);
        else if (axis=="y") rotate([90,0,0]) cylinder(d=d,h=width,center=true);
        else cylinder(d=d,h=width,center=true);
}

module drag_chain_link(axis="x",pitch=18,width=24,height=14) {
    color([0.045,0.048,0.052])
        rotate([0,0,axis=="y" ? 90 : 0])
            difference() {
                cube([pitch-2,width,height],center=true);
                cube([pitch+1,width-9,height-7],center=true);
            }
}

module hose_segment(a,b,d=5) {
    color([0.08,0.32,0.88]) hull() {
        translate(a) sphere(d=d,$fn=16);
        translate(b) sphere(d=d,$fn=16);
    }
}

module z_cutting_table() {
    table_w=760;
    table_d=400;
    table_cx=motion_center_x;
    table_cy=-20;
    frame_z=cutting_table_z-10;
    screw_x=350;
    screw_y=180;

    // 2020 perimeter directly supports the removable honeycomb cassette.
    for (y=[table_cy-table_d/2+10,table_cy+table_d/2-10])
        translate([table_cx,y,frame_z]) extrusion2020_x(table_w);
    for (x=[table_cx-table_w/2+10,table_cx+table_w/2-10])
        translate([x,table_cy,frame_z]) extrusion2020_y(table_d-20);

    // Simplified honeycomb cassette and retaining rim.
    color([0.34,0.36,0.37])
        translate([table_cx,table_cy,cutting_table_z+1.5])
            cube([table_w-38,table_d-38,3],center=true);
    color([0.12,0.13,0.14])
        for (x=[table_cx-table_w/2+20:20:table_cx+table_w/2-20])
            translate([x,table_cy,cutting_table_z+3.3])
                cube([1,table_d-42,1],center=true);

    // Four lead screws rise from bearing blocks on the lower support rails.
    // Captive nut blocks bolt to the table perimeter, giving every corner a
    // continuous base -> screw -> nut -> table load path.
    for (x=[table_cx-screw_x,table_cx+screw_x],
         y=[table_cy-screw_y,table_cy+screw_y]) {
        color([0.48,0.49,0.50])
            translate([x,y,30]) cylinder(d=8,h=110);
        color([0.12,0.13,0.14])
            translate([x,y,35]) cube([28,28,10],center=true);
        color([0.58,0.59,0.60])
            translate([x,y,frame_z]) cube([30,30,14],center=true);
    }
}

module moving_services_drag_chains() {
    if (show_drag_chains) {
        pitch=18;
        head_x=motion_center_x+x_carriage_position;
        gantry_y=y_carriage_position;
        // The X carrier runs immediately along the front face of the gantry,
        // not suspended above the tube. Its lower run rests in a fixed tray.
        chain_y=gantry_y-22;

        // X carrier: fixed at the right gantry end and doubled back to A4.
        x_fixed=motion_center_x+x_rail_length/2+10;
        x_loop=(x_fixed+head_x)/2;
        x_lower_z=gantry_z+9;
        x_upper_z=x_lower_z+46;
        x_r=(x_upper_z-x_lower_z)/2;
        x_mid_z=(x_upper_z+x_lower_z)/2;

        for (x=[x_loop+pitch/2:pitch:x_fixed-pitch/2])
            translate([x,chain_y,x_lower_z]) drag_chain_link();
        for (x=[head_x+pitch/2:pitch:x_loop-pitch/2])
            translate([x,chain_y,x_upper_z]) drag_chain_link();
        for (a=[-90:22.5:90])
            translate([x_loop-x_r*cos(a),chain_y,x_mid_z+x_r*sin(a)])
                rotate([0,-a,0]) drag_chain_link();

        // Full-length 2 mm tray is attached to the gantry front T-slot. The
        // chain-link bottom lands exactly on its top surface.
        color([0.18,0.19,0.20])
            translate([motion_center_x,chain_y,gantry_z+1])
                cube([820,26,2],center=true);
        // Small angle tabs make the cantilevered tray-to-2040 connection
        // explicit at several points along the gantry.
        color([0.42,0.43,0.44])
            for (x=[motion_center_x-360:180:motion_center_x+360])
                translate([x,gantry_y-12,gantry_z-1])
                    cube([18,6,18],center=true);

        // Y carrier: fixed by the electronics bulkhead and doubled back to
        // the moving gantry. It carries X-motor wiring plus the air supply.
        y_fixed=-frame_depth/2+44;
        y_moving=chain_y;
        y_loop=(y_fixed+y_moving)/2;
        y_lower_z=240;
        y_upper_z=300;
        y_r=(y_upper_z-y_lower_z)/2;
        y_mid_z=(y_upper_z+y_lower_z)/2;
        chain_x=electronics_divider_x-18;

        for (yy=[y_fixed+pitch/2:pitch:y_loop-pitch/2])
            translate([chain_x,yy,y_lower_z]) drag_chain_link(axis="y");
        for (yy=[y_loop+pitch/2:pitch:y_moving-pitch/2])
            translate([chain_x,yy,y_upper_z]) drag_chain_link(axis="y");
        for (a=[-90:22.5:90])
            translate([chain_x,y_loop-y_r*cos(a),y_mid_z+y_r*sin(a)])
                rotate([a,0,0]) drag_chain_link(axis="y");

        // Fixed and moving-end brackets give both carriers a real attachment.
        color([0.12,0.13,0.14]) {
            translate([x_fixed,chain_y,x_lower_z]) cube([30,34,8],center=true);
            translate([head_x,chain_y,x_upper_z]) cube([30,34,8],center=true);
            translate([chain_x,y_fixed,y_lower_z]) cube([34,30,8],center=true);
            translate([chain_x,y_moving,y_upper_z]) cube([34,30,8],center=true);

            // Moving-end riser bolts to A4 and supports the elevated return
            // end; the lower fixed end is carried directly by the tray.
            a4_top_z=gantry_z+MGN12_ASSEMBLY_HEIGHT+6;
            translate([head_x,chain_y,(a4_top_z+x_upper_z-4)/2])
                cube([20,12,x_upper_z-4-a4_top_z],center=true);
        }

        if (show_air_tube) {
            // Blue air line follows both carriers and then drops to A3's
            // push-fit elbow. Curved sections are approximated segmentally.
            hose_segment([chain_x,y_fixed,y_lower_z],
                         [chain_x,y_loop,y_lower_z]);
            hose_segment([chain_x,y_loop,y_upper_z],
                         [chain_x,y_moving,y_upper_z]);
            for (a=[-90:22.5:67.5])
                hose_segment([chain_x,y_loop-y_r*cos(a),y_mid_z+y_r*sin(a)],
                             [chain_x,y_loop-y_r*cos(a+22.5),y_mid_z+y_r*sin(a+22.5)]);
            hose_segment([x_fixed,chain_y,x_lower_z],
                         [x_loop,chain_y,x_lower_z]);
            hose_segment([x_loop,chain_y,x_upper_z],
                         [head_x,chain_y,x_upper_z]);
            for (a=[-90:22.5:67.5])
                hose_segment([x_loop-x_r*cos(a),chain_y,x_mid_z+x_r*sin(a)],
                             [x_loop-x_r*cos(a+22.5),chain_y,x_mid_z+x_r*sin(a+22.5)]);
            hose_segment([chain_x,y_moving,y_upper_z],
                         [x_fixed,chain_y,x_lower_z]);
            hose_segment([head_x,chain_y,x_upper_z],
                         [head_x+27,gantry_y-72,130]);
        }
    }
}

module base_frame() {
    pocket_z=upper_chassis_z-20;
    outer_left=-frame_width/2+20;
    outer_right=frame_width/2-20;

    // 1200 x 650 mm lower rectangle. The 1200 mm members are 2020 because
    // available 2040 stock is limited to 1 m; all 2040 members stay <=900 mm.
    for (y=[front_rail_y,rear_rail_y])
        translate([0,y,20]) extrusion2020_x(frame_width);
    for (x=[-frame_width/2+20,frame_width/2-20])
        translate([x,0,20]) extrusion_y(frame_depth);

    // The real build uses 60 x 60 x 4 mm five-hole corner gussets beneath
    // the lower rail joints.  Three M5 positions fasten each plate to the
    // perpendicular extrusions; the diagonal pair at [10,30] and [30,10]
    // carries the purchased two-hole leveling-foot socket.
    if (show_leveling_feet)
        for (sx=[-1,1], sy=[-1,1]) {
            corner_x=sx < 0 ? outer_left : outer_right;
            corner_y=sy < 0 ? front_rail_y : rear_rail_y;
            // Mirror one inward-facing local assembly into every corner.
            translate([corner_x,corner_y,8])
                scale([-sx,-sy,1]) {
                    corner_gusset_2020_60();
                    translate([20,20,-2])
                        rotate([0,0,-45])
                            leveling_foot_3_8_16(
                                adjustment=leveling_foot_adjustment,
                                mount_hole_half_spacing=sqrt(200));
                }
        }
    // All four corner uprights reach the underside of the side/rear ledges.
    for (x=[outer_left,outer_right],
         y=[front_rail_y,rear_rail_y])
        translate([x,y,30])
            extrusion_z(upper_chassis_z-10-30);

    // Only the front cutting-chamber member is recessed. Its left end now
    // reaches the exterior face of the side ledge and bears directly on the
    // 2040 corner upright; there is no inward dogleg or floating transition.
    // The right end similarly bears on the electronics-divider post.
    pocket_front_left=outer_left-10;
    pocket_front_right=electronics_divider_x;
    pocket_front_length=pocket_front_right-pocket_front_left;
    pocket_front_cx=(pocket_front_left+pocket_front_right)/2;
    translate([pocket_front_cx,front_rail_y,pocket_z])
        extrusion2020_x(pocket_front_length);

    // Vertical M5 fasteners lock the recessed rail to the two supporting
    // upright tops. They replace the former side-mounted transition plates.
    color([0.72,0.73,0.74])
        for (x=[outer_left,electronics_divider_x], yoff=[-4,4])
            translate([x,front_rail_y+yoff,pocket_z+11])
                cylinder(d=8,h=2,center=true,$fn=32);

    // Full-height side and rear rails are the three physical lid ledges.
    translate([0,rear_rail_y,upper_chassis_z])
        extrusion2020_x(frame_width);
    translate([outer_left-10,0,upper_chassis_z])
        extrusion2020_y(frame_depth);
    translate([outer_right+10,0,upper_chassis_z])
        extrusion2020_y(frame_depth);

    // Full-depth divider creates a protected right-side electronics bay.
    // The Z=20 member is also the right-hand foundation for the tube support
    // grid; the two higher members carry the electronics floor/bulkhead.
    translate([electronics_divider_x,0,20]) extrusion_y(frame_depth-40);
    translate([electronics_divider_x,0,58]) extrusion_y(frame_depth-40);
    translate([electronics_divider_x,0,78]) extrusion_y(frame_depth-40);

    // Buildable electronics-bay frame: two divider posts rise from the lower
    // chassis and carry a full-depth 2020 top member.  Together with the
    // recessed outer perimeter this is a closed four-sided support frame for
    // the control deck and isolation sheet.
    for (y=[front_rail_y,rear_rail_y])
        translate([electronics_divider_x,y,30])
            extrusion2020_z(upper_chassis_z-40);
    translate([electronics_divider_x,0,upper_chassis_z])
        extrusion2020_y(frame_depth-20);

    // Close the top-front corner of the electronics bay with a real 2020
    // member.  It butts between the right face of the divider rail and the
    // left face of the outer-right side rail, rather than overlapping either
    // extrusion.  This member supports the front edge of the control deck.
    electronics_front_left=electronics_divider_x+10;
    electronics_front_right=outer_right;
    electronics_front_length=electronics_front_right-electronics_front_left;
    electronics_front_cx=(electronics_front_left+electronics_front_right)/2;
    translate([electronics_front_cx,front_rail_y,upper_chassis_z])
        extrusion2020_x(electronics_front_length);

    // Full-width structural frame at the front of the rear tube compartment.
    // The existing rear and side perimeter members complete the compartment;
    // this single bulkhead frame replaces the former little four-sided cube.
    if (show_tube_pocket_frame) {
        cavity_frame_w=frame_width-40;
        cavity_frame_h=tube_cavity_top_z-tube_cavity_floor_z;
        for (z=[tube_cavity_floor_z+10,tube_cavity_top_z-10])
            translate([0,tube_cavity_front_y,z])
                extrusion2020_x(cavity_frame_w);
        for (x=[-frame_width/2+20,frame_width/2-20])
            translate([x,tube_cavity_front_y,tube_cavity_floor_z+10])
                extrusion2020_z(cavity_frame_h-20);
    }

    color([0.18,0.20,0.21,0.55])
        translate([(electronics_divider_x+frame_width/2-20)/2,0,65])
            cube([frame_width/2-20-electronics_divider_x,frame_depth-80,3],center=true);

    // Lower tube-support grid. Two X-running 2020 members connect the left
    // perimeter rail to the electronics-divider foundation directly beneath
    // all four tube-shelf posts.
    // Cut to the inner faces of the 40 mm-wide perimeter/divider 2040s.
    tube_grid_left=-frame_width/2+40;
    tube_grid_right=electronics_divider_x-20;
    tube_grid_length=tube_grid_right-tube_grid_left;
    tube_grid_center=(tube_grid_left+tube_grid_right)/2;
    for (grid_y=[tube_shelf_y-28,tube_shelf_y+28])
        translate([tube_grid_center,grid_y,20])
            extrusion2020_x(tube_grid_length);

    // A short longitudinal bridge between those rails sits directly beneath
    // the outboard A1 pedestal.
    translate([left_optics_x,tube_shelf_y,20])
        extrusion2020_y(36);

    // Two more lower crossrails carry the four Z-table screw bearings.
    for (grid_y=[-200,160])
        translate([tube_grid_center,grid_y,20])
            extrusion2020_x(tube_grid_length);
}

module y_motion() {
    // Y carriage top is 154+13=167. A proper 6 mm mating plate raises the
    // 40 mm X gantry bottom to Z=173 and spreads its load across each block.
    rail_z=154;

    // Four short 2040 posts carry the Y support beams from the front/rear
    // frame rails.  Nothing in this motion stack is floating.
    for (x=[motion_center_x-y_rail_offset,motion_center_x+y_rail_offset],
         y=[front_rail_y,rear_rail_y])
        translate([x,y,30]) extrusion_z(rail_z-20-30);

    // Each Y rail is continuously supported by a 2040 beam. Its top is Z=154,
    // exactly matching the MGN12 rail mounting surface.
    for (x=[motion_center_x-y_rail_offset,motion_center_x+y_rail_offset])
        translate([x,0,rail_z-10]) extrusion_y(frame_depth-40);

    // Fixed rear crossmember prevents the two long Y support beams from
    // racking relative to one another.  Its 760 mm cut length fits exactly
    // between the inner faces of the two 40 mm-wide 2040 beams.  Keeping it
    // near the rear supports leaves the cutting table and front Y drive open.
    y_crossbrace_y=frame_depth/2-40;
    y_crossbrace_length=2*y_rail_offset-40;
    translate([motion_center_x,y_crossbrace_y,rail_z-10])
        extrusion2020_x(y_crossbrace_length);

    // Small inside angle plates and M5 heads show the buildable joints at
    // both ends of the brace instead of leaving an apparent butt joint.
    for (x=[motion_center_x-y_rail_offset+25,
            motion_center_x+y_rail_offset-25]) {
        color([0.38,0.39,0.40])
            translate([x,y_crossbrace_y,rail_z-1])
                cube([30,18,3],center=true);
        color([0.72,0.73,0.74])
            for (dx=[-9,9])
                translate([x+dx,y_crossbrace_y,rail_z+1])
                    cylinder(d=6,h=3,center=true);
    }

    // Rails run along Y; each receives one H carriage at the same Y position.
    for (x=[motion_center_x-y_rail_offset,motion_center_x+y_rail_offset])
        translate([x,0,rail_z]) rotate([0,0,90])
            mgn12_assembly(length=y_rail_length,carriage_type="H",
                           positions=[y_carriage_position]);

    // Two identical adapter plates bolt to the MGN12H 20 x 20 mm patterns;
    // their elongated M5 holes fasten into the underside slot of the 2040.
    for (x=[motion_center_x-y_rail_offset,motion_center_x+y_rail_offset])
        translate([x,y_carriage_position,
                   rail_z+MGN12_ASSEMBLY_HEIGHT])
            mgn12h_2040_gantry_plate(thickness=gantry_adapter_thickness);

    // The 820 mm X gantry rests on both carriage adapter plates. It only
    // overhangs the 800 mm rail enough to carry the end pulleys; shortening it
    // keeps the fixed A1 mirror completely outside the moving gantry sweep.
    // Its bottom is Z=173, exactly on the two mating-plate top faces.
    translate([motion_center_x,y_carriage_position,gantry_z-20])
        extrusion_x(820);

    // Single Y motor and front cross-shaft synchronize both side belts.
    shaft_z=180;
    y_drive_y=-frame_depth/2+44;
    right_y_axis_x=motion_center_x+y_rail_offset;
    left_y_axis_x=motion_center_x-y_rail_offset;
    y_belt_outboard=25;
    left_y_belt_x=left_y_axis_x-y_belt_outboard;
    right_y_belt_x=right_y_axis_x+y_belt_outboard;
    y_motor_z=135;
    y_motor_face_x=right_y_belt_x+5;

    // Motor is on the right-hand Y support, beside the electronics bulkhead.
    // Its body remains in the cutting chamber while its shaft points right,
    // leaving a short wiring route to a sealed bulkhead feedthrough.
    translate([y_motor_face_x-50,y_drive_y,y_motor_z])
        rotate([0,90,0]) nema17_stepper_17hs19(show_wires=false);
    color([0.55,0.56,0.57])
        translate([(left_y_belt_x+right_y_belt_x)/2,y_drive_y,shaft_z])
            rotate([0,90,0])
                cylinder(d=8,h=right_y_belt_x-left_y_belt_x,center=true);

    // Lower motor plate overlaps the right cross-shaft bearing plate, creating
    // one continuous vertical support without a cantilevered motor shelf.
    color([0.55,0.08,0.055]) {
        translate([y_motor_face_x-5,y_drive_y,y_motor_z])
            difference() {
                cube([10,52,58],center=true);
                rotate([0,90,0]) cylinder(d=23,h=12,center=true);
            }
        // Horizontal foot bridges the 25 mm outboard belt/motor plane back to
        // the supported right-hand 2040 beam.
        translate([(right_y_axis_x+right_y_belt_x)/2,y_drive_y,159])
            cube([y_belt_outboard+10,52,12],center=true);
    }

    // Offset bearing plates tie the cross-shaft to the two supported Y beams.
    // They sit on the inboard side of each belt plane; an axle/bearing spacer
    // reaches the pulley.  The former centered plates put solid aluminum
    // directly through both GT2 belt runs.
    for (side=[-1,1]) {
        axis_x=motion_center_x+side*y_rail_offset;
        plate_x=axis_x-side*10;
        color([0.55,0.08,0.055])
            translate([plate_x,y_drive_y,shaft_z])
                difference() {
                    cube([10,52,52],center=true);
                    rotate([0,90,0]) cylinder(d=12,h=12,center=true);
                }
        color([0.68,0.69,0.70])
            translate([(axis_x+plate_x)/2,y_drive_y,shaft_z])
                rotate([0,90,0]) cylinder(d=8,h=abs(axis_x-plate_x),center=true);
    }

    // Both reduction pulleys sit together beyond the right Y-belt plane:
    // 20T motor and 40T synchronized cross-shaft.
    reduction_pulley_x=right_y_belt_x+13;
    translate([reduction_pulley_x,y_drive_y,y_motor_z])
        pulley(axis="x",d=16,width=9);
    translate([reduction_pulley_x,y_drive_y,shaft_z])
        pulley(axis="x",d=28,width=9);
    if (show_belts) {
        belt_segment([reduction_pulley_x,y_drive_y-10,y_motor_z],
                     [reduction_pulley_x,y_drive_y-16,shaft_z]);
        belt_segment([reduction_pulley_x,y_drive_y+10,y_motor_z],
                     [reduction_pulley_x,y_drive_y+16,shaft_z]);
    }
    for (x=[left_y_belt_x,right_y_belt_x]) {
        translate([x,y_drive_y,shaft_z]) pulley(axis="x");
        translate([x, frame_depth/2-54,shaft_z]) pulley(axis="x");
        if (show_belts) {
            belt_segment([x,y_drive_y,shaft_z+8],[x,frame_depth/2-54,shaft_z+8]);
            belt_segment([x,y_drive_y,shaft_z-8],[x,frame_depth/2-54,shaft_z-8]);
        }
    }

    // Each moving end of the 2040 gantry carries a two-piece clamp on the
    // outboard upper belt run.  The vertical plate bolts to the gantry end;
    // the lower tongue and cap intentionally pinch the belt between them.
    for (side=[-1,1]) {
        gantry_end_x=motion_center_x+side*410;
        belt_x=motion_center_x+side*(y_rail_offset+y_belt_outboard);
        tongue_x=(gantry_end_x+belt_x)/2;
        tongue_w=abs(belt_x-gantry_end_x)+8;
        color([0.55,0.08,0.055]) {
            translate([gantry_end_x,y_carriage_position,gantry_z-20])
                cube([6,38,40],center=true);
            translate([tongue_x,y_carriage_position,shaft_z+5.3])
                cube([tongue_w,18,4],center=true);
        }
        color([0.06,0.065,0.07])
            translate([belt_x,y_carriage_position,shaft_z+10.7])
                cube([24,18,4],center=true);
        color([0.70,0.71,0.72])
            for (dy=[-5,5])
                translate([belt_x,y_carriage_position+dy,shaft_z+13])
                    cylinder(d=4,h=8,center=true);
    }
}

module x_motion_and_head() {
    y=y_carriage_position;
    // A4's belt fastener rotates onto global Y=gantry_y.  Keep the complete
    // pulley/belt plane on that datum so the fastener actually pinches the
    // upper run instead of hovering 10 mm in front of it.
    belt_y=y;
    left_pulley_x=motion_center_x-x_rail_length/2+5;
    // Drive pulley sits at the electronics-side end of the shortened gantry,
    // increasing head/motor clearance at maximum +X.
    right_pulley_x=motion_center_x+x_rail_length/2+10;
    a4_z=gantry_z+MGN12_ASSEMBLY_HEIGHT;
    // The assembled A4 clamp captures the belt 12.7 mm above the plate
    // datum.  A 16 mm pulley therefore centers 8 mm below that upper tangent.
    a4_belt_local_z=12.7;
    upper_run_z=a4_z+a4_belt_local_z;
    x_pulley_z=upper_run_z-8;
    head_origin_z=a4_z-(63.5+32);
    head_x=motion_center_x+x_carriage_position;
    // With A4 rotated +90 degrees, offsetting the slot-group centroid by
    // 38 mm puts its four adjustment slots over the MGN12H M3 pattern.
    // The head opening then hangs from the opposite (-Y) gantry face.
    a4_mount_y=y-38;
    head_y=y-72;

    // The single 800 mm rail lies horizontally on top of the gantry.
    translate([motion_center_x,y,gantry_z])
        mgn12_assembly(length=x_rail_length,carriage_type="H",
                       positions=[x_carriage_position]);

    // A4 is the carriage plate: it rests directly on the MGN12H top surface.
    // Its four elongated holes accept screws into the block's four M3 holes;
    // there is no intermediate shelf or head riser.
    translate([head_x,a4_mount_y,a4_z])
        rotate([0,0,90])
            startnow_connecting_plate(show_belt_fastener=true);

    // Four visible M3 cap screws pass through A4's slots into the MGN12H
    // carriage.  Their 20 x 20 mm centers are the actual mechanical joint.
    color([0.72,0.73,0.74])
        for (dx=[-10,10],dy=[-10,10]) {
            translate([head_x+dx,y+dy,a4_z+6.5])
                cylinder(d=6,h=3,center=true);
            translate([head_x+dx,y+dy,a4_z+8.1])
                cylinder(d=3,h=2,center=true,$fn=6);
        }

    // A3 hangs vertically through the large A4 opening. In its unrotated
    // orientation the lateral aperture faces -X, directly toward A2.
    translate([head_x,head_y,head_origin_z])
        startnow_laser_head(focal_length=63.5);

    // Passive left idler: a plate behind the belt plane bolts to the gantry,
    // with a real axle spacer reaching forward to the idler.  Keeping the
    // support behind Y+7 leaves both belt tangents completely unobstructed.
    idler_plate_y=y+10;
    color([0.55,0.08,0.055])
        translate([left_pulley_x,idler_plate_y,x_pulley_z])
            difference() {
                cube([28,6,56],center=true);
                rotate([90,0,0]) cylinder(d=8,h=8,center=true);
            }
    color([0.68,0.69,0.70])
        translate([left_pulley_x,(belt_y+idler_plate_y-3)/2,x_pulley_z])
            rotate([90,0,0])
                cylinder(d=6,h=idler_plate_y-3-belt_y,center=true);

    // Left idler and right drive pulley both rotate about Y.
    translate([left_pulley_x,belt_y,x_pulley_z]) pulley(axis="y");

    // Fabricable 6 mm side plate bolts into the 2040 side T-slot.  Its body is
    // offset inward so both M5/T-nut joints remain over the extrusion while
    // the NEMA shaft stays on the drive-pulley datum.
    translate([right_pulley_x,y+16,x_pulley_z])
        rotate([90,0,0])
            x_axis_nema17_2040_motor_mount(show_hardware=true);

    // X motor is outside the gantry/optical corridor.  Its front face lands
    // against the bracket at Y+16 and the 24 mm shaft reaches the belt plane.
    translate([right_pulley_x,y+66,x_pulley_z])
        rotate([90,0,0]) nema17_stepper_17hs19(show_wires=false);
    translate([right_pulley_x,belt_y,x_pulley_z])
        gt2_pulley_20t(axis="y");

    if (show_belts) {
        // One cut belt forms a closed path: end 1 at A4 clamp -> drive pulley
        // -> lower full-span run -> idler -> end 2 back at the A4 clamp.
        // Both cut ends meet inside the closed A4 clamp.  After A4's +90
        // degree rotation its local clamp Y=25 becomes global X=head_x-25.
        clamp_x=head_x-25;
        lower_run_z=x_pulley_z-8;
        belt_segment([clamp_x,belt_y,upper_run_z],
                     [left_pulley_x,belt_y,upper_run_z]);
        belt_segment([left_pulley_x,belt_y,lower_run_z],
                     [right_pulley_x,belt_y,lower_run_z]);
        belt_segment([right_pulley_x,belt_y,upper_run_z],
                     [clamp_x,belt_y,upper_run_z]);
    }
}

module motion_clearance_review() {
    if (show_motion_clearance) {
        // Conservative axis-aligned envelopes for the low portion of A3 and
        // the right-side Y motor/plate. A4 is above the motor and is excluded.
        head_x=motion_center_x+x_carriage_position;
        head_y=y_carriage_position-72;
        motor_x=motion_center_x+y_rail_offset-21;
        motor_y=-frame_depth/2+44;
        x_gap=abs(head_x-motor_x)-(30+25);
        y_gap=abs(head_y-motor_y)-(22+26);
        collision=x_gap<0 && y_gap<0;
        motor_clearance=max(x_gap,y_gap);
        left_x_pulley=motion_center_x-x_rail_length/2+5;
        right_x_pulley=motion_center_x+x_rail_length/2+10;
        left_end_clearance=abs(head_x-left_x_pulley)-(33+7);
        // Right end includes the 56 mm-wide motor plate, not merely a pulley.
        right_end_clearance=abs(head_x-right_x_pulley)-(33+28);
        end_clearance=min(left_end_clearance,right_end_clearance);
        conservative_clearance=min(motor_clearance,end_clearance);
        any_collision=collision || end_clearance<0;

        echo(str("Motion clearance: ",conservative_clearance,
                 " mm; motor=",motor_clearance,
                 " mm; X-end hardware=",end_clearance,
                 " mm; collision=",any_collision,
                 "; X=",x_carriage_position,
                 "; Y=",y_carriage_position));

        color([1.0,0.48,0.05,0.28])
            translate([motor_x,motor_y,135]) cube([50,52,58],center=true);
        color(any_collision ? [1.0,0.0,0.0,0.48] : [0.05,0.85,0.18,0.25])
            translate([head_x,head_y,157]) cube([60,44,126],center=true);
    }
}

module tube_and_optics() {
    shelf_y=tube_shelf_y;
    shelf_z=tube_shelf_z;
    holder_spacing=620;
    holder_height=tube_holder_height;
    tube_z=optical_axis_z;

    // The shelf follows the tube as one supported assembly.  Its extra 50 mm
    // on the output side leaves room for A1 alignment and service access.
    tube_shelf_length=780;
    tube_shelf_center_x=tube_center_x-50;
    tube_rail_y_offset=28;
    // Two parallel 2020 rails support the front and rear edges of both tube
    // holder bases. Their top faces are exactly the holder mounting plane.
    for (rail_y=[shelf_y-tube_rail_y_offset,
                 shelf_y+tube_rail_y_offset])
        translate([tube_shelf_center_x,rail_y,shelf_z-10])
            extrusion2020_x(tube_shelf_length);

    // Each rail has two independent vertical supports. All four remain on the
    // cutting-chamber side of the electronics bulkhead.
    for (x=[tube_center_x-310,tube_center_x+310],
         rail_y=[shelf_y-tube_rail_y_offset,
                 shelf_y+tube_rail_y_offset])
        translate([x,rail_y,30]) extrusion2020_z(shelf_z-50);
    for (x=[-holder_spacing/2,holder_spacing/2])
        translate([tube_center_x+x,shelf_y,shelf_z]) rotate([0,0,90])
            laser_tube_holder(tube_diameter=tube_diameter,height=holder_height);

    // Tube module has a Y axis, hence rotate it onto global X.
    translate([tube_center_x,shelf_y,tube_z]) rotate([0,0,90])
        co2_laser_tube_50w(diameter=tube_diameter,length=tube_length);

    // A1 at the tube output and A2 carried close to the left service wall.
    // Both mirror centers share the wall-clearance-derived X datum above;
    // moving this datum carries the pedestals, bridge and beam path together.
    tube_output_x=tube_center_x-tube_length/2;
    tube_terminal_x=tube_center_x+tube_length/2;
    // The lid's electronics-side 2020 rail ends 2 mm before the divider
    // post's left face.  Its inner edge is another 20 mm toward the tube.
    lid_edge_rail_inner_x=electronics_divider_x-10-2-20;
    a1_x=left_optics_x;
    left_y_rail_x=motion_center_x-y_rail_offset;
    gantry_left_x=motion_center_x-820/2;
    a1_mount_height=205;
    // The modeled A1 bore center is height-32 above its mounting base.
    a1_mirror_center_above_base=a1_mount_height-32;
    a1_base_z=tube_z-a1_mirror_center_above_base;
    // A1 pedestal is supported from the left base rail rather than floating.
    translate([a1_x,shelf_y,30]) extrusion_z(a1_base_z-30);
    // The base stays square to the chassis. The telescoping round post allows
    // only the upper head to yaw 225 degrees, preserving the required mirror
    // plane while pointing its adjusters toward the rear service hatch.
    translate([a1_x,shelf_y,a1_base_z])
        startnow_first_mirror_mount(height=a1_mount_height,head_yaw=225);

    // A1 and A2 share X exactly, making this beam leg a true 90-degree turn.
    a2_x=a1_x;
    // A2 and the A3 side aperture share the front (-Y) optical plane.
    a2_y=y_carriage_position-72;
    a2_base_z=tube_z-51;
    // A2's own 70 x 66 slotted installation plate sits on this rigid offset
    // bridge.  The bridge is bolted to the front face/end of the 2040 gantry
    // and carries the mirror center outboard of the left Y rail.  This is the
    // lateral adjustment the real A2 foot is intended to provide.
    bridge_right_x=gantry_left_x+32;
    bridge_left_x=a2_x-40;
    bridge_center_x=(bridge_left_x+bridge_right_x)/2;
    bridge_width=bridge_right_x-bridge_left_x;
    color([0.55,0.08,0.055]) {
        translate([bridge_center_x,(a2_y+y_carriage_position-20)/2,
                   a2_base_z-5])
            cube([bridge_width,y_carriage_position-20-a2_y,10],center=true);
        // Downturned flange makes the shelf a buildable angle bracket rather
        // than a floating plate.
        translate([gantry_left_x+16,y_carriage_position-20,a2_base_z+5])
            cube([32,8,30],center=true);
    }
    // A2 receives the Y-axis leg and turns it 90 degrees along the moving
    // X gantry. Its face is again 45 degrees to both beam segments.
    // 315 degrees has the same 45-degree optical plane as 135 degrees, but
    // reverses the physical mount so its adjustment screws sit outside the
    // incoming/outgoing beam corner.
    translate([a2_x,a2_y,a2_base_z])
        rotate([0,0,315]) startnow_second_mirror_mount();

    echo(str("Left optics: A1/A2 X=",a1_x,
             "; left Y rail X=",left_y_rail_x,
             "; gantry left end X=",gantry_left_x,
             "; optical-to-rail clearance=",left_y_rail_x-a1_x,
             " mm; optical-to-gantry-end clearance=",gantry_left_x-a1_x,
             " mm; estimated A1-to-gantry swept Y clearance=",
             shelf_y-(150+20+49)," mm"));
    echo(str("Tube/lid clearance: tube terminal X=",tube_terminal_x,
             "; lid edge rail begins X=",lid_edge_rail_inner_x,
             "; clearance=",lid_edge_rail_inner_x-tube_terminal_x," mm"));
    echo(str("Tube-output/A1 alignment gap: ",tube_output_x-a1_x," mm"));
    echo(str("Left optics/skin clearance (conservative): optics envelope X=",
             a1_x-left_optics_envelope,
             "; skin inner face X=",left_skin_inner_x,
             "; clearance=",a1_x-left_optics_envelope-left_skin_inner_x,
             " mm"));

    if (show_beam_path)
        color([1.0,0.05,0.02,0.65]) {
            // Optical path: tube --X--> A1 --Y--> A2 --X--> A3 --Z--> bed.
            hull() {
                translate([tube_output_x,shelf_y,tube_z]) sphere(d=1.2);
                translate([a1_x,shelf_y,tube_z]) sphere(d=1.2);
            }
            hull() {
                translate([a1_x,shelf_y,tube_z]) sphere(d=1.2);
                translate([a2_x,a2_y,tube_z]) sphere(d=1.2);
            }
            // The X-axis leg enters A3 through its lateral -X aperture.
            hull() {
                translate([a2_x,a2_y,tube_z]) sphere(d=1.2);
                translate([motion_center_x+x_carriage_position,y_carriage_position-72,tube_z]) sphere(d=1.2);
            }
            // A3's internal 45-degree mirror turns the beam vertically down
            // through the lens/nozzle; the head barrel remains parallel to Z.
            hull() {
                translate([motion_center_x+x_carriage_position,
                           y_carriage_position-72,tube_z]) sphere(d=1.2);
                translate([motion_center_x+x_carriage_position,
                           y_carriage_position-72,105]) sphere(d=1.2);
            }
        }
}

module electronics_bay() {
    if (show_electronics) {
        // The bay has about 155 mm of clear X width between the divider and
        // right perimeter extrusion.  Keep the PSU's 139.7 mm dimension on X;
        // the former 90-degree rotation put its 177.8 mm dimension through
        // both the divider and the tube-pocket uprights.
        //
        // Its rear edge stops ahead of the tube-pocket frame at Y=145, while
        // its terminal face points toward the open front service area.
        translate([500,20,67])
            vevor_laser_power_supply_50w(show_cable=false);

        // Two TS35 rails use the smoke-isolation divider as a vertical DIN
        // backboard. Heavy equipment remains frame-supported; controls and
        // terminals no longer consume the floor.
        // Rail backs bear on the electronics-side surface of the isolation
        // sheet.  The hat section projects into the service bay (+X), not
        // through the sheet or divider extrusion.
        din_x=electronics_bulkhead_x+electronics_bulkhead_t/2;
        din_y=-85;
        din_len=400;
        for (z=[145,255])
            translate([din_x,din_y,z]) rotate([0,90,-90])
                din_rail_ts35(length=din_len);

        // Purchased drivers bolt to printable DIN carrier plates. Their
        // terminals face the service door and remain individually removable.
        for (y=[-205,-125]) {
            translate([din_x+8,y,196]) rotate([0,0,90])
                din_driver_adapter(width=64,height=106);
            translate([din_x+13,y,196]) rotate([0,90,0]) rotate([0,0,90])
                microstep_driver_4a();
        }

        // Low-side, flyback-protected MOSFET output for the ordered 24 VDC
        // air valve, plus adjacent field-wiring terminals.
        translate([din_x+17,-20,255]) rotate([0,0,90])
            din_mosfet_output_24v();
        translate([din_x+17,55,255]) rotate([0,0,90])
            din_terminal_block_bank(count=8);

        echo(str("Electronics clearances: PSU/bulkhead=",
                 500-139.7/2-(electronics_bulkhead_x+electronics_bulkhead_t/2),
                 " mm; PSU/right rail=9.75 mm; PSU/rear tube bulkhead >30 mm"));
    }
}

module enclosure_side_panels() {
    panel=[0.74,0.76,0.75,0.72];
    // Opaque lower side and rear panels fitted inside the extrusion frame.
    if (show_panels && show_side_panels) {
        // The former one-piece left skin is now two external lift-off access
        // panels.  Their inner faces touch the outside faces of the 2020s;
        // unlike the earlier datum, neither sheet intersects the aluminum.
        // There is no fixed horizontal mullion, so removing both sheets
        // exposes the complete side opening for oversized workpieces.
        left_panel_thickness=3;
        // The left perimeter members are 2040s with their 40 mm dimension
        // across X.  Their centers are at -frame_width/2+20, so the true
        // outside face is -frame_width/2 (not center-10 as for a 2020).
        // Put the sheet's inner face exactly on that plane: external contact,
        // zero aluminum/panel overlap.
        left_frame_outer_x=-frame_width/2;
        left_panel_x=left_frame_outer_x-left_panel_thickness/2;
        left_panel_y_span=frame_depth;
        left_panel_bottom=22.5;
        left_panel_split=180;
        left_panel_top=frame_height-22.5;
        panel_seam=4;
        lower_panel_top=left_panel_split-panel_seam/2;
        upper_panel_bottom=left_panel_split+panel_seam/2;
        lower_panel_h=lower_panel_top-left_panel_bottom;
        upper_panel_h=left_panel_top-upper_panel_bottom;

        if (show_left_lower_access_panel)
            left_access_panel(left_panel_x-left_lower_panel_pull,0,
                              (left_panel_bottom+lower_panel_top)/2,
                              left_panel_y_span,lower_panel_h,
                              handle_z=112);
        if (show_left_upper_access_panel)
            left_access_panel(left_panel_x-left_upper_panel_pull,0,
                              (upper_panel_bottom+left_panel_top)/2,
                              left_panel_y_span,upper_panel_h,
                              handle_z=258);

        // Compressible gasket remains on the fixed front/rear/bottom
        // perimeter.  The center seal and its backing leave with the lower
        // panel, so no structural bar remains across the access opening.
        color(gasket_color) {
            for (y=[front_rail_y,rear_rail_y])
                translate([left_frame_outer_x-0.5,y,frame_height/2])
                    cube([1,8,frame_height-45],center=true);
            // Bottom seal only.  The former top run was both unnecessary
            // and visually confused with the lid's left-side tubing seal.
            translate([left_frame_outer_x-0.5,0,left_panel_bottom])
                cube([1,left_panel_y_span-20,8],center=true);
        }

        if (show_left_lower_access_panel) {
            // A thin aluminum backing/overlap strip is riveted to the lower
            // sheet and projects behind the upper sheet. It blocks smoke and
            // light across the 4 mm reveal without becoming a frame member.
            backing_x=left_frame_outer_x+1.5-left_lower_panel_pull;
            color([0.38,0.40,0.41])
                translate([backing_x,0,left_panel_split])
                    cube([2,left_panel_y_span-42,32],center=true);
            // Foam tape on the upper half of the removable backing strip.
            color(gasket_color)
                translate([left_frame_outer_x-0.25-left_lower_panel_pull,
                           0,left_panel_split+9])
                    cube([0.5,left_panel_y_span-42,14],center=true);
            // Rivets retain the backing to the lower panel only.
            color([0.70,0.71,0.72])
                for (y=[-240,-120,0,120,240])
                    translate([left_panel_x-2-left_lower_panel_pull,
                               y,left_panel_split-9])
                        rotate([0,90,0]) cylinder(d=5,h=2,$fn=24);
        }

        // Right wall frame with a large electronics service opening.
        color(panel)
            difference() {
                translate([frame_width/2-10,0,frame_height/2])
                    cube([3,frame_depth-45,frame_height-45],center=true);
                translate([frame_width/2-10,0,170])
                    cube([8,520,250],center=true);
            }
    }
    color(panel) if (show_panels && show_rear_panel) {
        difference() {
            translate([0,rear_skin_y,frame_height/2])
                cube([frame_width-45,rear_panel_t,frame_height-45],center=true);
            if (show_exhaust_port)
                translate([motion_center_x,rear_skin_y,exhaust_port_z])
                    rotate([90,0,0]) cylinder(d=exhaust_port_d,h=8,center=true);
            if (show_rear_tube_hatch)
                translate([rear_tube_hatch_cx,rear_skin_y,
                           optical_axis_z])
                    cube([rear_tube_hatch_w,8,120],center=true);
            // IEC C14 fused/switched inlet: 48 x 31 mm body opening and two
            // 3.6 mm flange screws on the advertised 1.57 in spacing.
            translate([iec_inlet_x,rear_skin_y,iec_inlet_z])
                rotate([90,0,0]) {
                    cube([48,31,rear_panel_t+4],center=true);
                    for (x=[-19.94,19.94])
                        translate([x,0,0])
                            cylinder(d=3.6,h=rear_panel_t+4,
                                     center=true,$fn=24);
                }
        }
    }
    if (show_panels && show_front_panel) {
        front_panel_t=3;
        front_y=front_skin_y;
        panel_w=frame_width-45;
        panel_left=-panel_w/2;
        panel_right=panel_w/2;
        divider_left=electronics_divider_x-10;
        divider_right=electronics_divider_x+10;
        cutting_panel_w=divider_left-panel_left;
        cutting_panel_x=(panel_left+divider_left)/2;
        electronics_panel_w=panel_right-divider_right;
        electronics_panel_x=(divider_right+panel_right)/2;

        // Extend the lower skins across the bottom 2020 centerline so their
        // first M5 row can engage real roll-in T-nuts in that extrusion.
        lower_bottom_z=10;
        lower_h=front_fascia_start_z-lower_bottom_z;
        upper_h=frame_height-20-front_fascia_start_z;
        cutting_fastener_x=[panel_left+30,cutting_panel_x,divider_left-30];
        electronics_fastener_x=[divider_right+30,panel_right-30];

            // Squared two-piece front: removable lower service panel and a
            // coplanar upper infill panel, both fixed to the straight frame.
            color([0.20,0.22,0.23]) {
                difference() {
                    translate([cutting_panel_x,front_y,
                               lower_bottom_z+lower_h/2])
                        cube([cutting_panel_w,front_panel_t,lower_h],center=true);
                    for (x=cutting_fastener_x,
                         z=[20,front_fascia_start_z])
                        translate([x,front_y,z]) rotate([90,0,0])
                            cylinder(d=5.6,h=front_panel_t+4,
                                     center=true,$fn=28);
                }
                difference() {
                    translate([electronics_panel_x,front_y,
                               lower_bottom_z+lower_h/2])
                        cube([electronics_panel_w,front_panel_t,lower_h],center=true);
                    translate([estop_x,front_y,upper_control_z])
                        rotate([90,0,0])
                        cylinder(d=32,h=8,center=true);
                    translate([pendant_x,front_y,pendant_z])
                        rotate([90,0,0])
                        cylinder(d=26,h=8,center=true);
                    translate([keyswitch_x,front_y,upper_control_z])
                        rotate([90,0,0])
                        cylinder(d=20,h=8,center=true);
                    for (x=electronics_fastener_x,
                         z=[20,front_fascia_start_z])
                        translate([x,front_y,z]) rotate([90,0,0])
                            cylinder(d=5.6,h=front_panel_t+4,
                                     center=true,$fn=28);
                }
            }
            // Upper infill includes real cutouts for the electronics-bay
            // operator controls on the vertical front face.
            color([0.30,0.32,0.33])
                difference() {
                    union() {
                        translate([cutting_panel_x,front_y,
                                   front_fascia_start_z+(upper_h-20)/2])
                            cube([cutting_panel_w,front_panel_t,
                                  upper_h-20],center=true);
                        translate([electronics_panel_x,front_y,
                                   front_fascia_start_z+upper_h/2])
                            cube([electronics_panel_w,front_panel_t,
                                  upper_h],center=true);
                    }
                    // Galvanometer rectangular body opening.
                    translate([galvanometer_x,front_y,270])
                        cube([82,8,59],center=true);
                    for (x=cutting_fastener_x,
                         z=[front_fascia_start_z,upper_chassis_z-20])
                        translate([x,front_y,z]) rotate([90,0,0])
                            cylinder(d=5.6,h=front_panel_t+4,
                                     center=true,$fn=28);
                    for (x=electronics_fastener_x,
                         z=[front_fascia_start_z,upper_chassis_z])
                        translate([x,front_y,z]) rotate([90,0,0])
                            cylinder(d=5.6,h=front_panel_t+4,
                                     center=true,$fn=28);
                }
            color([0.08,0.085,0.09])
                translate([0,front_rail_y,front_fascia_start_z])
                    extrusion2020_x(panel_w);
            // External printable clips and M5 hardware.  Their T-nuts sit in
            // the front-facing slots of the real horizontal 2020 members;
            // the orange preview color makes the complete load path visible.
            for (x=cutting_fastener_x,
                 z=[20,front_fascia_start_z,upper_chassis_z-20])
                translate([x,front_y-front_panel_t/2,z])
                    rotate([90,0,0])
                        external_2020_panel_clip(
                            panel_thickness=front_panel_t,
                            show_hardware=true,
                            body_color=panel_clip_color);
            for (x=electronics_fastener_x,
                 z=[20,front_fascia_start_z,upper_chassis_z])
                translate([x,front_y-front_panel_t/2,z])
                    rotate([90,0,0])
                        external_2020_panel_clip(
                            panel_thickness=front_panel_t,
                            show_hardware=true,
                            body_color=panel_clip_color);
    }
}

// Lift-off left-side enclosure panel. Coordinate inputs are global; the
// sheet normal is X. Four printable bridge clips and M5 screws engage roll-in
// T-nuts in the front/rear upright slots. A U-handle leaves with the panel.
module left_access_panel(x,y,z,width,height,handle_z) {
    panel_t=3;
    yfast=[front_rail_y,rear_rail_y];
    zfast=[z-height/2+22,z+height/2-22];
    color([0.56,0.58,0.59,0.82])
        difference() {
            translate([x,y,z]) cube([panel_t,width,height],center=true);
            for (yf=yfast,zf=zfast)
                translate([x,yf,zf]) rotate([0,90,0])
                    cylinder(d=5.6,h=panel_t+4,center=true,$fn=28);
        }

    // Printed clips sit outside the sheet. Their screws pass through the
    // real panel holes and terminate in T-nuts captured by the 2020 slots.
    for (yf=yfast,zf=zfast)
        translate([x-panel_t/2,yf,zf]) rotate([0,-90,0])
            external_2020_panel_clip(panel_thickness=panel_t,
                                     show_hardware=true,
                                     body_color=panel_clip_color);

    // Horizontal pull handle; both feet and grip leave with the panel.
    color([0.10,0.105,0.11]) {
        for (yfoot=[y-45,y+45])
            translate([x-9,yfoot,handle_z])
                rotate([0,90,0]) cylinder(d=12,h=15,center=true,$fn=32);
        translate([x-17,y,handle_z])
            rotate([90,0,0]) cylinder(d=12,h=90,center=true,$fn=32);
    }
}

module electronics_service_panel(angle=electronics_service_panel_angle) {
    if (show_panels && show_side_panels) {
        door_t=4;
        right_frame_outer_x=frame_width/2;
        // External Voron-style panel mount: in the closed position the
        // sheet's inner face is tangent to the outer face of the right-side
        // 2020, never embedded in its profile.
        door_x=right_frame_outer_x+door_t/2;
        hinge_y=270;
        door_y=536;
        door_z=266;

        // Rear vertical hinge; positive angle swings the door outward (+X).
        translate([door_x,hinge_y,170]) rotate([0,0,angle]) {
            color([0.56,0.58,0.59])
                translate([0,-door_y/2,0])
                    cube([door_t,door_y,door_z],center=true);
            // Two printable cam latches pull the door against its perimeter
            // gasket. M5 mounting screws and M4 pivots remain metal hardware.
            for (z=[115,225])
                translate([7,-door_y+25,z-170]) rotate([0,90,0])
                    enclosure_cam_latch_assembly();
        }

        for (z=[105,170,235])
            translate([door_x,hinge_y,z]) rotate([0,90,0])
                enclosure_hinge_assembly(width=38,leaf_depth=20);
    }
}

module isolated_electronics_bulkhead() {
    if (show_panels && show_electronics_bulkhead) {
        // The electronics divider ends at the full-width tube-compartment
        // wall. Electronics occupy only the front-right portion of the box.
        // Exact clear-opening limits: rear face of the front 2020 through to
        // the front face of the perpendicular tube-cavity skin.  The edges
        // meet those parts without either overlap or a smoke-leak gap.
        divider_front=front_outer_y+20;
        divider_rear=tube_cavity_front_y;
        divider_bottom_z=30;
        // Fit the sheet to the clear opening below the Z=330 rail. Ending at
        // its underside (Z=320), rather than its upper face, prevents the
        // sheet edge from appearing through the extrusion slot.
        divider_top_z=upper_chassis_z-10;
        divider_height=divider_top_z-divider_bottom_z;
        divider_center_z=(divider_bottom_z+divider_top_z)/2;
        color([0.66,0.68,0.68])
            translate([electronics_bulkhead_x,
                       (divider_front+divider_rear)/2,divider_center_z])
                cube([electronics_bulkhead_t,
                      divider_rear-divider_front,divider_height],center=true);

        // Full-width removable front skin and floor of the rear tube cavity.
        // A small aperture at A1 passes only the reflected beam into the
        // cutting chamber; the rest remains smoke-tight.
        color([0.66,0.68,0.68]) {
            difference() {
                translate([0,tube_cavity_front_y+1.5,
                           (tube_cavity_floor_z+tube_cavity_top_z)/2])
                    cube([frame_width-42,3,
                          tube_cavity_top_z-tube_cavity_floor_z],center=true);
                translate([left_optics_x,tube_cavity_front_y+1.5,optical_axis_z])
                    rotate([90,0,0]) cylinder(d=18,h=8,center=true,$fn=36);
            }
            translate([0,(tube_cavity_front_y+rear_outer_y-21)/2,
                       tube_cavity_floor_z-1.5])
                cube([frame_width-42,rear_outer_y-21-tube_cavity_front_y,
                      3],center=true);
        }

        // Represent sealed cable glands/feedthroughs rather than open holes.
        color([0.07,0.075,0.08])
            for (y=[-120,-80,-40])
                translate([electronics_bulkhead_x,y,105]) rotate([0,90,0])
                    cylinder(d=14,h=12,center=true);
        // Dedicated nearby gland for the right-side Y motor cable.
        color([0.07,0.075,0.08])
            translate([electronics_bulkhead_x,-frame_depth/2+44,135])
                rotate([0,90,0]) cylinder(d=14,h=12,center=true);
    }
}

module cutting_chamber_exhaust() {
    if (show_panels && show_rear_panel && show_exhaust_port) {
        // Rear flange only; the blower belongs downstream/outside the machine.
        color([0.16,0.17,0.18])
            translate([motion_center_x,rear_skin_y,exhaust_port_z])
                rotate([90,0,0])
                    difference() {
                        cylinder(d=exhaust_port_d+12,h=18,center=true);
                        cylinder(d=exhaust_port_d,h=20,center=true);
                    }
    }
}

module rear_mains_inlet() {
    if (show_panels && show_rear_panel)
        // Mounting face is flush with the outside of the rear skin; the
        // molded body and spade terminals project inward into the isolated
        // electronics bay.
        translate([iec_inlet_x,rear_outer_y+rear_panel_t,iec_inlet_z])
            rotate([90,0,0]) iec_c14_fused_inlet();
}

module rear_tube_service_hatch(angle=rear_tube_hatch_angle) {
    if (show_panels && show_rear_panel && show_rear_tube_hatch) {
        // Bound the service hatch by real structure.  Its left edge meets the
        // inside face of the rear-left perimeter upright and its right edge
        // stops at the tube-side face of the electronics-divider upright.
        // The hatch therefore cannot hide behind or swing through either
        // extrusion.
        hatch_left=rear_tube_hatch_left;
        hatch_right=rear_tube_hatch_right;
        hatch_cx=rear_tube_hatch_cx;
        hatch_w=rear_tube_hatch_w;
        hatch_h=136;
        rear_y=rear_skin_y;
        hinge_z=optical_axis_z+68;
        gasket_inset=4;
        hardware_inset=120;

        // Fixed closed-cell gasket follows the shortened framed opening.
        color(gasket_color) {
            for (z=[optical_axis_z-64,optical_axis_z+64])
                translate([hatch_cx,rear_y-2,z])
                    cube([hatch_w-2*gasket_inset,5,8],center=true);
            for (x=[hatch_left+gasket_inset,hatch_right-gasket_inset])
                translate([x,rear_y-2,optical_axis_z])
                    cube([8,5,128],center=true);
        }

        // The sheet and its two compression-latch tabs rotate together about
        // the top hinge axis. Positive angle opens outward (+Y) and upward.
        translate([hatch_cx,rear_y,hinge_z])
            rotate([angle,0,0]) {
                color([0.52,0.54,0.55])
                    translate([0,0,-hatch_h/2])
                        cube([hatch_w,4,hatch_h],center=true);
                color([0.07,0.075,0.08])
                    for (x=[-hatch_w/2+hardware_inset,
                             hatch_w/2-hardware_inset])
                        translate([x,4,-hatch_h+15])
                            cube([30,10,24],center=true);
            }

        // Three fixed hinges distribute the load across the long access door.
        for (x=[hatch_left+hardware_inset,hatch_cx,
                hatch_right-hardware_inset])
            translate([x,rear_y,hinge_z])
                enclosure_hinge_assembly(width=46,leaf_depth=20);
    }
}

module electronics_control_deck() {
    if (show_panels && show_control_panel) {
        deck_left=electronics_divider_x+5;
        deck_right=frame_width/2-20;
        deck_w=deck_right-deck_left;
        deck_x=(deck_left+deck_right)/2;
        // Four-millimetre deck sheet sits directly on the Z=340 top faces of
        // the recessed electronics-bay 2020 frame.
        deck_z=upper_chassis_z+12;
        // Cover the newly framed front edge.  The first fastener row lands
        // over the centerline of the top-front 2020 instead of floating
        // behind it.
        deck_front=front_outer_y;
        deck_rear=tube_cavity_front_y-10;
        deck_d=deck_rear-deck_front;
        deck_y=(deck_front+deck_rear)/2;
        lcd_x=deck_x;
        lcd_y=deck_front+58;

        // Fixed electronics-bay roof/control deck; service is through the
        // separate right-side door, not through the cutting-chamber lid.
        color([0.30,0.32,0.33])
            difference() {
                translate([deck_x,deck_y,deck_z])
                    cube([deck_w,deck_d,4],center=true);
                translate([lcd_x,lcd_y,deck_z])
                    cube([106,66,10],center=true);
            }

        // Vertical front operator panel, left-to-right: tube-current meter,
        // emergency stop, and keyed laser-enable selector.  Their bodies pass
        // through the cutouts in enclosure_side_panels(); nothing is perched
        // on the top deck.
        operator_y=front_skin_y;
        operator_z=270;

        // Analog galvanometer-style tube current meter.
        color([0.055,0.06,0.065])
            translate([galvanometer_x,operator_y-6,operator_z])
                cube([88,10,65],center=true);
        color([0.92,0.92,0.88])
            translate([galvanometer_x,operator_y-12,operator_z])
                cube([78,2,55],center=true);
        color([0.08,0.08,0.08]) {
            translate([galvanometer_x,operator_y-13,operator_z-7])
                rotate([0,-25,0]) cube([2,1,34],center=true);
            translate([galvanometer_x,operator_y-14,operator_z-21])
                rotate([90,0,0]) cylinder(d=6,h=2,center=true);
        }

        // Emergency stop: yellow legend plate and red mushroom operator.
        color([0.95,0.73,0.05])
            translate([estop_x,operator_y-4,upper_control_z]) rotate([90,0,0])
                cylinder(d=44,h=4,center=true);
        color([0.75,0.02,0.02]) {
            translate([estop_x,operator_y-11,upper_control_z]) rotate([90,0,0])
                cylinder(d=29,h=15,center=true);
            translate([estop_x,operator_y-22,upper_control_z]) sphere(d=32);
        }

        // Keyed laser-enable selector.
        color([0.08,0.085,0.09])
            translate([keyswitch_x,operator_y-5,upper_control_z]) rotate([90,0,0])
                cylinder(d=25,h=7,center=true);
        color([0.72,0.73,0.74]) {
            translate([keyswitch_x,operator_y-13,upper_control_z]) rotate([90,0,0])
                cylinder(d=9,h=16,center=true);
            translate([keyswitch_x,operator_y-23,upper_control_z])
                cube([4,3,18],center=true);
        }

        // Locking pendant receptacle mounts through the lower front row.  Its
        // cable exits forward and can fall naturally below the controls.
        color([0.055,0.06,0.065])
            translate([pendant_x,operator_y-6,pendant_z]) rotate([90,0,0])
                cylinder(d=31,h=10,center=true);
        color([0.72,0.73,0.74])
            for (a=[0:72:359])
                translate([pendant_x+7*cos(a),operator_y-12,
                           pendant_z+7*sin(a)])
                    rotate([90,0,0]) cylinder(d=2.5,h=3,center=true);

        // Controller LCD and black protective bezel mount through the top of
        // the electronics bay, centered across that bay and toward its front
        // edge for comfortable viewing from the operator position.
        color([0.04,0.045,0.05])
            translate([lcd_x,lcd_y,deck_z+7])
                cube([118,78,12],center=true);
        color([0.08,0.38,0.58])
            translate([lcd_x,lcd_y,deck_z+14])
                cube([104,64,2],center=true);

        // Four deck fasteners make the fixed/removable boundary explicit.
        color([0.72,0.73,0.74])
            for (x=[deck_left+12,deck_right-12],
                 y=[deck_front+12,deck_rear-12])
                translate([x,y,deck_z+3]) cylinder(d=7,h=3);
    }
}

module framed_hinged_lid(angle=24) {
    // Lid covers only the cutting chamber. Its right edge terminates at the
    // sealed electronics bulkhead; the bay has a fixed control deck.
    // The lid nests between the fixed left ledge and electronics-divider
    // post.  These are OUTER-FACE datums for the lid side rails (and the
    // centers of the silicone tubing in their outward-facing slots).
    // Leave only 2 mm to the neighboring fixed extrusion faces so the 6 mm
    // tubing projects into the gap and compresses when the lid closes.
    //
    // Do not inset these edges by another 10 mm: the side-rail loop below
    // already places each 20 mm rail center 10 mm inside its outer face.
    lid_side_seal_gap=2;
    fixed_left_ledge_inner_x=(-frame_width/2+10);
    divider_post_left_face=electronics_divider_x-10;
    lid_left=fixed_left_ledge_inner_x+lid_side_seal_gap;
    lid_right=divider_post_left_face-lid_side_seal_gap;
    lid_w=lid_right-lid_left;
    lid_cx=(lid_left+lid_right)/2;
    // The rear lid member and hinges now land on the full-width tube-cavity
    // mid brace. The laser tube remains beneath its own fixed service cap.
    hinge_y=tube_cavity_front_y;
    // Recess the complete lid 20 mm below its former datum.  Moving the
    // hinge axis with it keeps the frame, glazing, and real hinges connected.
    hinge_z=frame_height-30;
    // With the front lid member inset 10 mm from its boundary, this depth
    // puts its center on front_rail_y and its outer face on front_outer_y.
    lid_d=hinge_y-front_outer_y;

    // Everything after this transform rotates about the rear X-axis hinge.
    translate([lid_cx,hinge_y,hinge_z]) rotate([-angle,0,0]) {
        // Silver 2020 perimeter, matching the photographed lid frame.
        if (show_lid_frame) {
            for (local_y=[-lid_d+10,-10])
                translate([0,local_y,10]) extrusion2020_x(lid_w,black=false);
            for (local_x=[-lid_w/2+10,lid_w/2-10])
                translate([local_x,-lid_d/2,10])
                    rotate([-90,0,0])
                        aluminum_extrusion_2020(length=lid_d,center=true,black=false);

            // Round silicone cord is pressed into the moving lid extrusion
            // slots.  The front run stays in the bottom slot and closes onto
            // the recessed front ledge.  The left, rear, and right runs sit
            // in the OUTWARD-facing lid slots, inside the surrounding pocket.
            color(gasket_color) {
                // Front: underside slot, bearing downward on the ledge.
                translate([0,-lid_d+10,-0.5])
                    rotate([0,90,0])
                        cylinder(d=lid_gasket_diameter,
                                 h=lid_w-20,center=true,$fn=24);

                // Rear: outward/back-facing slot of the rear extrusion.
                translate([0,0,10])
                    rotate([0,90,0])
                        cylinder(d=lid_gasket_diameter,
                                 h=lid_w-40,center=true,$fn=24);

                // Sides: their outward-facing slots; shorten them between
                // the front and rear tubing runs to avoid corner overlap.
                for (local_x=[-lid_w/2,lid_w/2])
                    translate([local_x,-lid_d/2,10])
                        rotate([90,0,0])
                            cylinder(d=lid_gasket_diameter,
                                     h=lid_d-40,center=true,$fn=24);
            }
        }

        // Transparent laser-safe glazing representation.
        if (show_panels && show_lid_glazing)
            color([0.42,0.67,0.72,0.24])
                translate([0,-lid_d/2,10])
                    cube([lid_w-38,lid_d-38,3],center=true);
    }

    // Three hinges fasten directly to the tube-cavity mid brace.
    if (show_lid_frame)
        for (x=[lid_cx-lid_w/3,lid_cx,lid_cx+lid_w/3])
            translate([x,hinge_y,hinge_z])
                enclosure_hinge_assembly(width=42,leaf_depth=22);
}

module tube_cavity_cap() {
    if (show_panels && show_tube_cavity_cap) {
        cap_front=tube_cavity_front_y;
        cap_rear=rear_outer_y;
        cap_depth=cap_rear-cap_front;
        cap_y=(cap_front+cap_rear)/2;
        cap_width=frame_width-20;
        cap_z=tube_cavity_top_z+2;

        // Four-millimetre lift-off sheet rests on the mid, rear, and side
        // 2020 top faces. It is independent of both the cutting lid and the
        // electronics control deck, so tube service does not expose either.
        color([0.30,0.32,0.33])
            translate([0,cap_y,cap_z])
                cube([cap_width,cap_depth,4],center=true);

        // Perimeter fasteners into T-nuts make the removable boundary clear.
        color([0.72,0.73,0.74]) {
            for (x=[-cap_width/2+15,cap_width/2-15],
                 y=[cap_front+15,cap_rear-15])
                translate([x,y,cap_z+2.5]) cylinder(d=7,h=3,center=true,$fn=28);
            for (x=[-360,0,360], y=[cap_front+12,cap_rear-12])
                translate([x,y,cap_z+2.5]) cylinder(d=7,h=3,center=true,$fn=28);
        }
    }
}

module machine_enclosure() {
    if (show_enclosure) {
        enclosure_side_panels();
        electronics_service_panel();
        isolated_electronics_bulkhead();
        cutting_chamber_exhaust();
        rear_mains_inlet();
        rear_tube_service_hatch();
        electronics_control_deck();
        tube_cavity_cap();
        framed_hinged_lid(angle=lid_angle);
    }
}

module laser_cutter() {
    base_frame();
    z_cutting_table();
    y_motion();
    x_motion_and_head();
    moving_services_drag_chains();
    tube_and_optics();
    electronics_bay();
    machine_enclosure();
    motion_clearance_review();
}

laser_cutter();

$vpr=[66,0,32];
$vpt=[0,0,220];
$vpd=2650;
