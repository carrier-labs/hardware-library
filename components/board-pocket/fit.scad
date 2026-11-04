//-----------------------------------------------------------------------
// Fit piece: four board pockets on a light frame, marked 1 to 4 dots at
// their right-hand end. Two for the ESP32-C3 Super Mini, two for the JZK
// RS485 module, each at the PETG and the PLA clearance.
//
//   1  C3 Super Mini 22.52 x 18,  clearance 0.3 (PLA)
//   2  C3 Super Mini 22.52 x 18,  clearance 0.4 (PETG)
//   3  RS485 module  43 x 15.5,   clearance 0.3 (PLA)
//   4  RS485 module  43 x 15.5,   clearance 0.4 (PETG)
//
// Drop each board in: it should go in without forcing and not rattle about
// more than you'd like. Then stick a pad of the foam tape on the pedestal
// and press the board down: the edges should stay clear of the floor.
// The floor is a frame (windows either side of each pedestal) to save plastic.
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <board-pocket.scad>
use <../../util/marks.scad>

baseThick = 1.0;
pitch     = 25;
dotX      = 27;       // dots, past the longest pocket
tabX      = 31;       // frame's +X end

//-- [l, w, pedestal [l, w], clearance]: pedestals as in the controller project's receiver.scad
stations = [
  [22.52, 18.0, [14, 10], 0.3],
  [22.52, 18.0, [14, 10], 0.4],
  [43.0,  15.5, [26,  9], 0.3],
  [43.0,  15.5, [26,  9], 0.4],
];
wallT = 1.2;
n = len(stations);

module footprint(s) let (ox = s[0]/2 + s[3] + wallT + 1, oy = s[1]/2 + s[3] + wallT + 1)
  translate([-ox, -oy]) square([ox + tabX, 2*oy]);

difference()
{
  union()
  {
    //-- frame: each pocket's footprint plus a spine joining them under the dots
    translate([0, 0, -baseThick])
      linear_extrude(baseThick + 0.01)
      {
        for (i = [0 : n - 1]) translate([0, i*pitch]) footprint(stations[i]);
        translate([dotX - 3, -pitch/2 + 2]) square([tabX - dotX + 2.5, (n - 1)*pitch + pitch - 4]);
      }
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0])
        boardPocketHolder(stations[i][0], stations[i][1], stations[i][2], clearance = stations[i][3]);
  }
  for (i = [0 : n - 1])
  {
    s = stations[i];
    //-- windows in the floor either side of the pedestal
    for (m = [-1, 1])
      translate([-s[2][0]/2 + 1, i*pitch + m*(s[2][1]/2 + 0.8) - (m < 0 ? s[1]/2 - s[2][1]/2 - 1.6 : 0), -baseThick - 1])
        cube([s[2][0] - 2, s[1]/2 - s[2][1]/2 - 1.6, baseThick + 1.02]);
    translate([dotX, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0]) boardPocketGhost(stations[i][0], stations[i][1], 1.6, stations[i][2]);
