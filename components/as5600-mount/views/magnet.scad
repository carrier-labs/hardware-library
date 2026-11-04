// The magnet on the spindle tip, as a solid, for the catalogue.
include <../as5600-mount.scad>

tipZ = 11; magnet = "6x1";
translate([0, 0, as56MagnetFaceZ(tipZ, magnet)]) cylinder(d = as56MagnetD(magnet), h = as56MagnetT(magnet), $fn = 32);
