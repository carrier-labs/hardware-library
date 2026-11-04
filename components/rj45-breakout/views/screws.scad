// The two M2.5 screws and nuts as solids, for the catalogue.
use <../rj45-breakout.scad>
use <../../screw-post/screw-post.scad>

board = "pihut-106592"; wall = 2.0; postH = 4.2; floorThick = 2.4; pcb = 1.6;
L = 8;
for (h = rj45HolesXY(wall, board))
  translate([h[0], h[1], 0])
  {
    translate([0, 0, postH + pcb]) cylinder(d = screwHeadDia("M2.5"), h = screwHeadH("M2.5"), $fn = 24);
    translate([0, 0, postH + pcb - L]) cylinder(d = screwDia("M2.5"), h = L + 0.01, $fn = 16);
    translate([0, 0, -floorThick]) rotate([0, 0, 30]) cylinder(d = screwNutAF("M2.5")/cos(30), h = screwNutH("M2.5"), $fn = 6);
  }
