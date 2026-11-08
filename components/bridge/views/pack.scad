// The 602530 pack as a solid, in its cradle on the station, for the catalogue (the Ghost is %
// so it never renders). Also the body for the collision check.
use <../../lipo-cradle/lipo-cradle.scad>

pack = "602530";
d = lipoDims(pack);

lipoBody(pack);
//-- the lead, out of the tab end
for (s = [-1, 1]) translate([-d[2]/2 - 8, s*1.2 - 0.6, d[0]/2 - 0.6]) cube([8.01, 1.2, 1.2]);
