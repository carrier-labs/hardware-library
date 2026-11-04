// The pack as a solid, for the catalogue (the Ghost is % so it never renders).
// n = 4 sets them out as on the fit piece.
use <../lipo-cradle.scad>

name = "602530";
pcm  = 0;
n    = 1;
d  = lipoDims(name);
lx = d[2] + pcm; ly = d[1];
out = 0.6 + 1.6;
px = lx + 2*out + 8;
py = ly + 2*(out + 2 + 2) + 4;
pos = [[0, 0], [px, 0], [0, py], [px, py]];

for (i = [0 : n - 1])
  translate([pos[i][0], pos[i][1], 0])
  {
    lipoBody(name, pcm);
    //-- the lead, out of the tab end
    for (s = [-1, 1]) translate([-d[2]/2 - pcm - 8, s*1.2 - 0.6, d[0]/2 - 0.6]) cube([8.01, 1.2, 1.2]);
  }
