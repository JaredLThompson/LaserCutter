// =======================================================================
// UNIFIED DUAL-HULL PARAMETRIC 3D TIMING BELT MODULE (YOUR INSANELY SMART METHOD)
// =======================================================================

$fn=64;


// =======================================================================
// FIXED 3D TIMING BELT MODULE (VERTICAL STANDING WALLS)
// =======================================================================

$fn=64;

module gt2_belt(p1=[0,0,0], p2=[100,0,0], r1=6.37, r2=6.37, width=6, thickness=1.5) {
    vec = p2 - p1;
    dist = norm(vec);
    
    if (dist > 0.001) {
        translate(p1)
        rotate([0, 0, atan2(vec[1], vec[0])])              // Yaw rotation (Z-axis)
        rotate([0, -atan2(vec[2], norm([vec[0], vec[1]])), 0]) // Pitch rotation (Y-axis)
        rotate([90, 0, 0])                                 // FIXED: Rolls the belt 90° so it stands upright!
        {
            color("DimGray", 0.8)
            linear_extrude(height=width, center=true) {
                difference() {
                    // Outer rubber band hull boundary
                    hull() {
                        circle(r=r1 + thickness);
                        translate([dist, 0]) circle(r=r2 + thickness);
                    }
                    // Inner tooth clearance track hull subtraction
                    hull() {
                        circle(r=r1);
                        translate([dist, 0]) circle(r=r2);
                    }
                } 
            } 
        } 
    } 
}




// =======================================================================
// TESTING EXAMPLES (Both render completely solid now!)
// =======================================================================

// Example 1: Classic horizontal mismatched pulleys
gt2_belt(p1=[0,0,0], p2=[100,0,0], r1=19.1, r2=5.1, width=6);

// Example 2: Your actual 3D sloped stepper motor path layout!
translate([0, 50, 0])
    gt2_belt(p1=[0,11,17], p2=[39,11,29], r1=19.1, r2=5.1, width=6);
