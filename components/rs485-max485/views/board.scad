// The board as solids, for the catalogue (the Ghost is % so it never renders).
// part = "board" | "chips" | "foam" (squashed, under the lid pads); n boards at the fit piece's pitch
include <../rs485-max485.scad>

variant = "jzk";
part    = "board";
n       = 1;
pitch   = 30;
squeezes = [0.5, 1.0, 1.5, 2.0];   // as fit.scad (n > 1)

v   = rs485(variant);
top = rs485Top(variant);
module one(sq)
{
  if (part == "board") difference()
  {
    translate([-v[1]/2, -v[2]/2, top - v[3]]) cube([v[1], v[2], v[3]]);
    for (e = [[-1, v[5]], [1, v[6]]], i = [0 : e[1] - 1])
      translate([e[0]*(v[1]/2 - rs485PinEnd), (i - (e[1] - 1)/2)*rs485PinPitch, top - v[3] - 1])
        cylinder(d = 1.0, h = v[3] + 2, $fn = 12);
  }
  if (part == "chips")
  {
    for (x = [-1, 1]) translate([x*5 - rs485ChipSize[0]/2, -rs485ChipSize[1]/2, top - 0.01]) cube(rs485ChipSize + [0, 0, 0.01]);
    if (!is_undef(v[7])) translate([-v[1]/2 + 3, -v[7][1]/2, top - 0.01]) cube(v[7]);
  }
  if (part == "foam")
  {
    xs = n == 1 ? [-v[1]/2 + rs485PadInset + rs485PadLen/2, v[1]/2 - rs485PadInset - rs485PadLen/2]
                : [v[1]/2 - rs485PadInset - rs485PadLen/2];
    for (x = xs) translate([x - rs485PadLen/2, -(v[2] - 3)/2, top]) cube([rs485PadLen, v[2] - 3, bpFoam - sq - 0.01]);
  }
}
if (n == 1) one(bpSqueeze);
else for (i = [0 : n - 1]) translate([0, i*pitch, 0]) one(squeezes[i]);
