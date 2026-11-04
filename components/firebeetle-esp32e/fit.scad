//-----------------------------------------------------------------------
// Fit piece: a strip of wall and floor carrying the USB end of a FireBeetle
// four times over, marked 1 to 4 dots. Each station has the USB-C pocket,
// the board relief, the charge-LED light hole and the two posts at the USB
// end (the far end isn't needed: hold the board level). Slide the board's
// socket into the pocket from behind, over the post tops, and screw it down
// with two M2 x 8.
//
//   1  posts nominal, nut traps        (pocket 0.15 per side)
//   2  posts 0.2 further from the wall: socket face 0.2 back from flush
//   3  posts 0.2 closer to the wall:    socket face 0.2 proud
//   4  posts nominal, tap posts (screw cuts its own thread, no nuts)
//
// So: which sits flush (1-3), and nuts or self-tapping (1 v 4). The pocket
// clearance itself comes from the usb-c-port fit piece.
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <firebeetle-esp32e.scad>
use <../../util/marks.scad>

variant    = "ESP32-E";
wall       = 2.4;     // the project's wall: test at the thickness you'll use
floorThick = 2.0;     // M2 nut trap needs 2.0
postH      = 4.7;
clearance  = 0.15;
pitch      = 32;
depth      = 10;      // floor behind the wall's inner face

stations   = [ [0, "nut"], [0.2, "nut"], [-0.2, "nut"], [0, "tap"] ];   // [postShift, how]

n     = len(stations);
wallH = fbAxisZ(variant, postH) + 6;

union()
{
  difference()
  {
    union()
    {
      translate([-wall, -pitch/2, -floorThick]) cube([wall + depth, n*pitch, floorThick + 0.01]);
      translate([-wall, -pitch/2, 0]) cube([wall, n*pitch, wallH]);
    }
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0])
      {
        fbWallCut(variant, wall, postH, stations[i][1], clearance, stations[i][0], channelTop = wallH + 1);
        fbFloorCut(variant, wall, floorThick, postH, stations[i][1], postShift = stations[i][0], posts = "usb");
        translate([depth - 2.5, 0, 0]) rotate([0, 0, 90]) markDots(i + 1);
      }
  }
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0]) fbHolder(variant, wall, postH, stations[i][1], postShift = stations[i][0], posts = "usb");
}

if ($preview)
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0]) fbGhost(variant, wall, floorThick, postH, stations[i][1], stations[i][0], posts = "usb");
