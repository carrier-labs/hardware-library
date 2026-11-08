// A 3 x 4 carrier sitting on the 6 x 6 bench, for the catalogue: flat on the bench,
// its -X -Y hole on bench grid point (2, 1).
use <../carrier.scad>

bx = 6; by = 6;
nx = 3; ny = 4;
at = crOnBench(bx, by, nx, ny, 2, 1);

translate([at[0], at[1], crSeatZ("bench")]) carrierPlate(nx, ny);
