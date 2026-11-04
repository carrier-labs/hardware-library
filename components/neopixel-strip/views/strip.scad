// The strip pieces as solids, for the catalogue (the Ghost is % so it never renders).
// layout "station": as views/station.scad; "fit": n pieces at the fit piece's pitch.
use <../neopixel-strip.scad>

axisZ  = 8;
layout = "station";
n      = 4;
pitch  = 18;

if (layout == "fit")
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) npxSolid(axisZ, length = 15, clearance = [0.2, 0.4, 0.3, 0.3][i]);
else
{
  npxSolid(axisZ, length = 15);
  translate([0, 18, 0]) npxSolid(axisZ, n = 3, along = true);
}
