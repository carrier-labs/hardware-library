// The breakout's PCB as a solid, for the catalogue: holes, and the cutout the mid-mount jack drops through.
include <../rj45-breakout.scad>

board = "pihut-106592"; wall = 2.0; postH = 4.2;
b  = rj45Board(board);
j  = rj45JackOf(board);
ex = rj45BoardEdgeX(wall, board);
difference()
{
  translate([ex, -b[2]/2 - b[7], postH]) cube([b[1], b[2], b[3]]);
  for (h = rj45HolesXY(wall, board)) translate([h[0], h[1], postH - 1]) cylinder(d = b[5], h = b[3] + 2, $fn = 20);
  if (j[2] < 0) translate([ex - j[4] - 0.01, -j[1]/2, postH - 1]) cube([j[5] + 0.01, j[1], b[3] + 2]);
}
