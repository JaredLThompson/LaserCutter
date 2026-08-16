$fn = 64; // High resolution for functional printed parts

// Render the solid flat-belt clamp block laying flat on its face
y_flat_belt_gantry_clamp();
//belt_corner_chamfer();


module y_flat_belt_gantry_clamp() {

    // Solid block dimensions scaled so the part lays flat on its face
    block_w = 42; // Wide along X to bridge the rail and keep screws on the flanks
    block_d = 20; // Depth along Y
    block_h = 7; // Total thickness height (clamping surface thickness)
    
    // Extrusion Rail Mounting Specs (M5 Hardware)
    m5_clear_dia = 5.4;   
    m5_head_dia = 9.5;    
    m5_head_depth = 5.0; // Pocket depth to submerge the bolt head completely
    
    // FLAT BELT SLOT SPECS (Horizontal ribbon orientation)
    belt_w = 7.0;       // Width along X to comfortably clear a 6mm wide flat belt
    belt_groove_h = 2.5; // Shallow groove cut from the top face down into the block
    
    translate([0,-block_h,block_d/2])rotate([-90,0,0])union(){
    
    // Flip 90 degrees on its face so the flat grooved track faces upright 
    // and the M5 mounting screws bolt vertically down into the 2020 channel
        color("crimson") difference() {
            // 1. MAIN SOLID BRACKET BODY (Laying wide and flat)
            translate([0, 0, block_h/2])
                cube([block_w, block_d, block_h], center=true);
                
            // 2. VERTICAL MOUNTING SLOTS (Safely isolated on the left and right flanks)
            for (x_offset = [-14, 14]) {
                translate([x_offset, 0, 0]) {
                    hull() {
                        translate([-1.5, 0, -1]) cylinder(d=m5_clear_dia, h=block_h + 2);
                        translate([ 1.5, 0, -1]) cylinder(d=m5_clear_dia, h=block_h + 2);
                    }
                }
            }
            
            // 3. HORIZONTAL FLAT BELT GROOVE (Runs front-to-back along the Y-axis)
            translate([0, 0, block_h - belt_groove_h/2 + 0.1]) 
                cube([belt_w, block_d + 2, belt_groove_h], center=true);
            
            // Rounded notch for belt
            translate([0,0,-belt_groove_h])rotate([0,0,0])belt_corner_chamfer();

            // 4. CALL THE WASHBOARD TEETH SUBTRACTION HERE
            // Shifted slightly along Z to cut right into the floor of the groove
            //translate([0, 0, 0.05]) 
                //washboard(block_d, block_h, belt_groove_h, belt_w);
        }
    } //union
}

module belt_corner_chamfer(belt_width=7){
 difference(){
   cube([belt_width,belt_width*4,belt_width*4], center=true);
   hull() {
   translate([0,-belt_width/2,belt_width/2])rotate([0,90,0])cylinder(d=belt_width, h=belt_width+2, center=true);
   translate([0,belt_width*4,belt_width/2])rotate([0,90,0])cylinder(d=belt_width, h=belt_width+2, center=true);
   translate([0,-belt_width/2,-belt_width*4])rotate([0,90,0])cylinder(d=belt_width, h=belt_width+2, center=true);
   }
 }
}

// Added parameters to the module so it inherits the master dimensions cleanly
module washboard(block_d, block_h, belt_groove_h, belt_w) {
    // 2mm pitch pattern matching standard GT2 timing belt profiles
    for (y_tooth = [-block_d/2 : 2 : block_d/2]) {
        translate([0, y_tooth, block_h - belt_groove_h])
            rotate([0, 90, 0])
                cylinder(d=1.2, h=belt_w + 0.2, center=true, $fn=4); // Diamond washboard ridges
    }
}
