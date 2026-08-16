
use <Laser_Tube.scad>


tubeMountAssembled();
//translate([0,400,70])rotate([90,0,0])laser_tube(800);


module tubeMountAssembled(z_offset=00)
{
    rotate([0,0,90])
    union(){
      tubeMountBase();
      translate([0,0,17.5 + z_offset])tubeMountBaseKnob();
      translate([0,0,9 + z_offset])rotate([90,0,0])tubeMountMid();
      translate([0,0,80 + z_offset])rotate([90,0,0])tubeMountTop();
    } //union
}

module tubeMountTop(){
    cutoutRad=41;
    cutoutOffset=11;
    
    
    translate([0,5,-10])difference(){
        union(){
            hull(){
                translate([-73/2,0,0])cube([73,10,20]);
                translate([-11,0,0])cube([22,25,20]);
            }//hull
            translate([-110/2,0,0])cube([110,10,20]);
            translate([-14+110/2,-5,0])cube([14,15,20]);
            translate([-110/2,-5,0])cube([14,15,20]);
        }//union
        
        translate([0,-cutoutRad+cutoutOffset,-1])cylinder(h=20+2,r=cutoutRad,$fn=128);
        
        translate([110/2-7.5,10,0])rotate([90,0,0])hull(){
            translate([0,10,-1])cylinder(d=5,h=20+2,$fn=32);
            translate([0,0,-1])cylinder(d=5,h=20+2,$fn=32);
        }
        translate([-110/2+7.5,10,0])rotate([90,0,0])hull(){
            translate([0,10,-1])cylinder(d=5,h=20+2,$fn=32);
            translate([0,0,-1])cylinder(d=5,h=20+2,$fn=32);
        }
    }
    
}

module tubeMountMid(){
    width = 110;
    depth = 67;
    height = 20;
    cutoutRad=41;
    cutoutOffset=35;
    
    
    translate([0,0,-height/2])difference(){
        translate([-width/2,0,0])cube([width, depth, height]);
        
        translate([0,cutoutRad+cutoutOffset,-1])cylinder(h=height+2,r=cutoutRad,$fn=128);
        translate([width/2-11-14.5,-1,-1])cube([11,38,height+2]);
        translate([-width/2+14.5,-1,-1])cube([11,38,height+2]);
        translate([-40/2,-1,-1])cube([40,29,height+2]);
        
    }
    rotate([-90,0,0])cylinder(d=15.6,h=28,$fn=64);
    color("silver")translate([width/2-7.5,0,0])rotate([-90,0,0])cylinder(d=4,h=depth+35,$fn=32);
    color("silver")translate([-width/2+7.5,0,0])rotate([-90,0,0])cylinder(d=4,h=depth+35,$fn=32);
}

module tubeMountBase(){
    width = 118;
    depth = 67;
    depth2 = 28;
    height = 10;
    height2 = 37;
    difference(){
        union() {
            translate([-width/2,-depth/2,0])cube([width,depth,height]);
            translate([-width/2,-depth2/2,0])cube([width,depth2,height2]);
        } //union
        
        // mount slots
        translate([(width/2-25)*-1,-22.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=height+2,$fn=32);
            translate([10,0,-1])cylinder(d=5,h=height+2,$fn=32);
        }
        translate([(width/2-25)*-1,22.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=height+2,$fn=32);
            translate([10,0,-1])cylinder(d=5,h=height+2,$fn=32);
        }        
        translate([(width/2-25),-22.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=height+2,$fn=32);
            translate([10,0,-1])cylinder(d=5,h=height+2,$fn=32);
        }        
        translate([(width/2-25),22.5,0])hull(){
            translate([-10,0,-1])cylinder(d=5,h=height+2,$fn=32);
            translate([10,0,-1])cylinder(d=5,h=height+2,$fn=32);
        }    
        
        //Knob coutout
        translate([-35/2,-depth/2,17])cube([35,depth,12]);
        
        //Middle top cutout
        translate([-60/2,-20/2,-1])cube([60,20,height2+2]);
        
        //End top cutouts
        translate([(-15-4)+width/2,-20/2,-1])cube([15,20,height2+2]);
        translate([-width/2+4,-20/2,-1])cube([15,20,height2+2]);       
        
    } //difference
}

module tubeMountBaseKnob() {
    difference(){
        cylinder(d=35,h=11,$fn=128);
        translate([0,0,-1])cylinder(d=16,h=13,$fn=64);
        
    }
}