// The JZK RS485 module as solids, for the catalogue (the Ghost is % so it never renders),
// seated on a 2.5 pedestal with its length along Y. part = "board" | "chips";
// n boards at the fit piece's pitch along X.
include <../../rs485-max485/rs485-max485.scad>

variant  = "jzk";
part     = "board";
n        = 1;
pitch    = 31;
pedestal = 2.5;

v   = rs485(variant);
top = pedestal + v[3];

module one()
{
  rotate([0, 0, 90])
  {
    if (part == "board") difference()
    {
      translate([-v[1]/2, -v[2]/2, pedestal]) cube([v[1], v[2], v[3]]);
      for (e = [[-1, v[5]], [1, v[6]]], i = [0 : e[1] - 1])
        translate([e[0]*(v[1]/2 - rs485PinEnd), (i - (e[1] - 1)/2)*rs485PinPitch, pedestal - 1])
          cylinder(d = 1.0, h = v[3] + 2, $fn = 12);
    }
    if (part == "chips")
      for (x = [-1, 1]) translate([x*5 - rs485ChipSize[0]/2, -rs485ChipSize[1]/2, top - 0.01]) cube(rs485ChipSize + [0, 0, 0.01]);
  }
}

for (i = [0 : n - 1]) translate([i*pitch, 0, 0]) one();
