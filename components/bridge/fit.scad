//-----------------------------------------------------------------------
// Fit piece: four pairs of posts on one strip, marked 1 to 4 dots, each
// with its own bar printed beside it on its back, feet up. The bar is
// joined to the strip by a 0.4 x 0.8 breakaway sprue, so the piece is one
// part until you twist the bars off. Snap each bar down into its posts,
// then press a barb in with a thumbnail and lift it out again.
//
//   1  foot clearance 0.1
//   2  foot clearance 0.2
//   3  foot clearance 0.3
//   4  foot clearance 0.4
//
// Barb 0.5 throughout; span 20, bar 8 above the strip (a 602530 pack under
// 3 foam squashed by 1). Prints base down, as exported, no supports.
// Units: mm.
//-----------------------------------------------------------------------

use <bridge.scad>
use <../../util/marks.scad>

span      = 20;
h         = 8;         // brBarZ(6.0)
width     = 8;
baseThick = 1.6;
pitch     = 30;        // the longest bar is 26.1
rim       = 2;         // strip past the posts
markRoom  = 5;         // strip past the posts on the -Y side, for the dots
barGap    = 1.0;       // strip edge to the bar: the sprue's length
sprue     = [0.4, 0.8];   // sprue section: X width, Z height, from the bed up

stations  = [0.1, 0.2, 0.3, 0.4];   // foot clearance

n     = len(stations);
pyMax = max([for (c = stations) brPostY(width, c)]);
y0    = -pyMax/2 - rim - markRoom;  // strip's -Y edge
y1    =  pyMax/2 + rim;             // strip's +Y edge; the bars lie beyond it
barY  = y1 + barGap + width/2;      // bar centre line

difference()
{
  union()
  {
    translate([-pitch/2, y0, -baseThick]) cube([n*pitch, y1 - y0, baseThick]);
    for (i = [0 : n - 1])
      translate([i*pitch, 0, 0])
      {
        bridgePosts(span, h, width, clearance = stations[i]);
        //-- its bar, on its back on the bed: top face down, feet up
        translate([0, barY, h + 2.0 - baseThick]) rotate([180, 0, 0])
          bridgeBar(span, h, width, clearance = stations[i]);
        //-- the sprue, strip edge to the bar's side
        translate([-sprue[0]/2, y1 - 0.01, -baseThick]) cube([sprue[0], barGap + 0.02, sprue[1]]);
      }
  }
  for (i = [0 : n - 1])
    translate([i*pitch, 0, 0])
    {
      //-- open floor between the posts
      ix = brInside(span, stations[i])/2 - rim;
      translate([-ix, -width/2, -baseThick - 1]) cube([2*ix, width, baseThick + 2]);
      translate([0, y0 + markRoom/2, 0]) markDots(i + 1);
    }
}
