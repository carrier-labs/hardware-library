//-----------------------------------------------------------------------
// Carrier: a small printed plate on a 10 mm M2.5 grid that a bought part's
// holder sits on. The box floor offers the grid points a design uses; a
// bench plate is the whole grid, for prototyping. A carrier never knows
// which it is on.
//
// The standard:
//   grid 10, M2.5. A carrier is nx x ny whole units (5 x 2 = 50 x 20), 1.6
//   thick, with O2.9 holes on the grid points inset 5 from each edge (the
//   four corners; a side 6+ units long also gets a hole near its middle).
//   Fixing from above through the carrier, either
//     "tap"   the screw cuts its own thread in a O2.1 hole in a 4 tall O6
//             boss on the floor: carriers stand on their bosses, 4 mm of
//             wire room under them. M2.5 x 6. The default
//     "nut"   carrier flat on the floor, screw through, M2.5 nut in a trap
//             under a 2.4+ floor (screw-post's screwPostFloorCut)
//     "bench" flat on a bench plate: 4 thick, O2.1 tap holes on every grid
//             point, chamfered edge. No nuts
//
// Modules, all in the carrier frame unless said:
//   carrierPlate(nx, ny, open)   the plate with its holes; open pockets the
//                                middle to a frame to save plastic
//   carrierGhost(nx, ny)         the plate as a ghost, for other parts' previews
//   carrierScrews(nx, ny, how)   the screws as solids (views, collision checks)
//   carrierScrewGhost(nx, ny, how)  the same as a ghost, nuts too for "nut"
//   carrierBosses(nx, ny)        FLOOR frame: the "tap" bosses, add to the floor
//   carrierFloorCut(nx, ny, floorThick, how)  FLOOR frame: subtract from the
//                                floor: the pilot holes' run-on ("tap") or
//                                the nut traps ("nut"). Always subtract it
//   benchPlate(nx, ny)           FLOOR frame: a bench plate, top face at Z = 0
//
// Functions: crSize(nx, ny) → [L, W]; crHoles(nx, ny) → [[x, y], ...];
//   crSeatZ(how) → the carrier's top above the floor top (5.6 tap, 1.6 nut
//   or bench); crOnBench(bx, by, nx, ny, i, j) → where to put a carrier on a
//   bench so its -X -Y hole is on bench grid point (i, j).
//
// Carrier frame: origin at the plate's centre, Z = 0 on the plate's TOP
// face, so a component's holder frame (floor top) drops straight onto it;
// the plate is Z = -1.6 .. 0. X along nx, Y along ny. Units: mm.
// Floor frame: origin on the floor top under the carrier's centre, Z up.
// The carrier goes at Z = crSeatZ(how) above it.
//
// Use with `use <.../components/carrier/carrier.scad>`. A part's carrier
// is a wrapper: carrierPlate(5, 2, open = false); then its holder at Z = 0.
//-----------------------------------------------------------------------

include <../screw-post/screw-post.scad>   // its table gives the hole sizes; it draws nothing

//-- The standard (decided 2026-11-08; the hole sizes come from screw-post's table)
crGrid       = 10;      // grid pitch
crScrew      = "M2.5";  // screw-post size: clearance hole 2.9, tap hole 2.1, boss O6
crPlate      = 1.6;     // carrier plate thickness
crInset      = 5;       // holes this far in from each edge: on the grid points
crMidFrom    = 6;       // a side this many units or longer also gets a hole near its middle
crBossH      = 4;       // "tap" bosses: the carrier stands on them, wires run under it
crBossDia    = 6;       // = screw-post's post O for M2.5
crBenchThick = 4;       // bench plate
crBenchChamfer = 0.8;   // on the bench plate's top and bottom edges
crScrewLen   = 6;       // the standard screw, M2.5 x 6, under the head
crHow        = "tap";   // the default fixing
crHole = screwDia(crScrew) + screwHoleClear;        // 2.9: clearance hole through the carrier
crTap  = screwSize(crScrew)[6] + screwTapClear;      // 2.1: CAL, the fit piece decides (1.9 .. 2.2)

//-- Pilot holes
crTapRunout  = 0.5;     // pilot hole past the screw's tip, so it never bottoms
crFloorSkin  = 0.6;     // floor left whole under a pilot hole that runs into it

//-- The open plate
crFrame      = 3;       // solid border round the opening
crRib        = 2;       // rib across the opening at each mid hole pair
crOpenMin    = 8;       // no opening narrower than this; smaller plates stay solid
crFloorNut   = 2.4;     // thinnest floor for "nut": the M2.5 nut (2.0) and 0.4 over it

//-- [L, W] of an nx x ny carrier
function crSize(nx, ny) = [nx*crGrid, ny*crGrid];

//-- grid point i of n along an axis, from the plate's centre
function crCoord(n, i) = (i - (n - 1)/2)*crGrid;

//-- the hole indices along a side of n units: both ends, and near the middle from crMidFrom
//-- up (a side of even length puts it on the grid point just below the middle)
function crAxis(n) = n == 1 ? [0] : n >= crMidFrom ? [0, floor((n - 1)/2), n - 1] : [0, n - 1];

//-- every hole of an nx x ny carrier: the corners, and the mid pairs on long sides.
//-- Never one in the middle of the plate
function crHoles(nx, ny) =
  assert(nx >= 1 && ny >= 1 && nx == floor(nx) && ny == floor(ny), "a carrier is whole grid units")
  [for (i = crAxis(nx), j = crAxis(ny))
    if (i == 0 || i == nx - 1 || j == 0 || j == ny - 1) [crCoord(nx, i), crCoord(ny, j)]];

//-- every grid point of an nx x ny plate (the bench's holes)
function crGridPoints(nx, ny) = [for (i = [0 : nx - 1], j = [0 : ny - 1]) [crCoord(nx, i), crCoord(ny, j)]];

//-- the carrier's top face above the floor top, by fixing
function crSeatZ(how = crHow) =
  assert(how == "tap" || how == "nut" || how == "bench", str("unknown carrier fixing ", how))
  crPlate + (how == "tap" ? crBossH : 0);

//-- how deep a pilot hole goes from the boss top: the screw past the plate, plus run-out
function crTapDepth(screwLen = crScrewLen) = screwLen - crPlate + crTapRunout;

//-- how far the pilot hole runs on into the floor under a boss (0.9 for M2.5 x 6)
function crTapIntoFloor(screwLen = crScrewLen) = max(crTapDepth(screwLen) - crBossH, 0);

//-- the centre of an nx x ny carrier on a bx x by bench, with its -X -Y hole on bench grid
//-- point (i, j), counted from the bench's -X -Y corner
function crOnBench(bx, by, nx, ny, i, j) =
  assert(i >= 0 && j >= 0 && i + nx <= bx && j + ny <= by, "carrier off the bench")
  [crCoord(bx, i) + (nx - 1)*crGrid/2, crCoord(by, j) + (ny - 1)*crGrid/2];

//-- the plate. open: the middle is cut away to a frame, keeping each hole's grid cell and
//-- a crFrame border solid, with a rib across at each mid hole pair. Wrappers set
//-- open = false when their holder needs the area
module carrierPlate(nx, ny, open = true, hole = crHole)
{
  s = crSize(nx, ny); L = s[0]; W = s[1];
  difference()
  {
    translate([-L/2, -W/2, -crPlate]) cube([L, W, crPlate]);
    for (p = crHoles(nx, ny))
      translate([p[0], p[1], -crPlate - 1]) cylinder(d = hole, h = crPlate + 2, $fn = 24);
    if (open) carrierOpening(nx, ny);
  }
}

//-- what carrierPlate(open = true) cuts away: the inside of the frame, less the hole cells and ribs
module carrierOpening(nx, ny)
{
  s = crSize(nx, ny); L = s[0]; W = s[1];
  //-- the main window between the end cells is L - 2 cells by W - 2 frames (or the other way round)
  canOpen = (L - 2*crGrid >= crOpenMin && W - 2*crFrame >= crOpenMin) ||
            (W - 2*crGrid >= crOpenMin && L - 2*crFrame >= crOpenMin);
  if (canOpen)
    difference()
    {
      translate([-L/2 + crFrame, -W/2 + crFrame, -crPlate - 1]) cube([L - 2*crFrame, W - 2*crFrame, crPlate + 2]);
      for (p = crHoles(nx, ny))
        translate([p[0] - crGrid/2, p[1] - crGrid/2, -crPlate - 2]) cube([crGrid, crGrid, crPlate + 4]);
      if (nx >= crMidFrom)
        translate([crCoord(nx, crAxis(nx)[1]) - crRib/2, -W/2, -crPlate - 2]) cube([crRib, W, crPlate + 4]);
      if (ny >= crMidFrom)
        translate([-L/2, crCoord(ny, crAxis(ny)[1]) - crRib/2, -crPlate - 2]) cube([L, crRib, crPlate + 4]);
    }
}

//-- the plate as a ghost, for a part's preview on its carrier
module carrierGhost(nx, ny)
{
  %color("LightSteelBlue") carrierPlate(nx, ny, open = false);
}

//-- the screws as solids: heads on the plate's top, shanks down through it
module carrierScrews(nx, ny, how = crHow, length = crScrewLen)
{
  for (p = crHoles(nx, ny))
    translate([p[0], p[1], 0])
    {
      cylinder(d = screwHeadDia(crScrew), h = screwHeadH(crScrew), $fn = 24);
      translate([0, 0, -length]) cylinder(d = screwDia(crScrew), h = length + 0.01, $fn = 16);
    }
}

//-- the screws, and for "nut" the nuts under a floor of floorThick, as a ghost
module carrierScrewGhost(nx, ny, how = crHow, length = crScrewLen, floorThick = crFloorNut)
{
  %color("Silver") carrierScrews(nx, ny, how, length);
  if (how == "nut")
    for (p = crHoles(nx, ny))
      %color("DimGray") translate([p[0], p[1], -crPlate - floorThick]) rotate([0, 0, 30])
        cylinder(d = screwNutAF(crScrew)/cos(30), h = screwNutH(crScrew), $fn = 6);
}

//-- FLOOR frame. The "tap" bosses: O6, 4 tall, pilot hole right through (carrierFloorCut
//-- runs it on into the floor to the screw's depth), lead-in at the top so the screw starts square
module carrierBosses(nx, ny, h = crBossH, dia = crBossDia, tap = crTap)
{
  for (p = crHoles(nx, ny))
    translate([p[0], p[1], 0])
      difference()
      {
        translate([0, 0, -0.01]) cylinder(d = dia, h = h + 0.01, $fn = 40);
        translate([0, 0, -1]) cylinder(d = tap, h = h + 2, $fn = 24);
        translate([0, 0, h - 0.4]) cylinder(d1 = tap, d2 = tap + 0.8, h = 0.41, $fn = 24);
      }
}

//-- FLOOR frame. Subtract from the floor, whichever fixing:
//--   "tap"  the pilot hole's run-on below each boss, if the screw reaches that far
//--          (0.9 for M2.5 x 6; the floor keeps crFloorSkin under it)
//--   "nut"  a clearance hole and nut trap at each hole (screwPostFloorCut)
module carrierFloorCut(nx, ny, floorThick, how = crHow, tap = crTap, screwLen = crScrewLen)
{
  assert(how == "tap" || how == "nut", str("carrierFloorCut: fixing is tap or nut, not ", how));
  deep = crTapIntoFloor(screwLen);
  assert(how != "tap" || floorThick >= deep + crFloorSkin,
         str("floor too thin for an M2.5 x ", screwLen, " pilot hole: needs ", deep + crFloorSkin));
  for (p = crHoles(nx, ny))
    translate([p[0], p[1], 0])
      if (how == "tap") { if (deep > 0) translate([0, 0, -deep]) cylinder(d = tap, h = deep + 1, $fn = 24); }
      else screwPostFloorCut(crScrew, floorThick, "nut");
}

//-- FLOOR frame. The bench plate: nx x ny units, its top face at Z = 0, a tap hole on
//-- every grid point. Carriers screw straight to it
module benchPlate(nx, ny, thick = crBenchThick, tap = crTap, chamfer = crBenchChamfer)
{
  difference()
  {
    benchSlab(nx, ny, thick, chamfer);
    for (p = crGridPoints(nx, ny)) translate([p[0], p[1], 0]) benchTapHole(tap, thick);
  }
}

//-- the bench's slab without holes, chamfered top and bottom (the fit piece uses it too)
module benchSlab(nx, ny, thick = crBenchThick, chamfer = crBenchChamfer)
{
  s = crSize(nx, ny); L = s[0]; W = s[1]; c = chamfer;
  hull()
  {
    translate([-L/2 + c, -W/2 + c, -thick]) cube([L - 2*c, W - 2*c, thick]);
    translate([-L/2, -W/2, -thick + c]) cube([L, W, thick - 2*c]);
  }
}

//-- one tap hole through a bench of thick, with the lead-in, on the axis at the top face
module benchTapHole(tap = crTap, thick = crBenchThick)
{
  translate([0, 0, -thick - 1]) cylinder(d = tap, h = thick + 2, $fn = 24);
  translate([0, 0, -0.4]) cylinder(d1 = tap, d2 = tap + 0.8, h = 0.41, $fn = 24);
}
