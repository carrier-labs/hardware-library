// The M2 x 8 button-head screws and the nuts trapped in the floor, as solids for the catalogue.
use <../firebeetle-esp32e.scad>
use <../../screw-post/screw-post.scad>

variant    = "ESP32-E";
wall       = 2.4;
floorThick = 2.0;
postH      = 4.7;
length     = 8;

s   = "M2";
top = postH + 1.6;
for (h = fbHoles(variant, wall))
  translate([h[0], h[1], 0])
  {
    translate([0, 0, top]) cylinder(d = screwHeadDia(s), h = screwHeadH(s), $fn = 24);
    translate([0, 0, top - length]) cylinder(d = screwDia(s), h = length + 0.01, $fn = 16);
    translate([0, 0, -floorThick]) rotate([0, 0, 30]) cylinder(d = screwNutAF(s)/cos(30), h = screwNutH(s), $fn = 6);
  }
