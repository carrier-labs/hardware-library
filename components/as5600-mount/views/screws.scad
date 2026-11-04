// Screws up from below, washers and nuts on top, as solids for the catalogue.
include <../as5600-mount.scad>
use <../../screw-post/screw-post.scad>

board = "as5600-23"; tipZ = 11; magnet = "6x1"; floorThick = 2.0; L = 10;
postH = as56PostH(as56MagnetFaceZ(tipZ, magnet), board = board);
b = as56Board(board); s = b[6];
top = postH + b[3];
for (h = b[4])
  translate([h[0], h[1], 0])
  {
    translate([0, 0, -floorThick]) cylinder(d = screwHeadDia(s), h = screwHeadH(s), $fn = 24);
    translate([0, 0, -floorThick + screwHeadH(s) - 0.01]) cylinder(d = screwDia(s), h = L + 0.01, $fn = 16);
    translate([0, 0, top]) difference() { cylinder(d = as56WasherD, h = as56WasherT, $fn = 24); translate([0, 0, -1]) cylinder(d = screwDia(s) + 0.2, h = 2, $fn = 16); }
    translate([0, 0, top + as56WasherT]) difference() { cylinder(d = screwNutAF(s)/cos(30), h = screwNutH(s), $fn = 6); translate([0, 0, -1]) cylinder(d = screwDia(s) - 0.01, h = 4, $fn = 16); }
  }
