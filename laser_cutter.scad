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
show_enclosure=true;         // master enclosure switch: panels + lid
show_panels=true;            // master skin switch for an unobstructed assembly view
show_side_panels=true;       // left and right outer skins
show_left_lower_access_panel=true;
show_left_upper_access_panel=true;
show_rear_panel=true;
show_front_panel=true;
show_electronics_bulkhead=true;
show_rear_tube_hatch=true;
show_control_panel=true;
show_lid_glazing=false;
show_lid_frame=false;
lid_angle=24;                // [0:5:75] 0=closed; positive raises front edge
rear_tube_hatch_angle=0;     // [0:5:80] 0=closed; opens outward/upward
electronics_service_panel_angle=0; // [0:5:100] right-side bay access

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
animate_motion=false;        // use View > Animate; $t sweeps the work envelope
show_motion_clearance=false; // transparent head/motor keep-out volumes
x_carriage_position=animate_motion ? -330+660*$t : x_axis_position;
y_carriage_position=animate_motion
    ? -150+300*(0.5-0.5*cos(360*$t)) : y_axis_position;

// Concept frame and working envelope.
frame_width=1219.2;           // one full 48 in 2020 stick
frame_depth=650;
frame_height=360;
// Shared enclosure-face datums. A 20 mm front/rear rail is centered 10 mm
// inside the nominal envelope. The 3 mm skin sits inside it with its visible
// face exactly flush to that same envelope.
front_outer_y=-frame_depth/2;
rear_outer_y=frame_depth/2;
front_rail_y=front_outer_y+10;
rear_rail_y=rear_outer_y-10;
front_skin_y=front_outer_y+1.5;
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
// Horizontal center of the exposed upper electronics-bay front panel.
// Keep the galvanometer body and its sheet-metal opening on this datum.
galvanometer_x=(electronics_divider_x+10+(frame_width-45)/2)/2;
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
tube_tunnel_end_x=540;       // leaves 40 mm before the right frame upright
tube_tunnel_size_y=170;      // rear service alcove width
tube_tunnel_size_z=140;      // clearance for terminal, hoses and HV insulation


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

    // Structural frame for the isolated tube pocket. Two complete Y-Z
    // rectangles are joined by four X-running rails, so the tunnel skins are
    // cladding rather than unsupported sheet. Rails sit just inside the
    // nominal 170 x 140 mm tunnel envelope, leaving a 130 x 100 mm clear
    // aperture around the 50 mm tube, terminal insulation and water lines.
    if (show_tube_pocket_frame) {
        pocket_x0=electronics_divider_x;
        pocket_x1=tube_tunnel_end_x;
        pocket_xc=(pocket_x0+pocket_x1)/2;
        pocket_len=pocket_x1-pocket_x0;
        pocket_y_half=tube_tunnel_size_y/2-10;
        pocket_z_half=tube_tunnel_size_z/2-10;
        pocket_y_clear=tube_tunnel_size_y-40;
        pocket_z_clear=tube_tunnel_size_z-40;

        // Mouth and closed-end rectangular frames.
        for (x=[pocket_x0,pocket_x1]) {
            for (z=[optical_axis_z-pocket_z_half,
                    optical_axis_z+pocket_z_half])
                translate([x,tube_shelf_y,z])
                    extrusion2020_y(tube_tunnel_size_y);
            for (y=[tube_shelf_y-pocket_y_half,
                    tube_shelf_y+pocket_y_half])
                translate([x,y,optical_axis_z-pocket_z_half+10])
                    extrusion2020_z(pocket_z_clear);
        }

        // Four longitudinal corner rails close the load path in depth.
        for (y=[tube_shelf_y-pocket_y_half,
                tube_shelf_y+pocket_y_half],
             z=[optical_axis_z-pocket_z_half,
                optical_axis_z+pocket_z_half])
            translate([pocket_xc,y,z]) extrusion2020_x(pocket_len);

        // The lower end-frame corners bear on short posts down to the
        // electronics-bay foundation instead of floating above its floor.
        support_bottom_z=88;
        support_top_z=optical_axis_z-pocket_z_half-10;
        for (x=[pocket_x0,pocket_x1],
             y=[tube_shelf_y-pocket_y_half,
                tube_shelf_y+pocket_y_half])
            translate([x,y,support_bottom_z])
                extrusion2020_z(support_top_z-support_bottom_z);
    }

    // Gasket sits only on the supported side/rear lid ledges.  The front is
    // the 20 mm recessed pocket wall, not a fourth landing rail.
    gasket_left=outer_left-10;
    gasket_right=electronics_divider_x;
    gasket_length=gasket_right-gasket_left;
    gasket_center_x=(gasket_left+gasket_right)/2;
    color([0.035,0.038,0.04]) {
        translate([gasket_center_x,rear_rail_y,upper_chassis_z+15])
            cube([gasket_length,8,10],center=true);
        for (x=[gasket_left,gasket_right])
            translate([x,0,upper_chassis_z+15])
                cube([8,frame_depth-40,10],center=true);
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
        co2_laser_tube(diameter=tube_diameter,length=tube_length);

    // A1 at the tube output and A2 carried close to the left service wall.
    // Both mirror centers share the wall-clearance-derived X datum above;
    // moving this datum carries the pedestals, bridge and beam path together.
    tube_output_x=tube_center_x-tube_length/2;
    tube_terminal_x=tube_center_x+tube_length/2;
    // The lid's electronics-side 2020 rail occupies the 20 mm immediately
    // inside its right edge (electronics_divider_x-3).
    lid_edge_rail_inner_x=electronics_divider_x-23;
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
        // Low rear shelf keeps HV supply separated from the motion electronics.
        translate([500,180,67])
            rotate([0,0,90]) vevor_laser_power_supply_50w(show_cable=false);
        translate([500,-95,67])
            microstep_driver_pair(spacing=82);
    }
}

module enclosure_side_panels() {
    panel=[0.74,0.76,0.75,0.72];
    // Opaque lower side and rear panels fitted inside the extrusion frame.
    if (show_panels && show_side_panels) {
        // The former one-piece left skin is now two lift-off access panels.
        // There is no fixed horizontal mullion: removing both panels exposes
        // nearly the complete perimeter opening for oversized workpieces.
        left_panel_x=-frame_width/2+10;
        left_panel_y_span=frame_depth-45;
        left_panel_bottom=22.5;
        left_panel_split=180;
        left_panel_top=frame_height-22.5;
        panel_seam=4;
        lower_panel_top=left_panel_split-panel_seam/2;
        upper_panel_bottom=left_panel_split+panel_seam/2;
        lower_panel_h=lower_panel_top-left_panel_bottom;
        upper_panel_h=left_panel_top-upper_panel_bottom;

        if (show_left_lower_access_panel)
            left_access_panel(left_panel_x,0,
                              (left_panel_bottom+lower_panel_top)/2,
                              left_panel_y_span,lower_panel_h,
                              handle_z=112);
        if (show_left_upper_access_panel)
            left_access_panel(left_panel_x,0,
                              (upper_panel_bottom+left_panel_top)/2,
                              left_panel_y_span,upper_panel_h,
                              handle_z=258);

        // Compressible gasket remains on the fixed perimeter plus the
        // shared panel seam; it does not obstruct the opening when removed.
        color([0.035,0.038,0.04]) {
            for (y=[-left_panel_y_span/2,left_panel_y_span/2])
                translate([left_panel_x+2,y,frame_height/2])
                    cube([5,8,frame_height-45],center=true);
            for (z=[left_panel_bottom,left_panel_top])
                translate([left_panel_x+2,0,z])
                    cube([5,left_panel_y_span,8],center=true);
        }
        // The seam seal belongs to the removable sheets, not the chassis;
        // it leaves the opening when both panels are taken off.
        if (show_left_lower_access_panel || show_left_upper_access_panel)
            color([0.035,0.038,0.04])
                translate([left_panel_x+2,0,left_panel_split])
                    cube([5,left_panel_y_span,8],center=true);

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
            translate([0,frame_depth/2-10,frame_height/2])
                cube([frame_width-45,3,frame_height-45],center=true);
            if (show_exhaust_port)
                translate([motion_center_x,frame_depth/2-10,exhaust_port_z])
                    rotate([90,0,0]) cylinder(d=exhaust_port_d,h=8,center=true);
            if (show_rear_tube_hatch)
                translate([-25,frame_depth/2-10,optical_axis_z])
                    cube([1050,8,120],center=true);
        }
    }
    if (show_panels && show_front_panel) {
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

        lower_bottom_z=22;
        lower_h=front_fascia_start_z-lower_bottom_z;
        upper_h=frame_height-20-front_fascia_start_z;

            // Squared two-piece front: removable lower service panel and a
            // coplanar upper infill panel, both fixed to the straight frame.
            color([0.20,0.22,0.23]) {
                translate([cutting_panel_x,front_y,lower_bottom_z+lower_h/2])
                    cube([cutting_panel_w,3,lower_h],center=true);
                difference() {
                    translate([electronics_panel_x,front_y,
                               lower_bottom_z+lower_h/2])
                        cube([electronics_panel_w,3,lower_h],center=true);
                    translate([455,front_y,130]) rotate([90,0,0])
                        cylinder(d=32,h=8,center=true);
                    translate([520,front_y,130]) rotate([90,0,0])
                        cylinder(d=26,h=8,center=true);
                    translate([570,front_y,130]) rotate([90,0,0])
                        cylinder(d=20,h=8,center=true);
                }
            }
            // Upper infill includes real cutouts for the electronics-bay
            // operator controls on the vertical front face.
            color([0.30,0.32,0.33])
                difference() {
                    union() {
                        translate([cutting_panel_x,front_y,
                                   front_fascia_start_z+upper_h/2])
                            cube([cutting_panel_w,3,upper_h],center=true);
                        translate([electronics_panel_x,front_y,
                                   front_fascia_start_z+upper_h/2])
                            cube([electronics_panel_w,3,upper_h],center=true);
                    }
                    // Galvanometer rectangular body opening.
                    translate([galvanometer_x,front_y,270])
                        cube([82,8,59],center=true);
                }
            color([0.08,0.085,0.09])
                translate([0,front_rail_y,front_fascia_start_z])
                    extrusion2020_x(panel_w);
            color([0.08,0.085,0.09])
                for (x=[-panel_w/2+28,panel_w/2-28],
                     z=[55,front_fascia_start_z-28])
                    translate([x,front_y-2,z])
                        rotate([90,0,0]) cylinder(d=10,h=4,center=true);
    }
}

// Lift-off left-side enclosure panel. Coordinate inputs are global; the
// sheet normal is X. Four quarter-turn fasteners engage the fixed perimeter,
// and a formed U-handle projects outward from the cutting chamber.
module left_access_panel(x,y,z,width,height,handle_z) {
    color([0.56,0.58,0.59,0.82])
        translate([x,y,z]) cube([3,width,height],center=true);

    // Folded edge returns stiffen the removable sheet without leaving a
    // structural bar across the side opening after panel removal.
    color([0.38,0.40,0.41])
        for (yedge=[y-width/2+7,y+width/2-7])
            translate([x+3,yedge,z]) cube([8,12,height-12],center=true);

    // Quarter-turn compression latches at the two end-frame uprights.
    color([0.06,0.065,0.07])
        for (yfast=[y-width/2+22,y+width/2-22],
             zfast=[z-height/2+22,z+height/2-22])
            translate([x-3,yfast,zfast]) rotate([0,90,0])
                cylinder(d=10,h=5,center=true,$fn=32);

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
        door_x=frame_width/2-6;
        hinge_y=270;
        door_y=536;
        door_z=266;

        // Rear vertical hinge; positive angle swings the door outward (+X).
        translate([door_x,hinge_y,170]) rotate([0,0,angle]) {
            color([0.56,0.58,0.59])
                translate([0,-door_y/2,0]) cube([4,door_y,door_z],center=true);
            // Two quarter-turn compression latches on the front edge.
            color([0.06,0.065,0.07])
                for (z=[115,225])
                    translate([5,-door_y+18,z-170]) cube([10,24,22],center=true);
        }

        for (z=[105,170,235])
            translate([door_x,hinge_y,z]) rotate([0,90,0])
                lid_hinge(width=38);
    }
}

module isolated_electronics_bulkhead() {
    if (show_panels && show_electronics_bulkhead) {
        // Continuous sheet from base structure to the top-frame gasket plane,
        // except for the sealed tube-tunnel penetration at the rear.
        color([0.66,0.68,0.68])
            difference() {
                translate([electronics_divider_x,0,190])
                    cube([3,frame_depth-42,320],center=true);
                translate([electronics_divider_x,tube_shelf_y,optical_axis_z])
                    cube([8,tube_tunnel_size_y-6,
                           tube_tunnel_size_z-6],center=true);
            }

        // A removable, closed-end rear service alcove lets the tube terminal,
        // water hoses and HV insulation occupy otherwise unused bay volume
        // without sharing air or smoke with the electronics.
        tunnel_len=tube_tunnel_end_x-electronics_divider_x;
        color([0.66,0.68,0.68]) {
            difference() {
                translate([electronics_divider_x+tunnel_len/2,
                           tube_shelf_y,optical_axis_z])
                    cube([tunnel_len,tube_tunnel_size_y,
                           tube_tunnel_size_z],center=true);
                translate([electronics_divider_x-2+(tunnel_len-5)/2,
                           tube_shelf_y,optical_axis_z])
                    cube([tunnel_len-5,tube_tunnel_size_y-8,
                           tube_tunnel_size_z-8],center=true);
            }
            translate([tube_tunnel_end_x-1.5,tube_shelf_y,optical_axis_z])
                cube([3,tube_tunnel_size_y,
                       tube_tunnel_size_z],center=true);
        }

        // Represent sealed cable glands/feedthroughs rather than open holes.
        color([0.07,0.075,0.08])
            for (y=[-120,-80,-40])
                translate([electronics_divider_x,y,105]) rotate([0,90,0])
                    cylinder(d=14,h=12,center=true);
        // Dedicated nearby gland for the right-side Y motor cable.
        color([0.07,0.075,0.08])
            translate([electronics_divider_x,-frame_depth/2+44,135])
                rotate([0,90,0]) cylinder(d=14,h=12,center=true);
    }
}

module cutting_chamber_exhaust() {
    if (show_panels && show_rear_panel && show_exhaust_port) {
        // Rear flange only; the blower belongs downstream/outside the machine.
        color([0.16,0.17,0.18])
            translate([motion_center_x,frame_depth/2-14,exhaust_port_z])
                rotate([90,0,0])
                    difference() {
                        cylinder(d=exhaust_port_d+12,h=18,center=true);
                        cylinder(d=exhaust_port_d,h=20,center=true);
                    }
    }
}

module rear_tube_service_hatch(angle=rear_tube_hatch_angle) {
    if (show_panels && show_rear_panel && show_rear_tube_hatch) {
        hatch_cx=-25;
        hatch_w=1068;
        hatch_h=136;
        rear_y=frame_depth/2-7;
        hinge_z=optical_axis_z+68;

        // Fixed closed-cell gasket surrounding the 1050 x 120 mm opening.
        color([0.035,0.038,0.04]) {
            for (z=[optical_axis_z-64,optical_axis_z+64])
                translate([hatch_cx,rear_y-2,z])
                    cube([1060,5,8],center=true);
            for (x=[hatch_cx-529,hatch_cx+529])
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
                    for (x=[-350,350])
                        translate([x,4,-hatch_h+15])
                            cube([30,10,24],center=true);
            }

        // Three fixed hinges distribute the load across the long access door.
        for (x=[hatch_cx-350,hatch_cx,hatch_cx+350])
            translate([x,rear_y,hinge_z]) lid_hinge(width=46);
    }
}

module lid_hinge(width=42) {
    color([0.08,0.085,0.09]) {
        cube([width,14,5],center=true);
        rotate([0,90,0]) cylinder(d=8,h=width+6,center=true);
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
        deck_front=-frame_depth/2+30;
        deck_rear=frame_depth/2-30;
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
        lower_control_z=130;

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
            translate([455,operator_y-4,lower_control_z]) rotate([90,0,0])
                cylinder(d=44,h=4,center=true);
        color([0.75,0.02,0.02]) {
            translate([455,operator_y-11,lower_control_z]) rotate([90,0,0])
                cylinder(d=29,h=15,center=true);
            translate([455,operator_y-22,lower_control_z]) sphere(d=32);
        }

        // Keyed laser-enable selector.
        color([0.08,0.085,0.09])
            translate([570,operator_y-5,lower_control_z]) rotate([90,0,0])
                cylinder(d=25,h=7,center=true);
        color([0.72,0.73,0.74]) {
            translate([570,operator_y-13,lower_control_z]) rotate([90,0,0])
                cylinder(d=9,h=16,center=true);
            translate([570,operator_y-23,lower_control_z])
                cube([4,3,18],center=true);
        }

        // Locking pendant receptacle mounts through the lower front row.  Its
        // cable exits forward and can fall naturally below the controls.
        color([0.055,0.06,0.065])
            translate([520,operator_y-6,lower_control_z]) rotate([90,0,0])
                cylinder(d=31,h=10,center=true);
        color([0.72,0.73,0.74])
            for (a=[0:72:359])
                translate([520+7*cos(a),operator_y-12,
                           lower_control_z+7*sin(a)])
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
    // The left lid boundary is the outer face of the fixed side 2020. Since
    // the lid's side member is inset 10 mm from this boundary, its centerline
    // now lands exactly on outer_left (-frame_width/2+20) below it.
    lid_left=-frame_width/2+10;
    lid_right=electronics_divider_x-3;
    lid_w=lid_right-lid_left;
    lid_cx=(lid_left+lid_right)/2;
    hinge_y=frame_depth/2-12;
    // Closed lid bottom lands directly on the upper perimeter top (Z=350).
    hinge_z=frame_height-10;
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
        }

        // Transparent laser-safe glazing representation.
        if (show_panels && show_lid_glazing)
            color([0.42,0.67,0.72,0.24])
                translate([0,-lid_d/2,10])
                    cube([lid_w-38,lid_d-38,3],center=true);
    }

    // Three rear hinges remain fixed to the enclosure hinge axis.
    if (show_lid_frame)
        for (x=[lid_cx-lid_w/3,lid_cx,lid_cx+lid_w/3])
            translate([x,hinge_y,hinge_z]) lid_hinge();
}

module machine_enclosure() {
    if (show_enclosure) {
        enclosure_side_panels();
        electronics_service_panel();
        isolated_electronics_bulkhead();
        cutting_chamber_exhaust();
        rear_tube_service_hatch();
        electronics_control_deck();
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

// Simple hollow tube local to this assembly.
module co2_laser_tube(diameter=50,length=800) {
    color([0.72,0.91,1.00,0.38])
        rotate([90,0,0]) difference() {
            cylinder(d=diameter,h=length,center=true);
            cylinder(d=diameter-4,h=length+2,center=true);
        }
    color([0.88,0.92,0.94])
        for (y=[-length/2,length/2])
            translate([0,y,0]) rotate([90,0,0]) difference() {
                cylinder(d=diameter+5,h=8,center=true);
                cylinder(d=diameter-3,h=10,center=true);
            }
}

laser_cutter();

$vpr=[66,0,32];
$vpt=[0,0,220];
$vpd=2650;
