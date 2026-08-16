// Parametric Befenybay-style R18 10x10 mm closed drag-chain model
// All linear dimensions are millimeters.

/* [Simulation Controls] */
carriage_x = 200;             // [0:1:400]
mirror_chain_x = true;        // Mounts right/bend left for this laser layout
show_connectors = true;
show_hinge_pins = true;

/* [Chain Specifications] */
link_pitch = 14.5;            // Pivot-to-pivot pitch
external_width = 18.0;
external_height = 15.0;
internal_width = 10.0;
internal_height = 10.0;
bend_radius = 18.0;           // Centerline bend radius
total_links = 32;
hinge_pin_diameter = 3.0;
mount_hole_diameter = 4.2;    // M4 clearance

/* [Display] */
link_color = [0.16, 0.17, 0.18];
fixed_connector_color = [0.27, 0.51, 0.71];
moving_connector_color = [0.70, 0.13, 0.13];
pin_color = [0.50, 0.51, 0.52];

/* [Hidden] */
$fn = 40;

// Public assembly module. Explicit parameters make this file safe to import
// with `use` without relying on its standalone Customizer variables.
module parametric_drag_chain(carriage=200, links=32, mirrored=true,
                             pitch=14.5, radius=18,
                             outer_width=18, outer_height=15,
                             inner_width=10, inner_height=10,
                             show_ends=true, show_pins=true) {
    path_length = links * pitch;
    arc_len = PI * radius;
    maximum_travel = path_length - arc_len;
    bounded_carriage = min(max(carriage, 0), maximum_travel);

    assert(outer_width > inner_width,
           "outer_width must exceed inner_width");
    assert(outer_height > inner_height,
           "outer_height must exceed inner_height");
    assert(pitch > 0 && radius > 0 && links >= 3,
           "Pitch, bend radius, and link count must define a usable chain");
    assert(maximum_travel >= 0,
           "The selected chain is too short for the requested bend radius");

    echo(str("Drag-chain pitch length: ", path_length, " mm"));
    echo(str("Maximum carriage travel for this chain: ",
             maximum_travel, " mm"));
    if (carriage != bounded_carriage)
        echo(str("WARNING: drag-chain carriage was clamped from ", carriage,
                 " to ", bounded_carriage, " mm"));

    if (mirrored)
        mirror([1, 0, 0])
            draw_befenybay_drag_chain(
                carriage=bounded_carriage, links=links,
                pitch=pitch, radius=radius,
                outer_width=outer_width, outer_height=outer_height,
                inner_width=inner_width, inner_height=inner_height,
                show_ends=show_ends, show_pins=show_pins);
    else
        draw_befenybay_drag_chain(
            carriage=bounded_carriage, links=links,
            pitch=pitch, radius=radius,
            outer_width=outer_width, outer_height=outer_height,
            inner_width=inner_width, inner_height=inner_height,
            show_ends=show_ends, show_pins=show_pins);
}

// Standalone preview. `use <parametric_drag_chain.scad>` ignores this call.
parametric_drag_chain(carriage=carriage_x,
                      links=total_links,
                      mirrored=mirror_chain_x,
                      pitch=link_pitch,
                      radius=bend_radius,
                      outer_width=external_width,
                      outer_height=external_height,
                      inner_width=internal_width,
                      inner_height=internal_height,
                      show_ends=show_connectors,
                      show_pins=show_hinge_pins);


// Return [[x,y,z], rotation_about_Y] for distance d along the chain centerline.
function drag_chain_path_state(d, carriage, radius, path_length) =
    let(
        arc_len = PI * radius,
        bend_x = (path_length + carriage - arc_len) / 2,
        arc_d = d - bend_x,
        top_d = d - bend_x - arc_len,
        angle = arc_d / radius * 180 / PI
    )
    d <= bend_x
        ? [[d, 0, 0], 0]
        : d <= bend_x + arc_len
            ? [[bend_x + radius * sin(angle),
                0,
                radius - radius * cos(angle)],
               -angle]
            : [[bend_x - top_d, 0, 2 * radius], 180];


module place_on_drag_chain_path(d, carriage, radius, path_length) {
    state = drag_chain_path_state(d, carriage, radius, path_length);
    translate(state[0])
        rotate([0, state[1], 0])
            children();
}


module draw_befenybay_drag_chain(carriage=200, links=32,
                                 pitch=14.5, radius=18,
                                 outer_width=18, outer_height=15,
                                 inner_width=10, inner_height=10,
                                 show_ends=true, show_pins=true) {
    path_length = links * pitch;

    // Sample link centers at half-pitch intervals. The fixed and moving
    // connector pivots remain exactly at path distances 0 and L.
    for (i = [0 : links - 1])
        place_on_drag_chain_path((i + 0.5) * pitch,
                                 carriage, radius, path_length)
            befenybay_r18_closed_link(
                index=i, pitch=pitch,
                outer_width=outer_width, outer_height=outer_height,
                inner_width=inner_width, inner_height=inner_height,
                show_pin=show_pins);

    if (show_ends) {
        place_on_drag_chain_path(0, carriage, radius, path_length)
            befenybay_end_connector(
                is_moving=false, pitch=pitch,
                outer_width=outer_width, outer_height=outer_height,
                inner_width=inner_width, inner_height=inner_height);
        place_on_drag_chain_path(path_length, carriage,
                                 radius, path_length)
            befenybay_end_connector(
                is_moving=true, pitch=pitch,
                outer_width=outer_width, outer_height=outer_height,
                inner_width=inner_width, inner_height=inner_height);
    }
}


// Closed visual link with rounded side plates, upper/lower cable-retaining
// bridges, true hinge bores, and alternating plate nesting to avoid coplanar
// overlap between adjacent links.
module befenybay_r18_closed_link(index=0, pitch=14.5,
                                 outer_width=18, outer_height=15,
                                 inner_width=10, inner_height=10,
                                 pin_diameter=3, show_pin=true) {
    link_pitch = pitch;
    external_width = outer_width;
    external_height = outer_height;
    internal_width = inner_width;
    internal_height = inner_height;
    hinge_pin_diameter = pin_diameter;
    bridge_t = (external_height - internal_height) / 2;
    side_t = (external_width - internal_width) / 2;
    nesting_offset = index % 2 == 0 ? 0 : 0.45;
    plate_y = external_width / 2 - side_t / 2 - nesting_offset;
    bridge_width = 2 * (plate_y + side_t / 2);
    body_length = link_pitch + 2.2;

    color(link_color)
        difference() {
            union() {
                // Rounded side links pivot around the centers at each end.
                for (side = [-1, 1])
                    hull()
                        for (x = [-link_pitch / 2, link_pitch / 2])
                            translate([x, side * plate_y, 0])
                                rotate([90, 0, 0])
                                    cylinder(d=external_height,
                                             h=side_t, center=true);

                // Closed upper and lower bridges retain the cable bundle.
                for (z = [-1, 1])
                    translate([0, 0,
                               z * (external_height / 2 - bridge_t / 2)])
                        cube([body_length, bridge_width, bridge_t],
                             center=true);
            }

            // Preserve a clear 10x10 mm cable window through each link.
            cube([body_length + 2, internal_width, internal_height],
                 center=true);

            // Real hinge bores through both rounded end bosses.
            for (x = [-link_pitch / 2, link_pitch / 2])
                translate([x, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(d=hinge_pin_diameter + 0.35,
                                 h=external_width + 2, center=true);
        }

    if (show_pin)
        color(pin_color)
            translate([-link_pitch / 2, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d=hinge_pin_diameter,
                             h=external_width + 0.6, center=true);
}


module befenybay_end_connector(is_moving=false, pitch=14.5,
                               outer_width=18, outer_height=15,
                               inner_width=10, inner_height=10,
                               mount_hole=4.2) {
    link_pitch = pitch;
    external_width = outer_width;
    external_height = outer_height;
    internal_width = inner_width;
    internal_height = inner_height;
    mount_hole_diameter = mount_hole;
    mount_length = 20;
    mount_width = 26;
    mount_tab_t = 3;
    shell_t = (external_width - internal_width) / 2;
    // The upper endpoint's path frame is rotated 180 degrees. Mirror its
    // connector locally so the sleeve still points into the chain while the
    // mounting ear points away from it in global X.
    chain_local_direction = is_moving ? -1 : 1;
    mount_local_direction = -chain_local_direction;
    mount_tab_center_x = mount_local_direction * mount_length / 2;
    // The moving end is intentionally inverted relative to its sleeve so its
    // outward-facing mounting tab sits beneath the upper chain run.
    tab_local_z = is_moving
        ? external_height / 2 - mount_tab_t / 2
        : -external_height / 2 + mount_tab_t / 2;

    color(is_moving ? moving_connector_color : fixed_connector_color)
        difference() {
            union() {
                // Short chain-interface sleeve from the endpoint pivot toward
                // the first/last link center.
                translate([chain_local_direction * link_pitch / 4, 0, 0])
                    difference() {
                        cube([link_pitch / 2, external_width,
                              external_height], center=true);
                        cube([link_pitch / 2 + 2, internal_width,
                              internal_height], center=true);
                    }

                // Flat machine-mounting ear extends away from the chain.
                translate([mount_tab_center_x, 0, tab_local_z])
                    cube([mount_length, mount_width, mount_tab_t],
                         center=true);

                // Reinforcing cheeks connect the sleeve to the wider tab.
                for (side = [-1, 1])
                    hull() {
                        translate([0,
                                   side * (external_width / 2 - shell_t / 2),
                                   0])
                            cube([3, shell_t, external_height], center=true);
                        translate([mount_tab_center_x,
                                   side * (mount_width / 2 - shell_t / 2),
                                   tab_local_z])
                            cube([mount_length, shell_t, mount_tab_t],
                                 center=true);
                    }
            }

            // M4 mounting slot permits approximately 6 mm of adjustment.
            hull()
                for (x = [mount_tab_center_x - 3,
                          mount_tab_center_x + 3])
                    translate([x, 0, tab_local_z])
                        cylinder(d=mount_hole_diameter,
                                 h=mount_tab_t + 2, center=true);

            // The moving connector is installed inverted in this machine.
            // Counterbore its globally upper face for an M4 FHCS so the head
            // remains flush and cannot catch cables or nearby structure.
            if (is_moving)
                hull()
                    for (x = [mount_tab_center_x - 3,
                              mount_tab_center_x + 3])
                        translate([x, 0,
                                   tab_local_z - mount_tab_t / 2 - 0.01])
                            cylinder(d1=8.2, d2=mount_hole_diameter,
                                     h=2.2, center=false);
        }
}
