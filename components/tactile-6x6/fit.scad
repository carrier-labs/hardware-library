//-----------------------------------------------------------------------
// Fit piece: a strip of wall with four switch holders, marked 1 to 4 dots
// behind each. Set a switch down on each seat, legs to the sides, and push
// it into the hole until it clicks. Then press it, and try pulling it back.
//
//   1  tooth 0.4, clearance 0.3
//   2  tooth 0.6, clearance 0.3
//   3  tooth 0.8, clearance 0.3
//   4  tooth 0.6, clearance 0.2
//
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <tactile-6x6.scad>
use <../../util/marks.scad>

wall      = 2.4;     // the project's wall: test at the thickness you'll use
axisZ     = 8;       // stem axis above the floor
baseThick = 2.0;
pitch     = 16;

stations  = [ [0.3, 0.4], [0.3, 0.6], [0.3, 0.8], [0.2, 0.6] ];   // [clearance, tooth]

n      = len(stations);
length = n*pitch;
depth  = wall + 8 + 6;                    // wall, seat, room for the dots
wallH  = axisZ + 6/2 + 3;

difference()
{
  union()
  {
    translate([-wall, -pitch/2, -baseThick]) cube([depth, length, baseThick + 0.01]);
    translate([-wall, -pitch/2, 0]) cube([wall, length, wallH]);
    for (i = [0 : n - 1])
      translate([0, i*pitch, -0.01]) tact6x6Holder(axisZ + 0.01, clearance = stations[i][0], tooth = stations[i][1]);
  }
  for (i = [0 : n - 1])
  {
    translate([0, i*pitch, 0]) tact6x6WallCut(axisZ, wall);
    translate([depth - wall - 2.5, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) tact6x6Ghost(axisZ);
