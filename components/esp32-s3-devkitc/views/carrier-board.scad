// The board as solids, seated on its carrier, in the carrier frame, for the catalogue and the
// collision check (the Ghost is % so it never renders). part = "board" (PCB, LED) | "metal"
// (module shield, both USB shells) | "pins" (header bodies and pins, which point down).
include <../esp32-s3-devkitc.scad>

part = "board";

v   = s3Devkit();
wx  = s3CarrierWallX();
py  = s3CarrierPortY();
ex  = s3DevkitEdgeX(s3CarrierWall);
bz  = boardPocketZ(s3CarrierPedestal, s3CarrierTape);   // the PCB's underside above the plate
top = bz + v[3];
ly  = s3DevkitLeftY();                                    // the board's left edge, holder frame
cy  = ly - v[2]/2;                                        // its centre line

translate([wx, py, 0])
{
  if (part == "board")
  {
    translate([ex, ly - v[2], bz]) cube([v[1], v[2], v[3]]);
    translate([ex + v[9][0] - 0.75, ly - v[9][1] - 0.75, top - 0.01]) cube([1.5, 1.5, 0.61]);
  }
  if (part == "metal")
  {
    translate([ex + v[1] + v[8] - s3ModuleL, cy - s3ModuleW/2, top]) cube([s3ModuleL, s3ModuleW, s3ModuleH]);
    for (c = v[5])
      translate([ex - v[6], ly - c, top + v[7][1]/2]) rotate([0, 90, 0]) rotate([0, 0, 90])
        linear_extrude(s3ShellDepth) s3Shell2D(v);
  }
  if (part == "pins")
    for (r = [-1, 1])
    {
      translate([ex + s3PinFromEnd - s3PinPitch/2, cy + r*v[10]/2 - s3PinPitch/2, bz - s3HeaderBody])
        cube([s3PinN*s3PinPitch, s3PinPitch, s3HeaderBody]);
      for (i = [0 : s3PinN - 1])
        translate([ex + s3PinFromEnd + i*s3PinPitch - s3PinSq/2, cy + r*v[10]/2 - s3PinSq/2, bz - s3PinBelow])
          cube([s3PinSq, s3PinSq, s3PinBelow + v[3] + s3PinAbove]);
    }
}
