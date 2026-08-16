laser_tube(800);

module laser_tube(tube_length, laser=false)
{
  translate([tube_length/2,0,0])
  rotate([0,90,180])
  union(){
    //50,50,95,80
    end_length=85;
    union(){
        color("GhostWhite", alpha=.2)translate([0,0,end_length])cylinder(d=50,h=tube_length-(end_length*2),$fn=128);
        color("GhostWhite", alpha=.2)translate([0,0,tube_length-end_length])cylinder(d1=50,d2=20,h=end_length/2,$fn=128);
        color("PaleGoldenrod")translate([0,0,tube_length-(end_length/2)])cylinder(d=20,h=end_length/2,$fn=128);
        color("GhostWhite", alpha=.2)translate([0,0,end_length/2])cylinder(d1=20,d2=50,h=end_length/2,$fn=128);
        color("PaleGoldenrod")translate([0,0,0])cylinder(d=20,h=end_length/2,$fn=128);
    }
    
    //Laser beam (for alignment)
    if(laser==true){
      translate([0,0,800])color("red",.7)cylinder(d=1, h=120, $fn=32);
    }
  }//union
}