// Holders on a short piece of wall and floor, for the catalogue: a single
// pixel standing up (open window), and three in a row lying along the wall
// behind a diffuser skin.
use <../neopixel-strip.scad>

wall  = 2.4;
axisZ = 8;
rowY  = 18;          // the row's first LED

difference()
{
  union()
  {
    translate([-wall, -10, -2]) cube([wall + 14, 10 + rowY + 2*10 + 10, 2]);
    translate([-wall, -10, 0]) cube([wall, 10 + rowY + 2*10 + 10, axisZ + 9]);
    npxHolder(axisZ, length = 15);
    translate([0, rowY, 0]) npxHolder(axisZ, n = 3, along = true);
  }
  npxWallCut(axisZ, wall);
  translate([0, rowY, 0]) npxWallCut(axisZ, wall, n = 3, along = true, window = "skin", bar = true);
}
