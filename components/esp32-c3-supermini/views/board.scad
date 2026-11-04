// The board as solids, for the catalogue (the Ghost is % so it never renders).
// part = "board" (PCB, buttons, antenna) | "socket"; n boards at the fit piece's pitch and tapes
include <../esp32-c3-supermini.scad>

wall  = 2.4;
part  = "board";
n     = 1;
pitch = 26;
tapes = [0.7, 0.85, 1.0, 1.0];

module c3Solid(tape)
{
  d   = c3MiniDims();
  ex  = c3MiniEdgeX(wall);
  bz  = boardPocketZ(tape = tape);
  top = bz + d[2];
  if (part == "board")
  {
    translate([ex, -d[1]/2, bz]) cube([d[0], d[1], d[2]]);
    for (s = [-1, 1])
      translate([ex + c3ButtonX - c3ButtonSize/2, s*c3ButtonY - c3ButtonSize/2, top - 0.01])
        cube([c3ButtonSize, c3ButtonSize, c3ButtonH + 0.01]);
    translate([ex + d[0] - 1 - c3AntennaSize[0], -c3AntennaSize[1]/2, top - 0.01]) cube(c3AntennaSize);
  }
  if (part == "socket")
    translate([ex - d[3], 0, top + c3UsbH/2]) rotate([0, 90, 0]) rotate([0, 0, 90])
      linear_extrude(c3UsbDepth) usbcShell2D(h = c3UsbH);
}

for (i = [0 : n - 1]) translate([0, i*pitch, 0]) c3Solid(n == 1 ? bpTape : tapes[i]);
