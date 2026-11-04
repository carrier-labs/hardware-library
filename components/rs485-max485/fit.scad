//-----------------------------------------------------------------------
// Fit piece: four RS485 pockets, each with a bridge across it where a lid
// pad would be, marked 1 to 4 dots at the far end. Stick a 3 mm foam pad
// under each bridge; the stations vary how far the foam gets squashed on
// the board, so they also show up a PCB thinner or thicker than 1.6.
//
//   1  squeeze 0.5
//   2  squeeze 1.0   (the design value)
//   3  squeeze 1.5
//   4  squeeze 2.0
//
// The pocket ends are open: put tape on the pedestal with its liner on and
// slide the board in from the bus end (-X), under the foam. Which one holds
// the board firmly without bowing it, and still lets it slide in?
// The real holder has end walls (rs485Holder); this one leaves them off so
// the board can go in under the bridge.
// Prints base down, as exported, no supports (the bridges span about 20).
// Units: mm.
//-----------------------------------------------------------------------

include <rs485-max485.scad>
use <../../util/marks.scad>

foam      = 3.0;      // CAL: the foam you'll use
squeezes  = [0.5, 1.0, 1.5, 2.0];
baseThick = 1.0;
pitch     = 30;
barT      = 2.0;      // bridge thickness
pillar    = 3.0;      // pillar width across Y

v      = rs485();
n      = len(squeezes);
iy     = v[2]/2 + bpClearance;            // pocket inner half width
py     = iy + bpWall + 0.6;               // pillars' inner faces
padX   = v[1]/2 - rs485PadInset - rs485PadLen/2;   // logic-end lid pad, as in rs485LidPads
top    = rs485Top();
x0     = -v[1]/2 - bpClearance - 1;
x1     = v[1]/2 + 7;

difference()
{
  union()
  {
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0])
      {
        translate([x0, -py - pillar, -baseThick]) cube([x1 - x0, 2*(py + pillar), baseThick + 0.01]);
        rs485Holder(sides = ["open", "open", "gap", "gap"]);
        //-- bridge: pillars either side, bar across at the lid pad's height
        z0 = boardLidPadZ(top, foam, squeezes[i]);
        for (m = [-1, 1])
          translate([padX - rs485PadLen/2, m > 0 ? py : -py - pillar, -0.01]) cube([rs485PadLen, pillar, z0 + barT + 0.01]);
        translate([padX - rs485PadLen/2, -py - pillar, z0]) cube([rs485PadLen, 2*(py + pillar), barT]);
      }
    //-- spine joining the stations
    translate([x1 - 6, -pitch/2, -baseThick]) cube([6, n*pitch, baseThick + 0.01]);
  }
  for (i = [0 : n - 1])
    translate([x1 - 3, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
}

if ($preview)
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0])
    {
      rs485Ghost();
      boardLidPadGhost([rs485PadLen, v[2] - 3], [padX, 0], top, foam, squeezes[i]);
    }
