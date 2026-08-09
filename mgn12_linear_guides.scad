/* MGN12 rail with C and H carriage examples. */
use <laser_parts.scad>

$fn = 48;

// A 300 mm guide with the longer MGN12H carriage.
translate([0,-25,0])
    mgn12_assembly(length=300,carriage_type="H",positions=[-70]);

// A 200 mm guide with the compact MGN12C carriage.
translate([0,25,0])
    mgn12_assembly(length=200,carriage_type="C",positions=[35]);

$vpr = [58,0,32];
$vpt = [0,0,5];
$vpd = 430;
