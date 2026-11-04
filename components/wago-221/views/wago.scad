// The WAGO as a solid, for the catalogue (the Ghost is % so it never renders).
// n of them at the fit piece's pitch, so it sits in each clip.
use <../wago-221.scad>

name = "221-415";
n    = 1;
D = wagoDepth(name); L = wagoLength(name); H = wagoHeight(name); p = wagoPorts(name);
pitch = D + 2*(0.4 + 1.6) + 3;

for (i = [0 : n - 1])
  translate([i*pitch, 0, 0])
    difference()
    {
      wagoBody(name);
      //-- conductor entries on the -X face, and the lever split lines on top
      for (j = [0 : p - 1])
        translate([-D/2 - 1, (j - (p - 1)/2)*L/p, H*0.4]) rotate([0, 90, 0]) cylinder(d = L/p*0.55, h = 6, $fn = 16);
      for (j = [1 : p - 1])
        translate([-D/2 + 3, (j - p/2)*L/p - 0.3, H - 0.6]) cube([D - 4, 0.6, 1]);
    }
