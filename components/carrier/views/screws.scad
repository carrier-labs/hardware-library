// The screws (and nuts) as solids, for the catalogue (the Ghost is % so it never renders).
// scene = "bench": the 3 x 4 carrier's four screws on the bench
// scene = "floor": the screws of both carriers in floor.scad, and the nuts under the "nut" one
include <../carrier.scad>

scene = "bench";

if (scene == "bench")
{
  at = crOnBench(6, 6, 3, 4, 2, 1);
  translate([at[0], at[1], crSeatZ("bench")]) carrierScrews(3, 4);
}
if (scene == "floor")
{
  floorThick = 2.4;
  translate([-20, 0, crSeatZ("tap")]) carrierScrews(3, 2);
  translate([20, 0, crSeatZ("nut")]) carrierScrews(3, 2);
  for (p = crHoles(3, 2))
    translate([20 + p[0], p[1], -floorThick]) rotate([0, 0, 30])
      cylinder(d = screwNutAF(crScrew)/cos(30), h = screwNutH(crScrew), $fn = 6);
}
