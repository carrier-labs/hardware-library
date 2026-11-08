// The two 3 x 2 carriers of floor.scad, seated: on the bosses at the left, flat at the right.
use <../carrier.scad>

nx = 3; ny = 2;

translate([-20, 0, crSeatZ("tap")]) carrierPlate(nx, ny);
translate([20, 0, crSeatZ("nut")]) carrierPlate(nx, ny);
