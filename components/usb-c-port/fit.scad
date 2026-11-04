//-----------------------------------------------------------------------
// Fit piece: a strip of wall with four USB-C pockets, each with the relief
// for a board's end behind it, marked 1 to 4 dots. Hold a board level on
// the floor strip and slide its socket into each pocket from behind: it
// should go in with a light push, not rattle, and finish flush outside.
// Then plug a cable in from the front: it should seat fully.
//
//   1  0.10 per side
//   2  0.15 per side
//   3  0.20 per side
//   4  0.30 per side
//
// Set overhang/boardW/pcb to the board you'll test with (FireBeetle below;
// the relief is wide enough for the C3 Super Mini too).
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <usb-c-port.scad>
use <../../util/marks.scad>

wall      = 2.4;
overhang  = 1.47;     // FireBeetle 2 ESP32-E; C3 Super Mini 1.5
boardW    = 25.4;
pcb       = 1.6;
axisZ     = 5;        // socket axis above the floor: board on 1.8 of packing
baseThick = 2.0;
pitch     = 30;
clears    = [0.10, 0.15, 0.20, 0.30];

n     = len(clears);
wallH = axisZ + 6;
depth = 10;

difference()
{
  union()
  {
    translate([-wall, -pitch/2, -baseThick]) cube([wall + depth, n*pitch, baseThick + 0.01]);
    translate([-wall, -pitch/2, 0]) cube([wall, n*pitch, wallH]);
  }
  for (i = [0 : n - 1])
  {
    translate([0, i*pitch, 0]) usbcWallCut(axisZ, wall, overhang, boardW, pcb, clearance = clears[i]);
    translate([depth - 2.5, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) usbcGhost(axisZ, wall, overhang, boardW, pcb);
