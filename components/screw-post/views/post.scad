// One post of each kind on a piece of floor, for the catalogue: M2.5, nut trap and tap.
use <../screw-post.scad>

size       = "M2.5";
h          = 5;
floorThick = 2.4;

difference()
{
  union()
  {
    translate([-6, -6, -floorThick]) cube([24, 12, floorThick]);
    screwPost(size, h, "nut");
    translate([12, 0, 0]) screwPost(size, h, "tap");
  }
  screwPostFloorCut(size, floorThick, "nut");
}
