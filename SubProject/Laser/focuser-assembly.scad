// CO2 Laser Focuser Assembly
// Simplified but dimensionally accurate
// Origin at top mounting surface (bolts to adapter plate)
// Assembly hangs downward (-Z)

$fn=48;


focuser_assembly();


module focuser_assembly() {
  rotate([0,0,90])
  union(){
    translate([0,0,22.5])mirror_block();
    
    // Lens tube starts inside the mirror block bore and extends down
    // Block bottom is at Z=-35, tube top inserts ~10mm into block
    translate([0, 0, 0])
        lens_tube();
    
    // Nozzle attaches at bottom of lens tube
    // Tube goes from Z=-25 to Z=-25-90 = Z=-115
    translate([0, 0, -90])rotate([0,0,-90])
        nozzle_assembly();
  }
}

module mirror_block() {

  color("crimson")
  translate([0,0,0])
    difference(){
      cube([45,37,45], center=true);
      translate([0,-13,27])
          rotate([45,0,0])cube([50,75,50], center=true);
       translate([0,-30,0])rotate([-90,0,0])cylinder(d=20,h=50);
       translate([0,0,-30])cylinder(d=20,h=50);
       
    }//difference
  
  
  translate([0,-3,7])rotate([45,0,0])
    difference(){
      union(){
        color("crimson")cube([45,52,6], center=true);
        
        color("Gold") 
          translate([0, -20, 12])
           rotate([180,0,0])
             thumbscrew();  
      
        color("Gold") 
          translate([-15, 20, 12])
            rotate([180,0,0])
              thumbscrew();  
      
        color("Gold") 
          translate([15, 20, 12])
            rotate([180,0,0])
              thumbscrew();  
              

      } //union
                
    translate([0,0,-4])
      cylinder(d=27,h=8);
  }
  
  
  // A3 Mirror
  translate([0,-2,6])rotate([45,0,0])
  color("Gold")
    translate([0,0,0])
      cylinder(d=25,h=2);

}

module mirror_block_broken() {
    // Wedge-shaped block with 45-degree top face for mirror adjustment
    // Beam enters horizontally from back (Y+), mirror reflects it down (-Z)
    // Thumbscrews on the angled top face adjust the mirror
    // Flat bottom mates to the lens tube bore
    // Mounting flange at Z=0 (plate mounting surface)
    
    color("DimGray")
    difference() {
        // Wedge body: flat bottom, angled top
        // Back is taller (beam entry side), front is shorter
        translate([-20, -17, 0])
        polyhedron(
            points=[
                // Bottom face (flat at Z=-35)
                [0, 0, -35],    // 0: front-left-bottom
                [40, 0, -35],   // 1: front-right-bottom
                [40, 34, -35],  // 2: back-right-bottom
                [0, 34, -35],   // 3: back-left-bottom
                // Top face (angled: Z=0 at back, Z=-15 at front)
                [0, 0, -15],    // 4: front-left-top
                [40, 0, -15],   // 5: front-right-top
                [40, 34, 0],    // 6: back-right-top
                [0, 34, 0]      // 7: back-left-top
            ],
            faces=[
                [0,1,2,3],   // bottom (flat)
                [7,6,5,4],   // top (angled)
                [0,4,5,1],   // front
                [2,6,7,3],   // back
                [0,3,7,4],   // left
                [1,5,6,2]    // right
            ]
        );
        
        // 24mm bore through bottom for lens tube
        translate([0, 0, -36])
            cylinder(d=24.2, h=20);
        
        // Beam entry hole from back (horizontal)
        translate([0, 18, -22])
            rotate([90, 0, 0])
                cylinder(d=20, h=15);
    }
    
    // Brass thumbscrews on the angled top face
    // Perpendicular to the 45-degree slope
    color("Gold") {
        translate([-12, 5, -8])
            rotate([45, 0, 0])
                thumbscrew();
        translate([12, 5, -8])
            rotate([45, 0, 0])
                thumbscrew();
        translate([0, 17, -2])
            rotate([45, 0, 0])
                thumbscrew();
    }
}

module thumbscrew() {
    cylinder(d=10, h=4);
    translate([0, 0, 4])
        cylinder(d=6, h=8);
}

module lens_tube() {
    // 24mm OD, 90mm long
    // Origin at top of tube, extends downward
    color("crimson")
    translate([0, 0, -90])
    difference() {
        cylinder(d=24, h=90);
        translate([0, 0, -1])
            cylinder(d=19, h=92);
    }
}

module nozzle_assembly() {
    // Origin at top where it meets lens tube
    // Lock ring + cone extend downward
    
    // Lock ring (6mm tall, directly below tube)
    color("DimGray")
    translate([0, 0, -6])
    difference() {
        cylinder(d=26, h=6);
        translate([0, 0, -1])
            cylinder(d=19, h=8);
    }
    
    // Cone section below lock ring
    // 36mm tall, 22mm at top tapering to 5mm at tip
    color("crimson")
    translate([0, 0, -42])
    difference() {
        union() {
            translate([0, 0, 24])
                cylinder(d=22, h=12);
            cylinder(d1=5, d2=22, h=24);
        }
        translate([0, 0, -1])
            cylinder(d=2.5, h=38);
    }
    
    // Air assist fitting on side of cone
    color("DimGray")
    translate([13, 0, -18])
    rotate([0, 90, 0])
        cylinder(d=10, h=12);
    color("RoyalBlue")
    translate([23, 0, -18])
    rotate([0, 90, 0])
        cylinder(d=12, h=3);
}


