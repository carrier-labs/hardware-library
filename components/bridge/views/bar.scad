// The bar where it sits snapped into the station's posts, for the catalogue: the moving part
// of the "How it goes on" view, and the body for the collision check. Same span and h as
// station.scad.
use <../bridge.scad>

over = 25 + 2*(0.4 + 1.6);
span = brSpanFor(over);       // 36.5
h    = brBarZ(6.0);           // 8

rotate([0, 0, 90]) bridgeBar(span, h);
