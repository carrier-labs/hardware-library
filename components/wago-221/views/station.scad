// One clip on a piece of floor, for the catalogue.
use <../wago-221.scad>

name = "221-415";
L = wagoLength(name); D = wagoDepth(name);

translate([-D/2 - 5, -L/2 - 5, -2]) cube([D + 10, L + 10, 2]);
wagoClip(name);
