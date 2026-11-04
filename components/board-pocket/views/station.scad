// A pocket on a piece of floor, for the catalogue: the C3 Super Mini's.
use <../board-pocket.scad>

l = 22.52; w = 18; pad = [14, 10];
translate([-l/2 - 4, -w/2 - 4, -2]) cube([l + 8, w + 8, 2.01]);
boardPocketHolder(l, w, pad);
