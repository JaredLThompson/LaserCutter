/*
 * Owned hardware configuration:
 * STARTNOW red SET A1 A2 A3 A4, 63.5 mm A3 variant.
 * A1-A4 are shown here as a parts overview, not an optical layout.
 */
include <laser_parts.scad>

$fn = 64;
startnow_head_set_preview(focal_length=63.5, colors=true);

$vpr = [67, 0, 28];
$vpt = [0, 0, 85];
$vpd = 760;
