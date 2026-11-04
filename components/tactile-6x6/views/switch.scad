// The switch as a solid, for the catalogue (the Ghost is % so it never renders).
// n switches at the fit piece's pitch.
include <../tactile-6x6.scad>

axisZ = 8;
n     = 1;
pitch = 16;

module tact6x6Solid(axisZ)
{
  translate([0, -tact6Body/2, axisZ - tact6Body/2]) cube([tact6BodyH, tact6Body, tact6Body]);
  translate([0.01, 0, axisZ]) rotate([0, -90, 0]) cylinder(d = tact6StemDia, h = tact6Stem + 0.01, $fn = 32);
  for (s = [-1, 1], z = [-1, 1])
    translate([tact6BodyH - 0.01, s*tact6LegPitch/2 - tact6LegW/2, axisZ + z*tact6LegSpan/2 - tact6LegW/2])
      cube([tact6LegLength, tact6LegW, tact6LegW]);
}

for (i = [0 : n - 1]) translate([0, i*pitch, 0]) tact6x6Solid(axisZ);
