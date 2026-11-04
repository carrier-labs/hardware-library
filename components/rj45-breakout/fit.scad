//-----------------------------------------------------------------------
// Fit piece: a strip of wall with four RJ45 jack pockets, each with the two
// screw posts behind it on a ladder of floor, marked 1 to 4 dots between
// the posts. Slide a breakout along the post tops, jack first, into each
// pocket; screw it down (M2.5 x 8, nut in the trap underneath). The jack
// should go in with a light push, sit square, and finish flush outside.
// Then plug a cable in and press its latch to pull it out again.
//
//   1  0.15 per side
//   2  0.20 per side
//   3  0.30 per side (the controller project's boxes)
//   4  0.40 per side
//
// Set wall to the box you'll build (2.0 in the controller project's receiver and rack-end).
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <rj45-breakout.scad>
use <../../util/marks.scad>

board      = "pihut-106592";
wall       = 2.0;
postH      = 4.2;
floorThick = 2.4;
pitch      = 34;
clears     = [0.15, 0.20, 0.30, 0.40];

n      = len(clears);
holes  = rj45HolesXY(wall, board);
holeX  = holes[0][0];
front  = 6;                                  // floor bar along the wall, past its inner face
barW   = 9;                                  // floor bar under the posts
wallH  = rj45AxisZ(postH, board) + 7.5;      // jack top + clearance + 2 or so

difference()
{
  union()
  {
    //-- ladder of floor: along the wall, under the posts, and rungs between stations
    translate([-wall, -pitch/2, -floorThick]) cube([wall + front, n*pitch, floorThick]);
    translate([holeX - barW/2, -pitch/2, -floorThick]) cube([barW, n*pitch, floorThick]);
    for (i = [0 : n])
      translate([front - 1, i*pitch - pitch/2 - (i == 0 ? 0 : i == n ? 4 : 2), -floorThick])
        cube([holeX - front + 2, 4, floorThick]);
    translate([-wall, -pitch/2, 0]) cube([wall, n*pitch, wallH]);
    for (i = [0 : n - 1]) translate([0, i*pitch, 0]) rj45Holder(wall, postH, board);
  }
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0])
    {
      rj45WallCut(wall, postH, board, clearance = clears[i]);
      rj45FloorCut(wall, floorThick, board);
      translate([holeX, 0, 0]) markDots(i + 1);
    }
}

if ($preview)
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) rj45Ghost(wall, postH, board);
