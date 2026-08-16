// Laser Cutter 2026 - printable-parts selector and print inventory
//
// Choose one item in the OpenSCAD Customizer, render (F6), then export STL.
// `inventory` shows one representative of every unique printed part.
// Hardware, motors, bearings, pulleys, extrusion and CNC/sheet parts are
// intentionally excluded.

use <focuser-assembly.scad>;
use <MGN12H-Adapter-Plate.scad>;
use <x_axis_idler.scad>;
use <x_axis_drive.scad>;
use <mgn12h_2020_adapter.scad>;
use <y_axis_idler.scad>;
use <nema17_motor_plate.scad>;
use <x_drag_chain_carriage_bracket.scad>;
use <x_drag_chain_fixed_bracket.scad>;
use <y_drag_chain_brackets.scad>;

/* [Part selection] */
part = "x_drive_block"; // [inventory:Inventory - one of each, x_chain_brackets:X-chain brackets - both, x_chain_fixed_bracket:X-chain fixed motor bracket x1, x_chain_carriage_bracket:X-chain moving carriage bracket x1, y_chain_moving_bracket:Y-chain moving bracket x1, y_chain_fixed_bracket:Y-chain fixed bracket x1, focuser_mirror_block:Focuser mirror block x1, focuser_thumbscrew:Focuser thumbscrew x1, a4_adapter:A4 carriage adapter x1, a4_belt_clamp:A4 belt clamp x1, a4_tension_block:A4 tension block x1, x_idler_block:X idler block x1, x_drive_block:X drive block x1, y_rail_adapter:Y rail-to-2020 adapter x2, y_idler_saddle:Y idler fixed saddle x2, y_idler_fork:Y idler sliding fork x2, y_motor_plate:Y motor plate x1]

/* [Preview] */
show_quantity_echo = true;
inventory_spacing_x = 105; // [70:5:160]
inventory_spacing_y = 105; // [70:5:160]
$fn = 64;

if (show_quantity_echo)
    print_inventory_echo();

if (part == "inventory")
    inventory_layout();
else
    printable_part(part);


// Central selector. Keeping every export behind this module makes the file
// useful from the GUI and from command-line STL batch jobs using `-D part=`.
module printable_part(name) {
    if (name == "x_chain_brackets") {
        x_drag_chain_fixed_bracket(show_hardware=false);
        translate([115, 0, 0])
            x_drag_chain_carriage_bracket(show_hardware=false);
    }
    else if (name == "focuser_mirror_block") mirror_block();
    else if (name == "focuser_thumbscrew") thumbscrew();

    else if (name == "a4_adapter") MGN12HAdapterPlate();
    else if (name == "a4_belt_clamp") A4BeltClamp();
    else if (name == "a4_tension_block") A4BeltTensionBlock();

    else if (name == "x_idler_block") x_axis_idler_block();
    else if (name == "x_drive_block") x_axis_drive_block();
    else if (name == "y_rail_adapter") mgn12h_to_2020_adapter();
    else if (name == "y_idler_saddle") y_idler_fixed_saddle();
    else if (name == "y_idler_fork") y_idler_sliding_fork();
    else if (name == "y_motor_plate") nema_17_mount_plate();

    else if (name == "x_chain_carriage_bracket")
        x_drag_chain_carriage_bracket(show_hardware=false);
    else if (name == "x_chain_fixed_bracket")
        x_drag_chain_fixed_bracket(show_hardware=false);
    else if (name == "y_chain_moving_bracket")
        y_drag_chain_moving_bracket(show_hardware=false,
                                    shelf_top_z=-60.5,
                                    chain_x=0,
                                    chain_y=10);
    else if (name == "y_chain_fixed_bracket")
        y_drag_chain_fixed_bracket(show_hardware=false,
                                   shelf_top_z=-66.5,
                                   chain_x=-32,
                                   chain_y=10);
    else
        echo(str("Unknown printable part selector: ", name));
}


// One-per-design overview. This is an inventory view, not a single printer
// build plate: select individual parts above for STL export and slicing.
module inventory_layout() {
    names = [
        "focuser_mirror_block", "focuser_thumbscrew", "a4_adapter", "a4_belt_clamp",
        "a4_tension_block", "x_idler_block", "x_drive_block", "y_rail_adapter",
        "y_idler_saddle", "y_idler_fork", "y_motor_plate",
        "x_chain_carriage_bracket", "x_chain_fixed_bracket",
        "y_chain_moving_bracket", "y_chain_fixed_bracket"
    ];
    columns = 4;

    for (i = [0 : len(names)-1])
        translate([(i % columns) * inventory_spacing_x,
                   -floor(i / columns) * inventory_spacing_y,
                   0])
            printable_part(names[i]);
}


module print_inventory_echo() {
    echo("=== LASER CUTTER 2026 PRINT INVENTORY ===");
    echo("Focuser: mirror block x1, thumbscrew x1");
    echo("A4 carriage: adapter x1, belt clamp x1, tension block x1");
    echo("X motion: idler block x1, drive block x1");
    echo("Y motion: rail adapter x2, idler saddle x2, idler fork x2, motor plate x1");
    echo("Cable-chain supports: X carriage/fixed x1 each, Y moving/fixed x1 each");
    echo("Purchased/excluded: tube mounts, mirror mounts, cable chains and cable-chain ends");
    echo("Also excluded: fasteners, bearings, pulleys, motors, extrusion, panels, and CNC A1 pedestal plates");
}
