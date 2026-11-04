// The jack body as a solid, for the catalogue: a block with the plug opening in its face.
include <../rj45-breakout.scad>

board = "pihut-106592"; wall = 2.0; postH = 4.2;
j  = rj45JackOf(board);
ex = rj45BoardEdgeX(wall, board);
az = rj45AxisZ(postH, board);
difference()
{
  translate([ex - j[4], -j[1]/2, postH + j[2]]) cube([j[5], j[1], j[3] - j[2]]);
  //-- plug opening: 11.7 wide, 8 tall (CAL, for the picture only), 15 deep
  translate([ex - j[4] - 1, -11.7/2, az - 4]) cube([16, 11.7, 8]);
}
