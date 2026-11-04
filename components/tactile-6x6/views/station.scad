// One holder on a short piece of wall and floor, for the catalogue.
use <../tactile-6x6.scad>

wall  = 2.4;
axisZ = 8;

difference()
{
  union()
  {
    translate([-wall, -9, -2]) cube([wall + 10, 18, 2.01]);
    translate([-wall, -9, 0]) cube([wall, 18, axisZ + 6]);
    translate([0, 0, -0.01]) tact6x6Holder(axisZ + 0.01);
  }
  tact6x6WallCut(axisZ, wall);
}
