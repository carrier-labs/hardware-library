// One holder on a piece of floor, for the catalogue.
include <../rs485-max485.scad>

variant = "jzk";
v = rs485(variant);
translate([-v[1]/2 - 4, -v[2]/2 - 4, -2]) cube([v[1] + 8, v[2] + 8, 2.01]);
rs485Holder(variant);
