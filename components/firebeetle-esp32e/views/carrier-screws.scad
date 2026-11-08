// The screws on the carrier as solids, for the catalogue.
// which = "board":   the four M2 x 6 button heads holding the board to its posts (move with it)
// which = "carrier": the six M2.5 x 6 holding the carrier down, heads on the plate
use <../firebeetle-esp32e.scad>
use <../../carrier/carrier.scad>
use <../../screw-post/screw-post.scad>

variant = "ESP32-E";
wall    = 2.4;
postH   = 4.7;
length  = 6;
which   = "board";

if (which == "board")
{
  s   = "M2";
  top = fbCarrierTop(variant, postH);
  translate(fbCarrierAt(variant, wall))
    for (h = fbHoles(variant, wall))
      translate([h[0], h[1], 0])
      {
        translate([0, 0, top]) cylinder(d = screwHeadDia(s), h = screwHeadH(s), $fn = 24);
        translate([0, 0, top - length]) cylinder(d = screwDia(s), h = length + 0.01, $fn = 16);
      }
}
if (which == "carrier")
{
  n = fbCarrierSize(variant, wall);
  carrierScrews(n[0], n[1]);
}
