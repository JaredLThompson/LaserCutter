// Ruthex RX-M3x5x4 heat-set insert features.
// Manufacturer package dimensions:
//   insert: M3, 5.0 mm maximum OD, 4.0 mm long
//   printed pocket: 4.4 mm diameter, 5.0 mm minimum depth
//   minimum radial plastic wall: 1.3 mm

$fn = 48;

ruthex_rx_m3x5x4();

module ruthex_m3_boss(top_z=0, boss_d=10, boss_h=6) {
    translate([0, 0, top_z - boss_h / 2])
        cylinder(d=boss_d, h=boss_h, center=true);
}

module ruthex_m3_pocket(top_z=0, hole_d=4.4, boss_h=6) {
    // Ruthex permits a blind or through hole.  Use a through pocket here so
    // the feature is visible from both faces and an M3 screw cannot bottom
    // against a hidden plastic floor beneath the insert.
    translate([0, 0, top_z - boss_h / 2])
        cylinder(d=hole_d, h=boss_h + 0.2, center=true);
}

// Visual model of a Ruthex RX-M3x5x4 insert in its installed orientation.
// The top rim is flush with top_z and the 4 mm body projects into the part.
module ruthex_rx_m3x5x4(top_z=0,
                        length=4,
                        max_d=5.0,
                        pilot_d=4.25,
                        bore_d=2.5) {
    band_h = 1.35;
    waist_h = length - 2 * band_h;

    color([0.82, 0.52, 0.08])
        translate([0, 0, top_z - length])
            difference() {
                union() {
                    // Stepped core follows the package silhouette: a smaller
                    // lead-in, a central waist, and two full-diameter bands.
                    cylinder(d=pilot_d, h=length);
                    translate([0, 0, 0.15])
                        cylinder(d=max_d, h=band_h);
                    translate([0, 0, band_h])
                        cylinder(d=4.45, h=waist_h);
                    translate([0, 0, length - band_h - 0.15])
                        cylinder(d=max_d, h=band_h + 0.15);

                    // Opposing helical knurl bands make this read as a
                    // heat-set insert instead of a smooth metal cylinder.
                    ruthex_knurl_band(z0=0.20, h=band_h - 0.10,
                                      diameter=max_d, twist=24);
                    ruthex_knurl_band(z0=length - band_h - 0.05,
                                      h=band_h,
                                      diameter=max_d, twist=-24);
                }

                // Visible minor-diameter bore. The actual M3 thread is
                // intentionally represented by shallow internal rings below.
                translate([0, 0, -0.1])
                    cylinder(d=bore_d, h=length + 0.2);

                for (z = [0.55 : 0.65 : length - 0.35])
                    translate([0, 0, z])
                        rotate_extrude()
                            translate([bore_d / 2 - 0.08, 0])
                                circle(r=0.14, $fn=12);
            }
}

module ruthex_knurl_band(z0, h, diameter, twist) {
    for (a = [0 : 30 : 330])
        rotate([0, 0, a])
            translate([diameter / 2 - 0.20, -0.20, z0])
                linear_extrude(height=h, twist=twist, slices=5)
                    square([0.48, 0.40]);
}
