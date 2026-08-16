//RearMirrorMount.scad


AssembledRearMirrorMount(10, laser=true);
//rearMirrorMountFront();

module AssembledRearMirrorMount(zOffset=0, laser=true){
  rotate([0,0,-90])
  union(){
    rearMirrorMountBase();
    translate([0,0,115+zOffset])rotate([0,0,-45])rearMirrorMountTop();
    
    if(laser==true){
        translate([0,3,115+zOffset+43])rotate([0,90,0])
          color("red", alpha=.7)cylinder(d=1, h=320, $fn=32);
    }
  } //union
}

module rearMirrorMountTop() {
    color("crimson")union(){
        translate([-56/2,-22/2.0])cube([56,22,8]);
        translate([0,0,-80])cylinder(r=6,h=80,$fn=128);
    }//union
    translate([0,-2,8])rotate([90,0,0])rearMirrorMountBack();
    translate([0,7,14])rotate([90,0,0])rearMirrorMountFront();
}


module rearMirrorMountFront() {
    width = 54;
    depth = 54;
    height = 8;
    holeOffsetX = 2;
    holeOffsetY = depth/2+2;
    
    color("crimson")difference(){
        translate([-width/2,0,0])cube([width,depth,height]);
        translate([holeOffsetX,holeOffsetY,-1])cylinder(d=23,h=10,$fn=128);
        translate([holeOffsetX,holeOffsetY,1])cylinder(d=26,h=8,$fn=128);
    } //difference
    
    //Mirror
    translate([holeOffsetX,holeOffsetY,1])Mirror25mm();
    translate([holeOffsetX,holeOffsetY,4.1])rotate([0,0,-45])MirrorPlug();
    
}

module rearMirrorMountBack(){
    color("crimson")difference(){
        translate([-54/2,0,0])cube([54,60,8]);
        translate([27-12,18,-1])hull(){
            translate([-5,5,0])cylinder(r=5,h=10,$fn=64);
            translate([-45,45,0])cube([45,10,10]);
            translate([-45,0,0])cube([10,45,10]);
        }//hull
    }//difference
    
    translate([-21,12,0])BrassBoltLarge();
    translate([21,12,0])BrassBoltLarge();
    translate([21,55,0])BrassBoltLarge();
}



module rearMirrorMountBase(){
    width = 56;
    depth = 60;
    height = 8;
    cyl1Rad = 14;
    cyl1Height = 20;
    cyl2Rad = 11;
    cyl2Height = 110;
    innerCylRad = 6;
    
    
    color("crimson")difference(){
        union(){
            translate([-width/2,-depth/2,0])cube([width,depth,height]);
            cylinder(r=cyl1Rad, h=cyl1Height, $fn=128);
            cylinder(r=cyl2Rad, h=cyl2Height, $fn=128);
        }//union
        translate([0,0,-1])cylinder(r=innerCylRad, h=cyl2Height+2, $fn=128);
        translate([15,depth/2-7.5,-1])hull(){
            translate([0,-7.5,0])cylinder(r=2.5,h=10,$fn=32);
            translate([0,7.5,0])cylinder(r=2.5,h=10,$fn=32);
        }
        translate([15,-depth/2+7.5,-1])hull(){
            translate([0,-7.5,0])cylinder(r=2.5,h=10,$fn=32);
            translate([0,7.5,0])cylinder(r=2.5,h=10,$fn=32);
        }
        translate([-15,depth/2-7.5,-1])hull(){
            translate([0,-7.5,0])cylinder(r=2.5,h=10,$fn=32);
            translate([0,7.5,0])cylinder(r=2.5,h=10,$fn=32);
        }
        translate([-15,-depth/2+7.5,-1])hull(){
            translate([0,-7.5,0])cylinder(r=2.5,h=10,$fn=32);
            translate([0,7.5,0])cylinder(r=2.5,h=10,$fn=32);
        }
    }//difference
    
    translate([-5,0,92])rotate([0,-90,0])BrassBoltSmall();
    translate([0,5,92])rotate([-90,0,0])BrassBoltSmall();
}

module BrassBoltLarge() {
    color("#B5A642")union() {
        translate([0,0,15])cylinder(d=10,h=8,$fn=64);
        translate([0,0,-1])cylinder(d=7,h=20,$fn=64);
        translate([0,0,8.1])cylinder(d=12,h=3,$fn=64);
    }
}

module BrassBoltSmall() {
    color("#B5A642")union() {
        translate([0,0,15])cylinder(d=8,h=8,$fn=64);
        translate([0,0,0])cylinder(d=4,h=20,$fn=64);
    }
}

module MirrorPlug() {
    color(c=[1,.15,.15])difference(){
        cylinder(d=25.5,h=4,$fn=128);
        translate([0,0,-1])cylinder(d=17,h=6,$fn=128);
        translate([-14,-1,2])cube([28,2,3]);
    }//difference
}

module Mirror25mm(){
    color("gold")cylinder(d=25,h=3,$fn=128);
}