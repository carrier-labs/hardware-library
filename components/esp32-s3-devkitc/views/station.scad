// One holder on a piece of wall and floor, for the catalogue: YD clone, right-hand port open.
use <../esp32-s3-devkitc.scad>

wall = 2.4;
ly   = s3DevkitLeftY();
cy   = ly - s3Devkit()[2]/2;
difference()
{
  union()
  {
    translate([-wall, cy - 18, -2]) cube([wall + 66, 36, 2.01]);
    translate([-wall, cy - 18, 0]) cube([wall, 36, s3DevkitAxisZ() + 4]);
    s3DevkitHolder(wall);
  }
  s3DevkitWallCut(wall);
}
