//-----------------------------------------------------------------------
// Fit piece: four stations for the JZK TTL-RS485 module (43 x 15.5 x 1.6,
// no holes), marked 1 to 4 dots past the far end. Each is a 2.5-high
// pedestal strip under the board, an end stop at each end, and one hook on
// each long edge at mid-length, on its flex-relief tongue. Push the board
// down into each until both hooks click over. Then lift it by one end, tug
// it sideways, and pull it out.
//
//   1  reach 0.5, clearance 0.3
//   2  reach 0.7, clearance 0.3
//   3  reach 0.9, clearance 0.3
//   4  reach 0.7, clearance 0.2
//
// The floor is a 1.6 plate, as a carrier, with windows between the
// pedestal and the hooks. Boards run along Y, so a section along Y cuts
// every hook's profile. Set `variant` for another RS485 module. Prints
// base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <snap-hook.scad>
use <../rs485-max485/rs485-max485.scad>
use <../../util/marks.scad>

variant   = "jzk";
pedestal  = 2.5;       // floor to the board's underside: room for lead stubs
padW      = 6;         // pedestal strip, across the board
padEnd    = 8.5;       // strip stops this far from each end: clear of the pin rows
stopClear = 0.4;       // end stops to the board's ends (not under test)
stopW     = 6;
stopT     = 1.6;
stopRise  = 1.0;       // end stops above the board's top
plate     = 1.6;
pitch     = 31;        // stations along X: 15.5 + 2 x 6.9 past each edge, and a rail
spineW    = 8;         // floor under the pedestal, along Y
barW      = 16;        // floor under the hooks, along X
rail      = 3;         // floor round the edge of each cell
dotRoom   = 7;         // +Y rail, with the dots

stations  = [ [0.5, 0.3], [0.7, 0.3], [0.9, 0.3], [0.7, 0.2] ];   // [reach, clearance]

v   = rs485(variant);
L   = v[1]; W = v[2]; pcb = v[3];
top = pedestal + pcb;
n   = len(stations);
cx  = pitch/2;                       // cell half width
y0  = -(L/2 + stopClear + stopT + rail);
y1  =  L/2 + stopClear + stopT + dotRoom;
winX = [spineW/2, cx - rail];
winY = [barW/2, L/2 + stopClear + stopT - 1];

module station(reach, clearance)
{
  //-- pedestal strip and end stops
  translate([-padW/2, -(L/2 - padEnd), -0.01]) cube([padW, L - 2*padEnd, pedestal + 0.01]);
  for (m = [0, 1]) mirror([0, m, 0])
    translate([-stopW/2, L/2 + stopClear, -0.01]) cube([stopW, stopT, top + stopRise + 0.01]);
  snapHookPair(W, top, reach, clearance);
}

difference()
{
  union()
  {
    translate([-cx, y0, -plate]) cube([(n - 1)*pitch + 2*cx, y1 - y0, plate]);
    for (i = [0 : n - 1])
      translate([i*pitch, 0, 0]) station(stations[i][0], stations[i][1]);
  }
  for (i = [0 : n - 1])
    translate([i*pitch, 0, 0])
    {
      snapHookPairFloorCut(W, top, stations[i][0], stations[i][1], floorThick = plate);
      //-- windows in the four quadrants
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx > 0 ? winX[0] : -winX[1], sy > 0 ? winY[0] : -winY[1], -plate - 1])
          cube([winX[1] - winX[0], winY[1] - winY[0], plate + 2]);
      translate([0, y1 - dotRoom/2, 0]) markDots(i + 1);
    }
}

if ($preview)
  for (i = [0 : n - 1])
    translate([i*pitch, 0, 0]) rotate([0, 0, 90]) rs485Ghost(variant, pedestal, 0);
