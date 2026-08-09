/* Standalone preview for the owned TEN-HIGH-style 800 mm, 50 W CO2 tube. */

use <laser_parts.scad>

$fn=64;

co2_laser_tube_50w(length=800,diameter=50,
                    show_labels=true,show_wires=true);

$vpr=[68,0,22];
$vpt=[0,0,0];
$vpd=1050;
