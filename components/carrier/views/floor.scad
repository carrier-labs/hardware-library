// A piece of box floor offering two 3 x 2 carriers, for the catalogue: on the left the
// "tap" bosses (the carrier stands 4 above the floor), on the right the "nut" fixing
// (carrier flat, nut traps underneath). Cut it open to see the pilot holes and the traps.
use <../carrier.scad>

floorThick = 2.4;
nx = 3; ny = 2;

difference()
{
  union()
  {
    translate([-40, -15, -floorThick]) cube([80, 30, floorThick]);
    translate([-20, 0, 0]) carrierBosses(nx, ny);
  }
  translate([-20, 0, 0]) carrierFloorCut(nx, ny, floorThick, "tap");
  translate([20, 0, 0]) carrierFloorCut(nx, ny, floorThick, "nut");
}
