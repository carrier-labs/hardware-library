// One breakout station: a piece of wall and floor with the jack pocket and two posts, for the catalogue.
use <../rj45-breakout.scad>

board = "pihut-106592"; wall = 2.0; postH = 4.2; floorThick = 2.4; clearance = 0.3;
wallH = rj45AxisZ(postH, board) + 7.5;
difference()
{
  union()
  {
    translate([-wall, -18, -floorThick]) cube([wall + 26, 36, floorThick]);
    translate([-wall, -18, 0]) cube([wall, 36, wallH]);
    rj45Holder(wall, postH, board);
  }
  rj45WallCut(wall, postH, board, clearance = clearance);
  rj45FloorCut(wall, floorThick, board);
}
