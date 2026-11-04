//-----------------------------------------------------------------------
// Fit piece: four AS5600 mounts on one strip of floor, marked 1 to 4 dots
// between the front posts. Only the lip clearance changes: that sets how far
// the board can shift, and the magnet axis must stay within 0.25 of the IC.
//
//   1  0.05 per side
//   2  0.10 per side
//   3  0.15 per side
//   4  0.25 per side
//
// Drop a board in each: it should go in square without forcing, then sit
// with no shake you can feel. Screw one down (M2.5 x 8 up from below, washer
// and nut on top) to check the counterbores and that the clamp doesn't tilt it.
// Posts are short here (postH) to save plastic; the slot through each
// station's floor takes header pins pointing down (stand it on two blocks
// if they're longer than the floor and posts).
//
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <as5600-mount.scad>
use <../../util/marks.scad>

board      = "as5600-23";
postH      = 3.0;
floorThick = 2.0;
clears     = [0.05, 0.10, 0.15, 0.25];
side       = 23;                                  // board, for the layout
pitch      = side + 2*(0.25 + 1.6) + 4;

n = len(clears);
w = side + 2*(0.25 + 1.6) + 2;

difference()
{
  union()
  {
    translate([-pitch/2 + 1, -w/2, -floorThick]) cube([n*pitch - 2, w, floorThick]);
    for (i = [0 : n - 1]) translate([i*pitch, 0, 0]) as56Holder(postH, board, clearance = clears[i]);
  }
  for (i = [0 : n - 1])
    translate([i*pitch, 0, 0])
    {
      as56FloorCut(floorThick, board, headers = true);
      translate([0, -8, 0]) markDots(i + 1);
    }
}

if ($preview)
  for (i = [0 : n - 1]) translate([i*pitch, 0, 0]) as56Ghost(postH, board);
