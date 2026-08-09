/* 2020 and 2040 metric T-slot extrusion preview. */
use <laser_parts.scad>

$fn = 48;

// Upright 2020 sample.
translate([-35,0,0])
    aluminum_extrusion_2020(length=120);

// Upright 2040 sample, shown in black anodized finish.
translate([30,0,0])
    aluminum_extrusion_2040(length=120,black=true);

$vpr = [68,0,28];
$vpt = [0,0,58];
$vpd = 360;
