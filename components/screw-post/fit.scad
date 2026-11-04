//-----------------------------------------------------------------------
// Fit piece: a plate with a row of posts for each screw size, M2 at the
// front. In each row, dots 1-3 are nut traps at three clearances (drop a nut
// in from underneath: it should push in and stay, flush), dot 4 a tap post
// (drive the screw in: it should cut a thread without splitting the post).
// The size is engraved at the start of each row.
//
//   1  nut trap, across flats + 0.2
//   2  nut trap, + 0.3
//   3  nut trap, + 0.4
//   4  tap post
//
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <screw-post.scad>
use <../../util/marks.scad>

floorThick = 3.0;          // M3's nut needs 2.9
postH      = 5;
pitch      = 13;
sizes      = ["M2", "M2.5", "M3"];
nutClears  = [0.2, 0.3, 0.4];
labelW     = 12;

rows = len(sizes);
cols = len(nutClears) + 1;

difference()
{
  union()
  {
    translate([-labelW - pitch/2, -pitch/2, -floorThick]) cube([labelW + cols*pitch, rows*pitch, floorThick]);
    for (r = [0 : rows - 1], c = [0 : cols - 1])
      translate([c*pitch, r*pitch, 0]) screwPost(sizes[r], postH, c < len(nutClears) ? "nut" : "tap");
  }
  for (r = [0 : rows - 1])
  {
    for (c = [0 : len(nutClears) - 1])
      translate([c*pitch, r*pitch, 0]) screwPostFloorCut(sizes[r], floorThick, "nut", nutClears[c]);
    for (c = [0 : cols - 1])
      translate([c*pitch, r*pitch - pitch/2 + 1.6, 0]) markDots(c + 1);
    translate([-labelW/2 - pitch/2 + 1, r*pitch, -0.6])
      linear_extrude(1) text(sizes[r], size = 3.2, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
  }
}

if ($preview)
  for (r = [0 : rows - 1]) translate([0, r*pitch, 0]) screwPostGhost(sizes[r], postH, floorThick);
