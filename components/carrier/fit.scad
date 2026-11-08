//-----------------------------------------------------------------------
// Fit piece: a 5 x 2 piece of bench plate (4 thick, chamfered) with four
// tap holes along the back row, marked 1 to 4 dots in front of each, and
// one O2.9 clearance hole at the end. Drive an M2.5 x 6 into each tap hole:
// the right one takes a thread firmly without splitting the plate, and the
// screw goes in with a driver, not a wrench. Drop a screw through the 2.9
// hole: it should fall through.
//
//   1  tap hole 1.9
//   2  tap hole 2.0
//   3  tap hole 2.1  (the standard, and screw-post's table)
//   4  tap hole 2.2
//   "2.9"  clearance hole, the carrier's hole size
//
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

include <carrier.scad>
use <../../util/marks.scad>

taps  = [1.9, 2.0, 2.1, 2.2];
clear = crHole;            // 2.9
nx    = 5;
ny    = 2;
thick = crBenchThick;      // 4
grid  = crGrid;

difference()
{
  benchSlab(nx, ny, thick);
  for (i = [0 : len(taps) - 1])
  {
    x = (i - (nx - 1)/2)*grid;
    translate([x, grid/2, 0]) benchTapHole(taps[i], thick);
    translate([x, -grid/2, 0]) markDots(i + 1);
  }
  x = ((nx - 1) - (nx - 1)/2)*grid;
  translate([x, grid/2, -thick - 1]) cylinder(d = clear, h = thick + 2, $fn = 24);
  translate([x, -grid/2, -0.6]) linear_extrude(1)
    text(str(clear), size = 3, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}
