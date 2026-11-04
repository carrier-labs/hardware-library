// One holder on a piece of wall and floor, for the catalogue.
use <../esp32-c3-supermini.scad>

wall = 2.4;
difference()
{
  union()
  {
    translate([-wall, -13, -2]) cube([wall + 28, 26, 2.01]);
    translate([-wall, -13, 0]) cube([wall, 26, c3MiniAxisZ(1.0) + 4]);
    c3MiniHolder(wall);
  }
  c3MiniWallCut(wall);
}
