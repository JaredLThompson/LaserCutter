//FrontMiorrorMount.scad


AssembledFrontMirrorMount(z_offset=10);




module AssembledFrontMirrorMount(z_offset=0, laser=true){
  rotate([0,0,0])
  union(){
    translate([0,0,0])
      rotate([0,0,0])
        frontMirrorMountBaseBottom();
    translate([0,-27.5,8])
      rotate([0,0,0])
        frontMirrorMountBaseTop();
    translate([-8,-62.2,z_offset-5])
      rotate([90,0,-45])
        frontMirrorMountBack(z_offset=z_offset);
    translate([-2,-54.2,16+z_offset])
      rotate([90,0,-45])
        frontMirrorMountFront();
  }//union
  
  if(laser==true){
    color("red",alpha=.7)
      translate([-8,-55,45+z_offset])
      rotate([0,90,0])
        cylinder(d=1,h=450,$fn=32);
  }
}


module AssembledFrontMirrorMount_v2(laser=true){
  rotate([0,0,0])
  union(){
    translate([0,0,0])
      rotate([0,0,0])
        frontMirrorMountBaseBottom();
    translate([0,-27.5,-8])
      rotate([0,0,0])
        frontMirrorMountBaseTop();
    translate([-8,-62.2,0])
      rotate([90,0,-45])
        frontMirrorMountBack();
    translate([-1,-55.2,22])
      rotate([90,0,-45])
        frontMirrorMountFront();
  }//union
  
  if(laser==true){
    color("red",alpha=.7)
      translate([-8,-55,52])
      rotate([0,90,0])
        cylinder(d=1,h=450,$fn=32);
  }
}


module frontMirrorMountBack(z_offset=0){
    color("crimson")difference(){
        translate([-54/2,0,0])cube([54,75,8]);
        translate([27-12,33,-1])hull(){
            translate([-5,5,0])cylinder(r=5,h=10,$fn=64);
            translate([-45,45,0])cube([45,10,10]);
            translate([-45,0,0])cube([10,45,10]);
        }//hull
        
        //bolt slots
        hull(){
          translate([-20,4,-1])cylinder(d=4, h=10, $fn=32);
          translate([-20,17,-1])cylinder(d=4, h=10, $fn=32);
        }
        //bolt slots
        hull(){
          translate([20,4,-1])cylinder(d=4, h=10, $fn=32);
          translate([20,17,-1])cylinder(d=4, h=10, $fn=32);
        }
    }//difference
    
    translate([-21,27,0])BrassBoltLarge();
    translate([21,27,0])BrassBoltLarge();
    translate([21,70,0])BrassBoltLarge();
    
    translate([-20,4+13-z_offset,-6])rotate([0,0,0])m4HexHeadBolt();
    translate([20,4+13-z_offset,-6])rotate([0,0,0])m4HexHeadBolt();
}

module frontMirrorMountBaseBottom(){
    color("crimson")difference(){
        translate([-56/2,-63,0])cube([56,63,8]);
        
        //mount slots
        translate([-15,-4,0])hull(){
            translate([0,0,-1])cylinder(d=5,h=10,$fn=64);
            translate([0,-18,-1])cylinder(d=5,h=10,$fn=64);
        }//hull
        translate([15,-4,0])hull(){
            translate([0,0,-1])cylinder(d=5,h=10,$fn=64);
            translate([0,-18,-1])cylinder(d=5,h=10,$fn=64);
        }//hull
        
        translate([-28,-102,-1])rotate([0,0,45])cube([55,55,10]);
        translate([28,-80,-1])rotate([0,0,45])cube([24,24,10]);
        
        //Mount holes
        translate([-8,-34,-1])cylinder(d=4,h=10,$fn=64);
        translate([8,-49,-1])cylinder(d=4,h=10,$fn=64);
    }
} //frontMirrorMountBaseBottom

module frontMirrorMountBaseTop(){
    color("crimson")difference(){
        translate([-56/2,-54,0])cube([56,54,8]);
        
        //mount slots
        translate([-8,-6.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=10,$fn=64);
            translate([10,0,-1])cylinder(d=5,h=10,$fn=64);
            //translate([0,0,-1])cylinder(d=5,h=10,$fn=64);
            
        }//hull
        translate([8,-21.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=10,$fn=64);
            translate([10,0,-1])cylinder(d=5,h=10,$fn=64);
            //translate([0,0,-1])cylinder(d=5,h=10,$fn=64);
        }//hull
        
        translate([-28,-93,-1])rotate([0,0,45])cube([55,55,10]);
        

        tempOffset2 = sqrt(24*24+24*24);
        translate([28,-tempOffset2-37,-1])rotate([0,0,45])cube([24,24,10]);

    }
    
    //Bolts from bottom
    //translate([-8,-6.5,14])rotate([0,180,0])m4HexHeadBolt();
    //translate([8,-21.5,14])rotate([0,180,0])m4HexHeadBolt();
    
    //Bolts from top
    translate([-8,-6.5,-6])rotate([0,0,0])m4HexHeadBolt();
    translate([8,-21.5,-6])rotate([0,0,0])m4HexHeadBolt();
    
    
} //frontMirrorMountBaseBottom


module frontMirrorMountFront() {
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
    
} //frontMirrorMountFront


module m4HexHeadBolt() {
    color("silver")difference(){
        union(){
         cylinder(d=4,h=16,$fn=64);
         translate([0,0,16])cylinder(d=7.5,h=4.5,$fn=64);
         translate([0,0,15])cylinder(d=7.7,h=1,$fn=64);
         translate([0,0,14])cylinder(d=8,h=1,$fn=64);
        }//union
        translate([0,0,19])fhex(4,4);
    }//difference
    
}

module fhex(wid,height){
    hull(){
        cube([wid/1.7,wid,height],center = true);
        rotate([0,0,120])cube([wid/1.7,wid,height],center = true);
        rotate([0,0,240])cube([wid/1.7,wid,height],center = true);
    } //hull
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