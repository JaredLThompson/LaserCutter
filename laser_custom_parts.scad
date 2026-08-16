/*
 * laser_custom_parts.scad — fabrication-only output
 *
 * Select one custom component and render/export it without the cutter
 * assembly or purchased hardware. Add finalized fabricated components to the
 * selector as their reusable modules are completed in laser_parts.scad.
 */

use <laser_parts.scad>

$fn=48;

/* [Fabrication output] */
custom_part="mgn12h_2040_gantry_plate"; // [mgn12h_2040_gantry_plate,x_axis_nema17_2040_motor_mount,enclosure_hinge_fixed_leaf,enclosure_hinge_moving_leaf,enclosure_latch_base,enclosure_latch_lever,enclosure_latch_keeper,external_2020_panel_clip]
part_quantity=1;                         // [1:1:4]
part_spacing=90;                         // [70:5:150]
show_hardware=false;

/* [MGN12H to 2040 plate] */
plate_size=[76,58];
plate_thickness=6;                       // [4:1:10]
carriage_hole_pitch=[20,20];
gantry_bolt_spacing=52;                  // [40:1:60]

/* [X-axis NEMA 17 motor mount] */
x_motor_plate_size=[90,80];
x_motor_plate_thickness=6;               // [4:1:10]
x_motor_pitch=31;
x_motor_gantry_slot_y=-38;
x_motor_plate_center_x=-25;
x_motor_gantry_bolt_x=[-50,-20];

module selected_custom_part() {
    if (custom_part=="mgn12h_2040_gantry_plate")
        mgn12h_2040_gantry_plate(
            size=plate_size,
            thickness=plate_thickness,
            carriage_pitch=carriage_hole_pitch,
            gantry_bolt_spacing=gantry_bolt_spacing,
            show_hardware=show_hardware);
    else if (custom_part=="x_axis_nema17_2040_motor_mount")
        x_axis_nema17_2040_motor_mount(
            size=x_motor_plate_size,
            thickness=x_motor_plate_thickness,
            motor_pitch=x_motor_pitch,
            gantry_slot_y=x_motor_gantry_slot_y,
            plate_center_x=x_motor_plate_center_x,
            gantry_bolt_x=x_motor_gantry_bolt_x,
            show_hardware=show_hardware);
    else if (custom_part=="enclosure_hinge_fixed_leaf")
        enclosure_hinge_leaf(moving=false);
    else if (custom_part=="enclosure_hinge_moving_leaf")
        enclosure_hinge_leaf(moving=true);
    else if (custom_part=="enclosure_latch_base")
        enclosure_cam_latch_base();
    else if (custom_part=="enclosure_latch_lever")
        enclosure_cam_latch_lever();
    else if (custom_part=="enclosure_latch_keeper")
        translate([0,0,4]) enclosure_cam_latch_keeper();
    else if (custom_part=="external_2020_panel_clip")
        external_2020_panel_clip(show_hardware=show_hardware);
}

// Parts are laid flat on Z=0 and centered as a group for preview or nesting.
for (i=[0:part_quantity-1])
    translate([(i-(part_quantity-1)/2)*part_spacing,0,0])
        selected_custom_part();

$vpr=[0,0,0];
$vpt=[0,0,0];
$vpd=max(180,part_quantity*part_spacing+80);
