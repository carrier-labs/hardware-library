// One cradle with strap bars on a piece of floor, for the catalogue.
use <../lipo-cradle.scad>

name = "602530";
d = lipoDims(name);

translate([-d[2]/2 - 6, -d[1]/2 - 10, -2]) cube([d[2] + 12, d[1] + 20, 2]);
lipoCradle(name, strap = 10);
