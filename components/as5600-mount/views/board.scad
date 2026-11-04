// The board and its IC as solids, for the catalogue.
include <../as5600-mount.scad>

board = "as5600-23"; tipZ = 11; magnet = "6x1";
postH = as56PostH(as56MagnetFaceZ(tipZ, magnet), board = board);
b = as56Board(board);
difference()
{
  translate([0, 0, postH]) linear_extrude(b[3]) as56Outline(board);
  for (i = [0 : len(b[4]) - 1]) translate([b[4][i][0], b[4][i][1], postH - 1]) cylinder(d = b[5][i], h = b[3] + 2, $fn = 20);
}
translate([-as56IcL/2, -as56IcW/2, postH + b[3] - 0.01]) cube([as56IcL, as56IcW, as56IcH + 0.01]);
