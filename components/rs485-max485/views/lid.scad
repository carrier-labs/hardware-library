// Two strips of lid with their pads, for the catalogue.
include <../rs485-max485.scad>

variant = "jzk";
lidZ    = 10;      // lid's inner face above the floor
v       = rs485(variant);
xs      = [-v[1]/2 + rs485PadInset + rs485PadLen/2, v[1]/2 - rs485PadInset - rs485PadLen/2];
for (x = xs) translate([x - rs485PadLen/2 - 1, -v[2]/2 - 4, lidZ]) cube([rs485PadLen + 2, v[2] + 8, 2]);
rs485LidPads(lidZ, variant);
