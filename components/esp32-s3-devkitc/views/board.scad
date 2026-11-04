// The board as solids, for the catalogue (the Ghost is % so it never renders).
// part = "board" (PCB, LED) | "metal" (module shield, both ports); n boards at the fit
// piece's pitch, recesses and tapes
include <../esp32-s3-devkitc.scad>

wall     = 2.4;
part     = "board";
n        = 1;
pitch    = 36;
stations = [ [0.62, 1.0], [0.8, 1.0], [1.0, 1.0], [0.62, 0.7] ];   // as fit.scad

module s3Solid(recess, tape)
{
  v   = s3Devkit();
  ex  = s3DevkitEdgeX(wall, recess = recess);
  ly  = s3DevkitLeftY();
  top = boardPocketZ(tape = tape) + v[3];
  if (part == "board")
  {
    translate([ex, ly - v[2], top - v[3]]) cube([v[1], v[2], v[3]]);
    translate([ex + v[9][0] - 0.75, ly - v[9][1] - 0.75, top - 0.01]) cube([1.5, 1.5, 0.61]);
  }
  if (part == "metal")
  {
    translate([ex + v[1] + v[8] - s3ModuleL, ly - v[2]/2 - s3ModuleW/2, top]) cube([s3ModuleL, s3ModuleW, s3ModuleH]);
    for (c = v[5])
      translate([ex - v[6], ly - c, top + v[7][1]/2]) rotate([0, 90, 0]) rotate([0, 0, 90])
        linear_extrude(s3ShellDepth) s3Shell2D(v);
  }
}

if (n == 1) s3Solid(undef, bpTape);
else for (i = [0 : n - 1]) translate([0, i*pitch, 0]) s3Solid(stations[i][0], stations[i][1]);
