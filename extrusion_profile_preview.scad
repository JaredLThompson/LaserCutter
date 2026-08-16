/* Connected 20-series extrusion cross-section inspection. */
use <laser_parts.scad>

$fn=48;

// Thin slices make the internal topology easy to inspect in Preview/Render.
translate([-28,0,0]) aluminum_extrusion_2020(length=4,black=false);
translate([ 18,0,0]) aluminum_extrusion_2040(length=4,black=false);
