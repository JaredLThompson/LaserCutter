iec_fused_inlet_model();


module iec_fused_inlet_model(){
  color("black")difference(){
    union(){
    translate([0,-17,0])hull(){
        translate([7,0,0])cube([40,17,27]);
        translate([0,0,7.5]) cube([47,17,15]);
    }//hull



    radius1 = 6;
    radius2 = 3;
    positions = [
        [47/2, -11+radius1, radius1],
        [47/2, 11+27-radius1, radius1],
        [radius2-6, 0, radius2],
        [radius2-6, 27, radius2],
        [47-radius2+6, 0, radius2],
        [47-radius2+6, 27, radius2],

    ];

    // Faceplate
    difference(){
      floor=0;
      hull(){
      for (pos = positions)
        translate([pos[0],floor, pos[1]])
            rotate([-90,0,0])cylinder(h=1.5, r=pos[2], $fn=32);
      }//hull

      // Screw moounts
      translate([47/2,-1,27/2-20])rotate([-90,0,0])cylinder(h=3, d=4.7, $fn=32);
      translate([47/2,-1,27/2+20])rotate([-90,0,0])cylinder(h=3, d=4.7, $fn=32);

      }//difference
   }//union

     //R14 Receptacle
   hull(){
     translate([0+8,-15,1.5])cube([10,17,24]);
     translate([-6+8,-15,6])cube([16,17,15]);
   }//hull
   translate([38-6.25,-6,5.5])cube([10.5,8,16]);
  }//difference

  //Power Swtitch
  translate([38-6,-6,5.5])color("red")cube([10,8,8]);
  translate([38-6,-5.95,5.5+8.8])rotate([-7,0,0])color("red")cube([10,8,8]);

  //Power Pins
  positions = [
        [11,23.5-3.8,11],
        [6,12.5,14],
        [11,1.5+3.8,11]
  ];
  for (pos = positions)
        translate([pos[0],-16, pos[1]])
            color("silver")cube([4,pos[2],2]);
}
