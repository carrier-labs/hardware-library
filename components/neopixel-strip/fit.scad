//-----------------------------------------------------------------------
// Fit piece: a strip of wall with four strip holders and their windows,
// marked 1 to 4 dots behind each. Drop the 15 long piece of 10 mm, 100/m
// strip into each slot, LED to the wall. Light it and look from outside.
//
//   1  slot clearance 0.2, open window
//   2  slot clearance 0.4, open window
//   3  slot clearance 0.3, diffuser skin 0.4
//   4  slot clearance 0.3, diffuser skin 0.8
//
// Prints base down, as exported, no supports: the skins are thin upright
// walls at the wall's outer face. Units: mm.
//-----------------------------------------------------------------------

use <neopixel-strip.scad>
use <../../util/marks.scad>

name      = "10mm-100";
coat      = "ip30";
length    = 15;      // the piece in hand, measured
wall      = 2.4;     // the project's wall: test at the thickness you'll use
axisZ     = 8;       // LED centre above the floor
baseThick = 2.0;
pitch     = 18;

stations  = [ [0.2, "open", 0], [0.4, "open", 0], [0.3, "skin", 0.4], [0.3, "skin", 0.8] ];   // [clearance, window, skin]

n      = len(stations);
depth  = wall + 5 + npxThick(coat) + 0.8 + 1.6 + 5;     // wall, gap, slot, back, room for the dots
wallH  = axisZ + 8/2 + 3;

difference()
{
  union()
  {
    translate([-wall, -pitch/2, -baseThick]) cube([depth, n*pitch, baseThick]);
    translate([-wall, -pitch/2, 0]) cube([wall, n*pitch, wallH]);
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0]) npxHolder(axisZ, name, length = length, coat = coat, clearance = stations[i][0]);
  }
  for (i = [0 : n - 1])
  {
    translate([0, i*pitch, 0]) npxWallCut(axisZ, wall, name, window = stations[i][1], skin = stations[i][2]);
    translate([depth - wall - 2.5, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) npxGhost(axisZ, name, length = length, coat = coat, clearance = stations[i][0]);
