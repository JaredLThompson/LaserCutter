// A4 Adapter Plate
// Defaults to MGN15H Hole Spacing
// For reference: 
//    X = width (left-to-right)
//    Y = depth  (front-to-back)
//    Z = height (vertical up-and-down)

use <shcs.scad>;
use <fhcs.scad>;


$fn=64;
corner_r=4;
plateWidth = 130;
plateDepth =56;
plateHeight = 8;
focuserXOffset = 24; //9mm + 15mm radius
mgn15XOffset = 75;
  

A4AdapterPlateAssembly();


module A4AdapterPlateAssembly()
{
A4AdapterPlate();

translate([mgn15XOffset,plateDepth-4,6])
  A4BeltClampAssembly();

  
translate([mgn15XOffset,-30,0])
  A4BeltTensionBlockAssembly();
  

}

module A4BeltClampAssembly() {
  A4BeltClamp();
  translate([-9.5,0,2])
    rotate([180,0,0])m3_shcs(6);
  translate([9.5,0,2])
    rotate([180,0,0])m3_shcs(6);
}

module A4BeltClamp(){
  color("black")
    difference(){
      hull(){
        translate([-26/2+4,0,0])cylinder(r=4,h=1.5);
        translate([26/2-4,0,0])cylinder(r=4,h=1.5);
      }//hull
        
      //mount holes
      translate([-9.5,0,-1])cylinder(d=3,h=4);
      translate([9.5,0,-1])cylinder(d=3,h=4);
  }//difference
}

module A4BeltTensionBlockAssembly(){
  A4BeltTensionBlock();
  translate([0,6,5])A4BeltClampAssembly();
  
  translate([-13,0,4])
    rotate([-90,0,0])m4_shcs(40);
  translate([13,0,4])
    rotate([-90,0,0])m4_shcs(40);

}

module A4BeltTensionBlock(){
  width=40;

  translate([-width/2,0,0])
  color("Crimson")
  difference(){
    cube([width,15,8]);
    
    // Belt Clamp Inset
    translate([(width-33)/2,-7,4])
      rcube([33,20,6], 4);
      
    //Belt Clamp Mount Holes
    translate([width/2-9.5,6,-1])cylinder(d=3,h=10);
    translate([width/2+9.5,6,-1])cylinder(d=3,h=10);
    
    //Tension Screw Vias
    translate([width/2-13,-1,4])  
      rotate([-90,0,0])
        cylinder(d=3.8, h=20);
    translate([width/2+13,-1,4])  
      rotate([-90,0,0])
        cylinder(d=3.8, h=20);
    
  }//difference
}

module A4AdapterPlate(){
color("Crimson")
  difference(){
      cube([plateWidth,plateDepth,plateHeight]);
      
      // 30mm hole for focuser assembly
      translate([focuserXOffset,plateDepth/2,-1])cylinder(d=30,h=10);
      
    // focuser mounting holes
    foc_mount_positions = [
        [focuserXOffset-18, plateDepth/2+11],
        [focuserXOffset+18, plateDepth/2+11],
        [focuserXOffset-18, plateDepth/2-11],
        [focuserXOffset+18, plateDepth/2-11],
    ];
    // screw holes
    for (pos = foc_mount_positions)
        translate([pos[0], pos[1], -1])
            cylinder(h=plateHeight+2, d=5);
    //counter sinks from bottom
    for (pos = foc_mount_positions)
        translate([pos[0], pos[1], -1])
            cylinder(h=6, d=8);
    
            
    // MGN15 Mounting Holes  
    mgn_mount_positions = [
        [mgn15XOffset-13, plateDepth/2+13],
        [mgn15XOffset+13, plateDepth/2+13],
        [mgn15XOffset-13, plateDepth/2-13],
        [mgn15XOffset+13, plateDepth/2-13],
    ];
    for (pos = mgn_mount_positions)
        translate([pos[0], pos[1], -1])
            x_slot(radius=5/2,height=plateHeight+2, slotWidth=10);
    
    
    // Belt Clamp Inset
    translate([mgn15XOffset-17,plateDepth-10,5])
      rcube([34,15,4], 4);
      
    //Belt Clamp Mount Holes
    translate([mgn15XOffset-9.5,plateDepth-4,-1])cylinder(d=3,h=10);
    translate([mgn15XOffset+9.5,plateDepth-4,-1])cylinder(d=3,h=10);
    
    //Clamp tension holes
        
    translate([mgn15XOffset-13,-1,4])  
      rotate([-90,0,0])
        cylinder(d=3.8, h=13);
    translate([mgn15XOffset+13,-1,4])  
      rotate([-90,0,0])
        cylinder(d=3.8, h=13);
        
    // Drag Chain Mount Threaded Holes 
    // Far end of block, 36mm apart
    translate([plateWidth-14,plateDepth/2+18,plateHeight/2])
      rotate([0,90,0])cylinder(d=3.7, h=15);
    translate([plateWidth-14,plateDepth/2-18,plateHeight/2])
      rotate([0,90,0])cylinder(d=3.7, h=15);
        
  }//difference

}

module x_slot(radius, height, slotWidth){
  hull(){
    translate([-slotWidth/2+radius,0,0])
      cylinder(r=radius, h=height);
    translate([slotWidth/2-radius,0,0])
      cylinder(r=radius, h=height);
  }

}

module rcube(size, r=corner_r) {
    // Rounded-corner cube
    hull() {
        for (x = [r, size[0]-r])
            for (y = [r, size[1]-r])
                translate([x, y, 0])
                    cylinder(r=r, h=size[2], $fn=24);
    }
}
