// ---------------------------------------------------------------------------
// Metric T-slot aluminum extrusion
// Nominal cross sections with 6 mm-series slots. Exact internal webs vary by
// manufacturer; slot_width and center_bore are exposed for matching stock.

$fn=36;

ALUMINUM_CLEAR = [0.72,0.74,0.76];
ALUMINUM_BLACK = [0.08,0.085,0.09];

module _aluminum_extrusion_slot_2d(slot_width=6, cavity_width=11,
                                   cavity_depth=5, neck_depth=3) {
    // Slot opens toward +Y. Its cavity creates the familiar inverted T.
    union() {
        translate([-slot_width/2,-0.01])
            square([slot_width,neck_depth+0.02]);
        translate([-cavity_width/2,-cavity_depth])
            square([cavity_width,cavity_depth+0.01]);
    }
}

module _aluminum_2020_profile_2d(slot_width=6, cavity_width=11,
                                 center_bore=5) {
    // Dimensioned profile supplied from the user's existing extrusion model.
    // slot_width/cavity_width remain in the public API for compatibility;
    // this known stock uses a measured 5.26 mm opening geometry.
    difference() {
        square([20,20],center=true);
        square([17,17],center=true);
        square([40,5.26],center=true);
        rotate([0,0,90]) square([40,5.26],center=true);
    }

    difference() {
        union() {
            square([7.32,7.32],center=true);
            rotate([0,0,45]) square([1.5,25],center=true);
            rotate([0,0,-45]) square([1.5,25],center=true);
        }
        circle(d=center_bore,$fn=16);
    }

    for (x=[-7.9975,7.9975], y=[-7.9975,7.9975])
        translate([x,y]) square([4.005,4.005],center=true);
}

module _aluminum_2040_profile_2d(slot_width=6, cavity_width=11,
                                 center_bore=5) {
    union() {
        // A 2040 is two connected 20 mm cells. Their touching face lips and
        // webs merge into the central wall while retaining both core bores.
        for (x=[-10,10]) translate([x,0])
            _aluminum_2020_profile_2d(slot_width=slot_width,
                                      cavity_width=cavity_width,
                                      center_bore=center_bore);
    }
}

/*
 * 20 x 20 mm T-slot extrusion. Cross section is centered on X/Y; length is Z.
 * center=true places the midpoint at Z=0, otherwise the bottom is at Z=0.
 */
module aluminum_extrusion_2020(length=100, center=false, black=false,
                               slot_width=6, center_bore=5) {
    color(black ? ALUMINUM_BLACK : ALUMINUM_CLEAR)
        linear_extrude(height=length,center=center,convexity=10)
            _aluminum_2020_profile_2d(
                slot_width=slot_width,center_bore=center_bore);
}

/*
 * 20 x 40 mm T-slot extrusion. The 40 mm dimension follows X and length is Z.
 */
module aluminum_extrusion_2040(length=100, center=false, black=false,
                               slot_width=6, center_bore=5) {
    color(black ? ALUMINUM_BLACK : ALUMINUM_CLEAR)
        linear_extrude(height=length,center=center,convexity=10)
            _aluminum_2040_profile_2d(
                slot_width=slot_width,center_bore=center_bore);
}




aluminum_extrusion_2020(length=100,center=true,black=black);