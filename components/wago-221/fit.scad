//-----------------------------------------------------------------------
// Fit piece: four clips for a 221-415 on one open floor, marked 1 to 4 dots
// at the end of each. Push a WAGO down into each until the hooks snap over.
// Then try to lift it out by the levers, and prise a hook off.
//
//   1  hook 0.4, clearance 0.4
//   2  hook 0.7, clearance 0.4
//   3  hook 1.0, clearance 0.4
//   4  hook 0.7, clearance 0.2
//
// The floor is a frame (open under each WAGO) to save plastic. Set `name`
// for another size. Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <wago-221.scad>
use <../../util/marks.scad>

name      = "221-415";
baseThick = 1.6;
rim       = 4;       // solid floor round each clip
markRoom  = 5;       // floor past one end for the dots

stations  = [ [0.4, 0.4], [0.4, 0.7], [0.4, 1.0], [0.2, 0.7] ];   // [clearance, hook]

L = wagoLength(name);
D = wagoDepth(name);
n = len(stations);
pitch = D + 2*(0.4 + 1.6) + 3;
fy0 = -L/2 - 0.4 - 1.6 - rim + 1;
fy1 =  L/2 + 0.4 + 1.6 + rim - 1 + markRoom;
fx0 = -pitch/2;

difference()
{
  union()
  {
    translate([fx0, fy0, -baseThick]) cube([n*pitch, fy1 - fy0, baseThick]);
    for (i = [0 : n - 1])
      translate([i*pitch, 0, 0]) wagoClip(name, clearance = stations[i][0], hook = stations[i][1]);
  }
  for (i = [0 : n - 1])
    translate([i*pitch, 0, 0])
    {
      //-- open floor under the WAGO, leaving a rim round it and under the stops
      translate([-D/2 + rim, -L/2 + rim, -baseThick - 1]) cube([D - 2*rim, L - 2*rim, baseThick + 2]);
      translate([0, fy1 - markRoom/2, 0]) markDots(i + 1);
    }
}

if ($preview)
  for (i = [0 : n - 1]) translate([i*pitch, 0, 0]) wagoGhost(name);
