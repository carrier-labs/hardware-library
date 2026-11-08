// A JZK RS485 module's hooks on a 3 x 5 carrier plate, for the catalogue: pedestal strip,
// end stops, a hook on each long edge (the +X one with a release tab). The plate is the
// carrier part's, solid (open = false) because the hooks' tongues need the area.
use <../snap-hook.scad>
use <../../rs485-max485/rs485-max485.scad>
use <../../carrier/carrier.scad>

variant  = "jzk";
pedestal = 2.5;
padW     = 6;
padEnd   = 8.5;
stopClear = 0.4;
stopW    = 6;
stopT    = 1.6;
stopRise = 1.0;
plate    = 1.6;
nx = 3; ny = 5;                     // carrier units of 10

v   = rs485(variant);
L   = v[1]; W = v[2];
top = pedestal + v[3];

difference()
{
  union()
  {
    carrierPlate(nx, ny, open = false);
    translate([-padW/2, -(L/2 - padEnd), -0.01]) cube([padW, L - 2*padEnd, pedestal + 0.01]);
    for (m = [0, 1]) mirror([0, m, 0])
      translate([-stopW/2, L/2 + stopClear, -0.01]) cube([stopW, stopT, top + stopRise + 0.01]);
    snapHookPair(W, top, tab = [false, true]);
  }
  snapHookPairFloorCut(W, top, floorThick = plate);
}
