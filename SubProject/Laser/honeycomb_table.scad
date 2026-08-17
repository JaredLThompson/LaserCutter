// Honeycomb Table
use <kp08_pillow_block_bearing.scad>;
// 25"x17.5"
// or 635mm x 445mm

// frame 35 5/16" wide or 900mm

// acme screw at 32 5/8" or...
// 830 mm ---
// so offsets are at 70mm from ends

// I used 1" (1/8" thick) angle aluminum

angle_width = 25.4;
angle_thickness = 1/8 * 25.4;

flat_bar_width = 25.4;
flat_bar_thickness = 1/8*25.4;

hc_frame_depth = 444;
hc_frame_width = 635;

// Built frame is nominally 35 inches wide.  Keep the ACME locations derived
// from this value so a later metric measurement updates the whole assembly.
z_table_width = 35 * 25.4; // 889 mm
z_table_depth = 454;

acme_end_inset = 70;
acme_rod_length = 250;
acme_rod_bottom_z = -70;

acme_lower_bearing_z = -60;
acme_upper_bearing_z = 170;

kp08_shaft_center = 15;

// Fine adjustment for the rendered KP08 locations only: [X, Y, Z].
// Keep X/Y at zero when the bores are aligned with the ACME rods.
kp08_position_adjustment = [0, 0, 0];
// Plan-view orientation: the rear (+Y / "top") pair faces the opposite
// extrusion from the front (-Y / "bottom") pair.
kp08_front_flip = 0;
kp08_rear_flip = 180;

// Standalone-file preview controls. Top-level calls are ignored when this
// file is imported with `use`, so they do not duplicate cabinet parts.
preview_honeycomb_mesh = true;
preview_honeycomb_detail = "fast"; // "fast" or "detailed"
preview_acme_hardware = true;
preview_kp08_bearings = true;
preview_z_chain_drive = true;

z_table_assembly(
    show_honeycomb=preview_honeycomb_mesh,
    honeycomb_detail=preview_honeycomb_detail,
    show_acme_hardware=preview_acme_hardware);

if (preview_acme_hardware)
    z_table_leadscrew_assembly(
        show_bearings=preview_kp08_bearings);

if (preview_z_chain_drive)
    z_table_chain_drive_assembly();

// Preliminary #25-chain Z drive layout. These values are deliberately
// exposed so the motor and two idlers can be fitted around the cabinet.
z_chain_plane_z = -42;
// Rear-mounted beneath the laser-tube bay. The table is translated +150 Y in
// the cabinet, placing this motor near world Y=465 rather than outside the
// front chassis rail.
z_motor_position = [0, 315];
z_idler_left_position = [-105, 285];
z_idler_right_position = [105, 285];
z_motor_sprocket_teeth = 9;
z_motor_sprocket_bore = 6;
z_screw_sprocket_teeth = 10;
z_idler_sprocket_teeth = 20;
z_chain_pitch = 6.35; // ANSI #25 / ISO 04C, 1/4-inch pitch
z_chain_preview_width = 3.2;
z_motor_bracket_thickness = 3;
z_motor_bracket_width = 65;
z_motor_bracket_leg = 69;



//acme_mount();
module z_table_assembly(show_honeycomb=false,
                        honeycomb_detail="fast",
                        show_acme_hardware=true){
    //measureent cube
    //translate([0,-200-0])cube([450-70,10,10]);


    hc_frame(show_honeycomb=show_honeycomb,
             honeycomb_detail=honeycomb_detail);

    z_table();

    // Each screw is approximately 70 mm in from the end of the 35-inch frame.
    // Nominal center-to-center spacing: 889 - (2 * 70) = 749 mm.
    acme_x_offset = z_table_width / 2 - acme_end_inset;

    // Aligns the mount origin with the outer face of the front and back rails
    acme_y_offset = z_table_depth / 2;

    // Loop through all 4 corner positions
    for (x = [-acme_x_offset, acme_x_offset]) {
        for (y = [-acme_y_offset, acme_y_offset]) {

            translate([x, y, 0])
                // REVERSED: Spins 180 on the front rail (y < 0) so the bracket
                // projects outward toward the front, and stays at 0 on the back.
                rotate([0, 0, (y > 0) ? 0 : 180])
                    acme_mount(show_hardware=show_acme_hardware);

        }
    }
}

// Stationary Z-axis hardware.  This is intentionally separate from the
// moving table assembly: the table nuts travel along fixed lead screws.
module z_table_leadscrew_assembly(show_bearings=true) {
    acme_x_offset = z_table_width / 2 - acme_end_inset;
    acme_y_offset = z_table_depth / 2;

    for (x = [-acme_x_offset, acme_x_offset])
        for (y = [-acme_y_offset, acme_y_offset]) {
            // The front nut bracket is rotated outward, so its screw axis is
            // offset toward -Y; the rear bracket is offset toward +Y.
            screw_y = y + (y > 0 ? angle_width/2 : -angle_width/2);
            translate([x, screw_y, 0]) {
                translate([0, 0, acme_rod_bottom_z])
                    acme_rod_8mm(length=acme_rod_length);

                if (show_bearings) {
                    // The KP08 assembly includes its own 90-degree Z rotation.
                    // This compound rotation puts its bore on world Z while
                    // leaving the two mounting ears horizontal, as installed.
                    for (bearing_z = [acme_lower_bearing_z,
                                      acme_upper_bearing_z]) {
                        bearing_flip = y > 0
                                     ? kp08_rear_flip
                                     : kp08_front_flip;
                        // Rotating the rear bearing 180 degrees reverses the
                        // library's 15 mm shaft-center offset as well.
                        bearing_datum_y = bearing_flip == 180
                                        ? kp08_shaft_center
                                        : -kp08_shaft_center;
                        translate([kp08_position_adjustment[0],
                                   bearing_datum_y
                                     + kp08_position_adjustment[1],
                                   bearing_z
                                     + kp08_position_adjustment[2]])
                            rotate([0, 0, bearing_flip])
                                rotate([0, -90, -90])
                                    kp08_pillow_block_assembly();
                    }
                }
            }
        }
}

// Return the #25-chain pitch radius for a sprocket tooth count.
function chain_pitch_radius(teeth) =
    z_chain_pitch / (2 * sin(180 / teeth));

// External common tangent between two pitch circles.  `side=-1` selects the
// right-hand tangent while travelling c1 -> c2; this is the outside of the
// counter-clockwise Z-drive route below.
function chain_external_tangent(c1, r1, c2, r2, side=-1) =
    let(dx = c2[0] - c1[0],
        dy = c2[1] - c1[1],
        d = sqrt(dx*dx + dy*dy),
        phi = atan2(dy, dx),
        normal_angle = phi + side * acos((r1-r2)/d),
        n = [cos(normal_angle), sin(normal_angle)])
    [
        [c1[0] + r1*n[0], c1[1] + r1*n[1]],
        [c2[0] + r2*n[0], c2[1] + r2*n[1]]
    ];

function chain_point_angle(center, point) =
    atan2(point[1]-center[1], point[0]-center[0]);

// Follow the rotation imposed by the chain route.  Positive is CCW and
// negative is CW.  Unlike a shortest-arc choice, this preserves deliberate
// greater-than-180-degree engagement around the small drive sprocket.
function chain_directional_sweep(a1, a2, direction=1) =
    direction > 0
        ? ((a2-a1+360) % 360)
        : -((a1-a2+360) % 360);

// Stationary, mechanically synchronized four-screw Z drive.  Chain runs are
// calculated from the actual sprocket pitch circles so they touch the teeth
// tangentially instead of passing through the sprocket centers.
module z_table_chain_drive_assembly(show_motor=true,
                                    show_chain=true) {
    screw_x = z_table_width / 2 - acme_end_inset;
    screw_y = z_table_depth / 2 + angle_width/2;
    screw_points = [
        [-screw_x, -screw_y],
        [ screw_x, -screw_y],
        [ screw_x,  screw_y],
        z_idler_right_position,
        z_motor_position,
        z_idler_left_position,
        [-screw_x,  screw_y]
    ];
    route_teeth = [
        z_screw_sprocket_teeth,
        z_screw_sprocket_teeth,
        z_screw_sprocket_teeth,
        z_idler_sprocket_teeth,
        z_motor_sprocket_teeth,
        z_idler_sprocket_teeth,
        z_screw_sprocket_teeth
    ];
    // Screws and motor turn together; bearing idlers turn oppositely.  Using
    // these signs as signed pitch radii automatically selects external
    // tangents for equal-direction sprockets and internal tangents when the
    // chain crosses to an idler.
    route_directions = [1, 1, 1, -1, 1, -1, 1];
    route_radii = [for (teeth = route_teeth) chain_pitch_radius(teeth)];
    route_signed_radii = [
        for (i = [0 : len(route_radii)-1])
            route_radii[i] * route_directions[i]
    ];
    route_tangents = [
        for (i = [0 : len(screw_points)-1])
            chain_external_tangent(
                screw_points[i],
                route_signed_radii[i],
                screw_points[(i+1) % len(screw_points)],
                route_signed_radii[(i+1) % len(screw_points)],
                side=-1)
    ];

    // Four identical sprockets keep every ACME screw synchronized 1:1.
    for (x = [-screw_x, screw_x])
        for (y = [-screw_y, screw_y])
            translate([x, y, z_chain_plane_z])
                roller_chain_sprocket(
                    teeth=z_screw_sprocket_teeth,
                    bore=8,
                    width=3);

    // Bearing idlers route both chain spans around the small motor sprocket.
    for (p = [z_idler_left_position, z_idler_right_position])
        translate([p[0], p[1], z_chain_plane_z])
            color([0.20, 0.22, 0.24])
                roller_chain_sprocket(
                    teeth=z_idler_sprocket_teeth,
                    bore=8,
                    width=8,
                    show_hub=false);

    translate([z_motor_position[0], z_motor_position[1], z_chain_plane_z])
        color([0.12, 0.15, 0.17])
            roller_chain_sprocket(
                teeth=z_motor_sprocket_teeth,
                bore=z_motor_sprocket_bore,
                width=3);

    if (show_chain) {
        // Tangent straight spans.  These replace (rather than overlay) the
        // former center-to-center spans.
        for (i = [0 : len(screw_points)-1])
            chain_preview_segment(
                route_tangents[i][0],
                route_tangents[i][1],
                z=z_chain_plane_z + 1.5,
                width=z_chain_preview_width);

        // Calculated wrap from the incoming tangent to the outgoing tangent
        // at every sprocket.  The small continuous backing masks sub-pitch
        // rounding at the joins while the rollers show the real #25 pitch.
        for (i = [0 : len(screw_points)-1]) {
            incoming = route_tangents[(i-1+len(screw_points))
                                      % len(screw_points)][1];
            outgoing = route_tangents[i][0];
            start_angle = chain_point_angle(screw_points[i], incoming);
            end_angle = chain_point_angle(screw_points[i], outgoing);
            chain_sprocket_wrap_between(
                center=screw_points[i],
                radius=route_radii[i],
                start_angle=start_angle,
                sweep=chain_directional_sweep(
                    start_angle,
                    end_angle,
                    route_directions[i]),
                z=z_chain_plane_z + 1.5,
                width=z_chain_preview_width);
        }
    }

    if (show_motor)
        translate([z_motor_position[0], z_motor_position[1], 0]) {
            // Purchased 65 x 69 x 3 mm NEMA 23 right-angle mount.  Its
            // upright faces -Y toward the central 2040 support.
            translate([0, 0, z_chain_plane_z + 5])
                nema23_right_angle_mount();

            // Motor rests on top of the 3 mm horizontal plate.  The shaft
            // passes through the bracket and points down into the sprocket.
            translate([0, 0,
                       z_chain_plane_z + 5 + z_motor_bracket_thickness])
                z_drive_stepper_preview(
                    body=57,
                    length=56,
                    shaft_d=z_motor_sprocket_bore,
                    shaft_down=true);
        }
}

// Dimensioned preview of the purchased NEMA 23 right-angle mounting bracket.
// Local origin is the motor shaft center on the bottom of the horizontal leg.
module nema23_right_angle_mount() {
    w = z_motor_bracket_width;
    leg = z_motor_bracket_leg;
    t = z_motor_bracket_thickness;
    bend_to_motor = 39;
    motor_pitch = 47;
    frame_slot_pitch = 40;
    frame_slot_length = 42;
    frame_slot_width = 4.2;

    color([0.12, 0.12, 0.13]) {
        // Horizontal motor plate: 39 mm behind and 30 mm ahead of shaft.
        difference() {
            translate([-w/2, -bend_to_motor, 0])
                cube([w, leg, t]);

            // NEMA 23 pilot and its 47 mm square mounting pattern.
            translate([0, 0, -0.1])
                cylinder(d=45, h=t+0.2, $fn=64);
            for (x = [-motor_pitch/2, motor_pitch/2])
                for (y = [-motor_pitch/2, motor_pitch/2])
                    translate([x, y, -0.1])
                        cylinder(d=5.2, h=t+0.2, $fn=24);

            // Alternate four-hole pattern shown on the supplier drawing.
            for (a = [45 : 90 : 315])
                rotate([0, 0, a])
                    translate([19.1, 0, -0.1])
                        cylinder(d=5, h=t+0.2, $fn=24);
        }

        // Vertical 2040 mounting face with two 42 mm adjustment slots.
        difference() {
            translate([-w/2, -bend_to_motor-t, 0])
                cube([w, t, leg]);
            for (x = [-frame_slot_pitch/2, frame_slot_pitch/2])
                translate([x, -bend_to_motor-t-0.1, 10])
                    rotate([-90, 0, 0])
                        hull() {
                            cylinder(d=frame_slot_width,
                                     h=t+0.2,
                                     $fn=20);
                            translate([0, frame_slot_length, 0])
                                cylinder(d=frame_slot_width,
                                         h=t+0.2,
                                         $fn=20);
                        }
        }

        // The supplier bracket has a 15 x 25 mm triangular gusset at each
        // side.  Hulls keep this preview inexpensive while matching its load
        // path from the horizontal plate into the upright.
        for (x = [-w/2, w/2-t])
            hull() {
                translate([x, -bend_to_motor, 0]) cube([t, t, t]);
                translate([x, -bend_to_motor+15, 0]) cube([t, t, t]);
                translate([x, -bend_to_motor, 25]) cube([t, t, t]);
            }
    }
}



// Fully detailed #25 Roller Chain Segment Model
module chain_preview_segment(p1, p2, z=0, width=3.2) {
    // --- #25 Industrial Chain Dimensions (mm) ---
    pitch = 6.35;        // 1/4 inch spacing center-to-center
    pin_dia = 2.31;      // Pin diameter
    roller_dia = 3.30;   // Roller outer diameter
    link_width = 3.18;   // Internal width of inner link
    plate_thick = 0.76;  // Link plate thickness
    plate_height = 5.84; // Outer link plate waist height

    // --- Path Math ---
    dx = p2[0] - p1[0];
    dy = p2[1] - p1[1];
    distance = sqrt(dx*dx + dy*dy);
    angle = atan2(dy, dx);

    // Calculate exactly how many pitches fit into this run
    links_count = floor(distance / pitch);

    // Continuous pitch-line backing reaches both calculated tangent points.
    // The detailed links below are quantized to whole pitches; without this
    // backing their final fractional pitch appeared as a gap at each wrap.
    color([0.12, 0.12, 0.12])
        hull() {
            translate([p1[0], p1[1], z])
                cylinder(h=link_width + plate_thick*3,
                         d=plate_height,
                         center=true,
                         $fn=16);
            translate([p2[0], p2[1], z])
                cylinder(h=link_width + plate_thick*3,
                         d=plate_height,
                         center=true,
                         $fn=16);
        }

    // Helper: A single hourglass-shaped chain side plate
    module link_plate() {
        linear_extrude(height = plate_thick, center = true) {
            hull() {
                circle(d = plate_height, $fn=24);
                translate([pitch, 0, 0]) circle(d = plate_height, $fn=24);
            }
        }
    }

    // Render the links running down the line
    translate([p1[0], p1[1], z])
    rotate([0, 0, angle]) {
        for (i = [0 : links_count - 1]) {
            translate([i * pitch, 0, 0]) {

                // ALTERNATING LINKS: Even indexes are Inner, Odd are Outer
                if (i % 2 == 0) {
                    // --- INNER LINK ---
                    color("Silver") {
                        // Bottom Side Plate
                        translate([0, 0, -link_width/2 - plate_thick/2]) link_plate();
                        // Top Side Plate
                        translate([0, 0,  link_width/2 + plate_thick/2]) link_plate();
                        // Rollers/Bushings over the pin positions
                        translate([0, 0, 0]) cylinder(h = link_width, d = roller_dia, center=true, $fn=24);
                        translate([pitch, 0, 0]) cylinder(h = link_width, d = roller_dia, center=true, $fn=24);
                    }
                } else {
                    // --- OUTER LINK ---
                    color("DarkGray") {
                        // Outer plates sit further apart on Z axis to overlap inner links cleanly
                        z_offset = link_width/2 + plate_thick + plate_thick/2 + 0.05;

                        // Bottom Outer Plate
                        translate([0, 0, -z_offset]) link_plate();
                        // Top Outer Plate
                        translate([0, 0,  z_offset]) link_plate();

                        // Solid Connecting Pins
                        pin_h = link_width + (plate_thick * 3);
                        translate([0, 0, 0]) cylinder(h = pin_h, d = pin_dia, center=true, $fn=16);
                        translate([pitch, 0, 0]) cylinder(h = pin_h, d = pin_dia, center=true, $fn=16);
                    }
                }

            }
        }
    }
}

// Continuous #25-chain wrap between two calculated tangent points.  Rollers
// are spaced by the real 6.35 mm pitch while the dark backing guarantees a
// closed preview even when an arc contains a fractional final pitch.
module chain_sprocket_wrap_between(center=[0, 0],
                                   radius=10,
                                   start_angle=0,
                                   sweep=90,
                                   z=0,
                                   width=3.2) {
    pitch = z_chain_pitch;
    roller_dia = 3.30;
    plate_height = 5.84;
    chain_height = 3.18 + 0.76*3;
    arc_length = abs(sweep) * PI / 180 * radius;
    roller_count = max(1, floor(arc_length / pitch));
    render_steps = max(2, ceil(abs(sweep) / 6));

    // Smooth backing follows the pitch circle precisely.
    color([0.12, 0.12, 0.12])
        for (step = [0 : render_steps-1]) {
            a1 = start_angle + sweep * step/render_steps;
            a2 = start_angle + sweep * (step+1)/render_steps;
            hull() {
                translate([center[0] + radius*cos(a1),
                           center[1] + radius*sin(a1), z])
                    cylinder(h=chain_height,
                             d=plate_height,
                             center=true,
                             $fn=16);
                translate([center[0] + radius*cos(a2),
                           center[1] + radius*sin(a2), z])
                    cylinder(h=chain_height,
                             d=plate_height,
                             center=true,
                             $fn=16);
            }
        }

    // Roller centers include both tangent ends.  Their angular distribution
    // is uniform; the maximum visual pitch error is confined to the final
    // fractional link instead of accumulating around the sprocket.
    color("Silver")
        for (i = [0 : roller_count]) {
            a = start_angle + sweep * i/roller_count;
            translate([center[0] + radius*cos(a),
                       center[1] + radius*sin(a), z])
                cylinder(h=3.18,
                         d=roller_dia,
                         center=true,
                         $fn=18);
        }
}



module roller_chain_sprocket(teeth=10,
                             bore=8,
                             width=3,
                             show_hub=true) {
    pitch_d = z_chain_pitch / sin(180/teeth);
    root_d = pitch_d - z_chain_pitch * 0.72;
    tooth_d = z_chain_pitch * 0.58;

    difference() {
        union() {
            cylinder(d=root_d, h=width, center=true, $fn=max(24, teeth*3));
            for (a = [0 : 360/teeth : 359])
                rotate([0, 0, a])
                    translate([pitch_d/2, 0, 0])
                        cylinder(d=tooth_d,
                                 h=width,
                                 center=true,
                                 $fn=12);
            if (show_hub)
                translate([0, 0, -width/2-3])
                    cylinder(d=max(16, bore+8), h=6, $fn=32);
        }
        cylinder(d=bore, h=width+14, center=true, $fn=32);
    }
}

module z_drive_stepper_preview(body=57,
                               length=56,
                               shaft_d=6,
                               shaft_down=false) {
    if (shaft_down) {
        // Body above the chain plane, with the registration boss and shaft
        // pointing down toward the motor sprocket.
        color("DarkSlateGray")
            translate([-body/2, -body/2, 0])
                cube([body, body, length]);
        color("silver") {
            translate([0, 0, 0])
                rotate([180, 0, 0])
                    cylinder(d=38, h=2, $fn=48);
            translate([0, 0, 0])
                rotate([180, 0, 0])
                    cylinder(d=shaft_d, h=14, $fn=32);
        }
    } else {
        color("DarkSlateGray")
            translate([-body/2, -body/2, 0])
                cube([body, body, length]);
        color("silver") {
            translate([0, 0, length])
                cylinder(d=38, h=2, $fn=48);
            translate([0, 0, length+2])
                cylinder(d=shaft_d, h=14, $fn=32);
        }
    }
}



module hc_frame(show_honeycomb=false,
                honeycomb_detail="fast"){
    color("silver")
    translate([0,0,angle_thickness])difference(){
        translate([0,0,angle_width/2])cube([hc_frame_width,hc_frame_depth,angle_width], center=true);

        //cutouts
        translate([0,0,angle_width/2+angle_thickness])cube([hc_frame_width-angle_thickness*2,hc_frame_depth-angle_thickness*2,angle_width], center=true);

        translate([0,0,angle_width/2-angle_thickness])cube([hc_frame_width-angle_width*2,hc_frame_depth-angle_width*2,angle_width], center=true);
    }//difference

    if(show_honeycomb){
        // Positioned flat inside the lower ledge of the angle aluminum frame
        translate([0, 0, angle_thickness + angle_width/2])
            if (honeycomb_detail == "detailed")
                honeycomb_mesh();
            else
                honeycomb_mesh_fast();
    }
}

// Lightweight cabinet preview. This intentionally suggests a honeycomb bed
// rather than reproducing every cell. It uses a shallow dark core and two
// clipped families of narrow ribs, avoiding thousands of per-cell booleans.
module honeycomb_mesh_fast() {
    inner_w = hc_frame_width - angle_width * 2;
    inner_d = hc_frame_depth - angle_width * 2;
    mesh_height = 4;
    rib_pitch = 18;
    rib_width = 0.8;
    diagonal_length = sqrt(inner_w * inner_w + inner_d * inner_d) + 20;

    color([0.10, 0.13, 0.14])
        cube([inner_w, inner_d, 1], center=true);

    color([0.48, 0.55, 0.56])
        intersection() {
            cube([inner_w, inner_d, mesh_height], center=true);
            union()
                for (angle = [-60, 60])
                    rotate([0, 0, angle])
                        for (y = [-diagonal_length/2 : rib_pitch : diagonal_length/2])
                            translate([0, y, mesh_height/2])
                                cube([diagonal_length, rib_width, mesh_height],
                                     center=true);
        }
}

// Detailed parametric honeycomb grid. Best reserved for isolated inspection;
// the fast version above is substantially cheaper in the full machine model.
module honeycomb_mesh() {
    cell_radius = 6;      // Distance from center to a corner of a cell
    wall_thickness = 1.0; // Thickness of the honeycomb structural walls
    mesh_height = 12.7;   // Standard 1/2 inch core thickness

    // Mathematical spacing values for standard hexagons
    x_spacing = cell_radius * 1.5 + wall_thickness * sqrt(3)/2;
    y_spacing = cell_radius * sqrt(3) + wall_thickness;

    // Calculate how many rows and columns fit inside the inner frame opening
    inner_w = hc_frame_width - angle_thickness * 2;
    inner_d = hc_frame_depth - angle_thickness * 2;
    cols = floor(inner_w / x_spacing);
    rows = floor(inner_d / y_spacing);

    color("darkgray") {
        // Intersect bounds so hexagons do not poke through the metal frame outer edge
        intersection() {
            cube([inner_w, inner_d, mesh_height], center=true);

            // Loop through columns and rows to generate the structure efficiently
            translate([-inner_w/2, -inner_d/2, 0])
            for (c = [0 : cols]) {
                for (r = [0 : rows]) {
                    // Offset every second column to stagger the honeycombs correctly
                    y_offset = (c % 2 == 0) ? 0 : y_spacing / 2;

                    translate([c * x_spacing + cell_radius, r * y_spacing + y_offset + cell_radius, 0])
                        rotate([0, 0, 30])
                            difference() {
                                // Outer cell boundary
                                cylinder(h=mesh_height, r=cell_radius + wall_thickness/2, $fn=6, center=true);
                                // Inner empty cutout
                                cylinder(h=mesh_height + 2, r=cell_radius - wall_thickness/2, $fn=6, center=true);
                            }
                }
            }
        }
    }
}

module z_table(){
    z_rail_offset = 290;

    translate([0,-z_table_depth/2,0])
        angle_aluminum(length = z_table_width);
    translate([0,z_table_depth/2,0])
        rotate([0,0,180])
        angle_aluminum(length = z_table_width);
    translate([-z_rail_offset,0,-angle_thickness])
        rotate([0,0,90])
        flat_aluminum(length=z_table_depth);
    translate([z_rail_offset,0,-angle_thickness])
        rotate([0,0,-90])
        flat_aluminum(length=z_table_depth);
}

module acme_mount(show_hardware=false) {
    difference() {
        // 1. The solid aluminum angle bracket
        translate([0,0,angle_width])
            rotate([180,0,180])
                angle_aluminum(100);

        // 2. DRILL HOLES: Reusing your exact nut coordinates to align the drill bits
        translate([0, angle_width/2, 29])
            rotate([180,0,45]) {

                // Center boss clearance hole (body_d is 10.3mm, so 11mm gives clean clearance)
                translate([0, 0, 0])
                    cylinder(h=30, d=11, $fn=32, center=true);

                // 4x Mounting screw holes matching the flange bolt circle pattern
                hole_pitch_d = 16;
                for (a = [0 : 90 : 270]) {
                    rotate([0, 0, a])
                    translate([hole_pitch_d/2, 0, 0])
                        cylinder(h=30, d=3.4, $fn=16, center=true);
                }
            }
    } // end of difference

    if(show_hardware){
        // 3. The visible brass hardware nut
        translate([0, angle_width/2, 29])
            rotate([180,0,45])
                acme_nut_8mm();

        // Lead screw and KP08 supports are stationary chassis hardware and
        // are rendered by z_table_leadscrew_assembly().
    }
}




module flat_aluminum(length){
    color("silver")translate([-length/2,0,0])
        cube([length,flat_bar_width,flat_bar_thickness]);
}

module angle_aluminum(length=100) {
    color("silver") union(){
        translate([-length/2,0,0])cube([length,angle_width,angle_thickness]);
        translate([-length/2,0,0])cube([length,angle_thickness,angle_width]);
    } //union
}



// =======================================================================
// Acme 8mm Rod & Trapezoidal Nut Components
// =======================================================================

// Preview assembly
//translate([0, 0, 40])
//    rotate([180,0,0])acme_nut_8mm();
//acme_rod_8mm(length = 150);


// Module for a standard T8 Acme Lead Screw
// 8mm Outer Diameter, 2mm Pitch, 4 Starts (8mm Lead per turn)
module acme_rod_8mm(length=100) {
    lead = 8;       // Travel distance per full rotation (mm)
    starts = 4;     // Number of interleaved thread grooves
    od = 8;         // Outer diameter (mm)
    id = 6.2;       // Core inner root diameter (mm)

    total_turns = length / lead;
    total_twist = total_turns * 360;

    color("silver") {
        // Smooth unthreaded end tip (standard for mounting bearings)
        cylinder(h=10, d=5, center=false, $fn=32);

        // Main threaded helical body
        translate([0, 0, 10])
        linear_extrude(height=length-10, twist=-total_twist, $fn=40) {
            // 1. Internal solid core rod
            circle(d=id);

            // 2. Helical thread teeth projecting outward
            for (i = [0 : starts-1]) {
                rotate(i * 360 / starts)
                translate([0, id/2 - 0.1, 0])
                polygon(points=[
                    [-1.0, 0],      // Wide base at core root
                    [1.0, 0],
                    [0.5, 1.0],     // Flat trapezoidal ridge top
                    [-0.5, 1.0]
                ]);
            }
        }
    }
}

// Module for a standard Brass Trapezoidal Flange Nut
module acme_nut_8mm() {
    flange_d = 22;     // Large mounting flange diameter
    flange_h = 3.5;    // Thickness of the flange plate
    body_d = 10.3;     // Raised center boss diameter
    body_h = 15;       // Total overall height of the nut
    hole_pitch_d = 16; // Bolt circle diameter for mounting screws

    color("gold") { // Brass finish styling
        difference() {
            union() {
                // Main circular flange plate
                cylinder(h=flange_h, d=flange_d, $fn=48);
                // Raised cylindrical center sleeve
                cylinder(h=body_h, d=body_d, $fn=48);
            }

            // 1. Center clearance bore hole for the 8mm rod
            translate([0, 0, -1])
                cylinder(h=body_h+2, d=8, $fn=32);

            // 2. 4x Mounting bolt screw holes on the flange (M3 hardware)
            for (a = [0 : 90 : 270]) {
                rotate([0, 0, a])
                translate([hole_pitch_d/2, 0, -1])
                    cylinder(h=flange_h+2, d=3.4, $fn=16);
            }
        }
    }
}
