// The posts on a 4 x 5 carrier, either side of a 602530 pack's cradle, for the catalogue.
// The bridge frame is turned 90 deg so the bar crosses the pack's width; the cradle's lead
// gap stays clear at the carrier's -X end.
use <../bridge.scad>
use <../../carrier/carrier.scad>
use <../../lipo-cradle/lipo-cradle.scad>

pack = "602530";
over = 25 + 2*(0.4 + 1.6);    // the cradle's outside across the pack: 29
span = brSpanFor(over);       // 36.5: 1 clear each side of the cradle
h    = brBarZ(6.0);           // 8: the pack is 6 thick, under 3 foam squashed by 1

carrierPlate(4, 5, open = false);
lipoCradle(pack);
rotate([0, 0, 90]) bridgePosts(span, h);
