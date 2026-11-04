// The screw, nut and a board between them, as solids for the catalogue.
use <../screw-post.scad>

size       = "M2.5";
h          = 5;
floorThick = 2.4;
clamp      = 1.6;
d = screwDia(size);
L = screwPostScrew(size, h, floorThick, clamp);
for (x = [0, 12])
  translate([x, 0, 0])
  {
    translate([0, 0, h + clamp]) cylinder(d = screwHeadDia(size), h = screwHeadH(size), $fn = 24);
    translate([0, 0, h + clamp - (x == 0 ? L : h + clamp - 0.6)]) cylinder(d = d, h = x == 0 ? L : h + clamp - 0.6, $fn = 16);
  }
translate([0, 0, -floorThick]) rotate([0, 0, 30]) cylinder(d = screwNutAF(size)/cos(30), h = screwNutH(size), $fn = 6);
