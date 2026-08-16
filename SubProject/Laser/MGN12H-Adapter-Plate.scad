// MGN12H Adapter Plate
// Custom lightweight plate for MGN12H carriage
// Designed for 2020/2040 aluminum extrusion frame
// For reference: 
//    X = width (left-to-right)
//    Y = depth  (front-to-back)
//    Z = height (vertical up-and-down)

use <shcs.scad>;
use <fhcs.scad>;
use <mgn12h-rail.scad>;
use <focuser-assembly.scad>;
use <x-axis-drive.scad>;
use <gt2-belt.scad>;
use <saddle-block.scad>;



$fn=64;
corner_r=4;

// Plate dimensions - narrower and thinner than A4
//plateWidth = 110;       // Reduced from 130mm (no drag chain area needed on plate)
plateWidth = 80;       // Reduced from 130mm (no drag chain area needed on plate)


plateDepth = 50;        // Reduced from 56mm 
plateHeight = 6;        // Reduced from 8mm (lighter)

// Feature offsets
focuserXOffset = 24;    // 9mm + 15mm radius (same as A4)
//mgn12XOffset = 65;      // Adjusted for narrower plate
mgn12XOffset = 60;      // Adjusted for narrower plate

// MGN12H bolt pattern: 20mm x 20mm, M3
mgn12_bolt_spacing = 20;

// Belt clamp bolt spacing
beltClampBoltSpacing = 9.5;   // ±9.5mm = 19mm total
tensionBoltSpacing = 13;      // ±13mm = 26mm total


MGN12HAdapterPlateAssembly();


// X-axis rail assembly underneath
// Carriage top is at Z=22.5 in assembly coords
// Plate bottom at Z=0, so shift assembly down by 22.5
translate([mgn12XOffset, -375, -22.5])
    rotate([0,0,90])
    mgn12h_rail_assembly(800);

    
// Y-axis rail = right assembly underneath
translate([mgn12XOffset-200, -355, -62.5])
    rotate([0,0,0])
    mgn12h_rail_assembly(400);

// Y-axis rail = left assembly underneath
translate([mgn12XOffset-200, 400, -62.5])
    rotate([0,0,0])
    mgn12h_rail_assembly(400);
    
    
translate([focuserXOffset, plateDepth/2, 6])
      focuser_assembly();


translate([mgn12XOffset,410,-12.5])
  rotate([0,0,90])x_idler_assembly();      

translate([mgn12XOffset,0,12])rotate([90,0,90])gt2_belt(p1=[-355,0,0], p2=[410,0,0], r1=6.37, r2=6.37, width=6);
      
      
translate([mgn12XOffset,-355,-13])rotate([0,0,-90])x_drive_assembly();     
 
 
 
translate([mgn12XOffset,400,-40])saddle_block();
translate([mgn12XOffset,-355,-40])saddle_block();




module MGN12HAdapterPlateAssembly() {

  translate([plateDepth/2,-plateDepth/2,0])
  rotate([0,0,90])
  union(){
    MGN12HAdapterPlate();

    // Belt clamp on rear edge
    translate([mgn12XOffset, plateDepth-4, plateHeight-1])
        A4BeltClampAssembly();

    // Belt tension block on front
    translate([mgn12XOffset, -30, 0])
        A4BeltTensionBlockAssembly();
  }
}

module A4BeltClampAssembly() {
    A4BeltClamp();
    translate([-beltClampBoltSpacing, 0, 2])
        rotate([180, 0, 0]) m3_shcs(6);
    translate([beltClampBoltSpacing, 0, 2])
        rotate([180, 0, 0]) m3_shcs(6);
}

module A4BeltClamp() {
    color("black")
    difference() {
        hull() {
            translate([-26/2+4, 0, 0]) cylinder(r=4, h=1.5);
            translate([26/2-4, 0, 0]) cylinder(r=4, h=1.5);
        }
        // Mount holes
        translate([-beltClampBoltSpacing, 0, -1]) cylinder(d=3, h=4);
        translate([beltClampBoltSpacing, 0, -1]) cylinder(d=3, h=4);
    }
}

module A4BeltTensionBlockAssembly() {
    A4BeltTensionBlock();
    translate([0, 6, 5]) A4BeltClampAssembly();
    
    translate([-tensionBoltSpacing, 0, 4])
        rotate([-90, 0, 0]) m4_shcs(40);
    translate([tensionBoltSpacing, 0, 4])
        rotate([-90, 0, 0]) m4_shcs(40);
}

module A4BeltTensionBlock() {
    width = 40;
    translate([-width/2, 0, 0])
    color("Crimson")
    difference() {
        cube([width, 15, 8]);
        
        // Belt Clamp Inset
        translate([(width-30)/2, -7, 4])
            rcube([30, 20, 6], 4);
        
        // Belt Clamp Mount Holes
        translate([width/2-beltClampBoltSpacing, 6, -1]) cylinder(d=3, h=10);
        translate([width/2+beltClampBoltSpacing, 6, -1]) cylinder(d=3, h=10);
        
        // Tension Screw Vias
        translate([width/2-tensionBoltSpacing, -1, 4])
            rotate([-90, 0, 0]) cylinder(d=3.8, h=20);
        translate([width/2+tensionBoltSpacing, -1, 4])
            rotate([-90, 0, 0]) cylinder(d=3.8, h=20);
    }
}

module MGN12HAdapterPlate() {
    color("Crimson")
    difference() {
        // Main plate body
        cube([plateWidth, plateDepth, plateHeight]);
        
        // === Focuser Features ===
        
        // 30mm hole for focuser assembly
        translate([focuserXOffset, plateDepth/2, -1])
            cylinder(d=30, h=plateHeight+2);
        
        // Focuser mounting holes (36mm x 22mm pattern)
        foc_mount_positions = [
            [focuserXOffset-18, plateDepth/2+11],
            [focuserXOffset+18, plateDepth/2+11],
            [focuserXOffset-18, plateDepth/2-11],
            [focuserXOffset+18, plateDepth/2-11],
        ];
        // Screw through-holes
        for (pos = foc_mount_positions)
            translate([pos[0], pos[1], -1])
                cylinder(h=plateHeight+2, d=4.2);
        // Countersinks from bottom
        for (pos = foc_mount_positions)
            translate([pos[0], pos[1], -1])
                cylinder(h=4, d=7.5);
        
        // === MGN12H Mounting Holes ===
        // 20mm x 20mm pattern, M3
        mgn_mount_positions = [
            [mgn12XOffset - mgn12_bolt_spacing/2, plateDepth/2 + mgn12_bolt_spacing/2],
            [mgn12XOffset + mgn12_bolt_spacing/2, plateDepth/2 + mgn12_bolt_spacing/2],
            [mgn12XOffset - mgn12_bolt_spacing/2, plateDepth/2 - mgn12_bolt_spacing/2],
            [mgn12XOffset + mgn12_bolt_spacing/2, plateDepth/2 - mgn12_bolt_spacing/2],
        ];
        for (pos = mgn_mount_positions)
            translate([pos[0], pos[1], -1])
                cylinder(d=3.2, h=plateHeight+2);
        // Countersinks from top for SHCS heads
        for (pos = mgn_mount_positions)
            translate([pos[0], pos[1], plateHeight-2.5])
                cylinder(d=5.8, h=3);
        
        // === Belt Clamp Features ===
        
        // Belt Clamp Inset (rear edge)
        translate([mgn12XOffset-15, plateDepth-10, plateHeight-2])
            rcube([30, 15, 4], 4);
        
        // Belt Clamp Mount Holes
        translate([mgn12XOffset-beltClampBoltSpacing, plateDepth-4, -1])
            cylinder(d=3, h=plateHeight+2);
        translate([mgn12XOffset+beltClampBoltSpacing, plateDepth-4, -1])
            cylinder(d=3, h=plateHeight+2);
        
        // Tension screw holes (front edge)
        translate([mgn12XOffset-tensionBoltSpacing, -1, 4])
            rotate([-90, 0, 0]) cylinder(d=3.8, h=13);
        translate([mgn12XOffset+tensionBoltSpacing, -1, 4])
            rotate([-90, 0, 0]) cylinder(d=3.8, h=13);
        
        // === Weight Reduction Pockets ===

        // Drag Chain Mount Holes (right end face, M3 threaded)
        // 36mm apart in Y, at mid-height, entering from right side
        translate([plateWidth-5, plateDepth/2+15, plateHeight/2])
            rotate([0, 90, 0]) cylinder(d=2.5, h=15);
        translate([plateWidth-5, plateDepth/2-15, plateHeight/2])
            rotate([0, 90, 0]) cylinder(d=2.5, h=15);
        
        // Pocket below focuser area (bottom side, between mount holes)
        translate([focuserXOffset-12, 8, -1])
            rcube([24, 6, 2.5], 3);
        translate([focuserXOffset-12, plateDepth-14, -1])
            rcube([24, 6, 2.5], 3);
    }
}

module x_slot(radius, height, slotWidth) {
    hull() {
        translate([-slotWidth/2+radius, 0, 0])
            cylinder(r=radius, h=height);
        translate([slotWidth/2-radius, 0, 0])
            cylinder(r=radius, h=height);
    }
}

module rcube(size, r=corner_r) {
    hull() {
        for (x = [r, size[0]-r])
            for (y = [r, size[1]-r])
                translate([x, y, 0])
                    cylinder(r=r, h=size[2], $fn=24);
    }
}
