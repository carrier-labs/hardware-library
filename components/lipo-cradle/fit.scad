//-----------------------------------------------------------------------
// Fit piece: four cradles for the 602530 pack in a 2 x 2 grid on an open
// floor, marked 1 to 4 dots beside each. Drop the pack in each: does it go
// in without forcing, and how much does it slide about?
//
//   1  clearance 0.2
//   2  clearance 0.4
//   3  clearance 0.6
//   4  clearance 0.4, with strap bars for a 10 wide hook-and-loop strap
//
// The floor is a frame (open under each pack) to save plastic. Set `name`
// for another pack, `pcm` if its protection board makes it longer.
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <lipo-cradle.scad>
use <../../util/marks.scad>

name      = "602530";
pcm       = 0;
baseThick = 1.2;
rim       = 3;       // solid floor inside each wall
strapW    = 10;

stations  = [ [0.2, 0], [0.4, 0], [0.6, 0], [0.4, strapW] ];   // [clearance, strap]

d  = lipoDims(name);
lx = d[2] + pcm; ly = d[1];
out = 0.6 + 1.6;                                   // widest clearance + wall
px = lx + 2*out + 8;                               // room for the dots between
py = ly + 2*(out + 2 + 2) + 4;                     // room for the strap bars
pos = [[0, 0], [px, 0], [0, py], [px, py]];

difference()
{
  union()
  {
    //-- a floor pad under each cradle (and its dots), joined by two bars
    for (i = [0 : 3])
      translate([pos[i][0], pos[i][1], -baseThick])
      {
        sy = ly/2 + out + 1 + (stations[i][1] > 0 ? 4 : 0);
        translate([-lx/2 - pcm/2 - out - 1, -sy, 0]) cube([lx + 2*out + 2, 2*sy, baseThick]);
        translate([lx/2 - pcm/2, -6, 0]) cube([out + 7, 12, baseThick]);    // tab for the dots
      }
    for (y = [0, py]) translate([0, y - 3, -baseThick]) cube([px, 6, baseThick]);
    for (x = [0, px]) translate([x - 3, 0, -baseThick]) cube([6, py, baseThick]);
    for (i = [0 : 3])
      translate([pos[i][0], pos[i][1], 0])
        lipoCradle(name, clearance = stations[i][0], pcm = pcm, strap = stations[i][1]);
  }
  for (i = [0 : 3])
    translate([pos[i][0], pos[i][1], 0])
    {
      translate([-lx/2 - pcm/2 + rim, -ly/2 + rim, -baseThick - 1]) cube([lx - 2*rim, ly - 2*rim, baseThick + 2]);
      translate([lx/2 - pcm/2 + out + 4, 0, 0]) rotate([0, 0, 90]) markDots(i + 1);
    }
}

if ($preview)
  for (i = [0 : 3]) translate([pos[i][0], pos[i][1], 0]) lipoGhost(name, pcm);
