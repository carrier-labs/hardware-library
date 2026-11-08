//-----------------------------------------------------------------------
// LiPo pouch cell, in a low open cradle on the floor
//
// A low wall round the pack's footprint, with a gap on one side for the
// lead. The pack drops in and the lid (or a strap) keeps it down. Optional
// strap bars on the two long sides take a hook-and-loop strap over the pack:
// the strap goes down outside the wall, under the bar, and back up.
//
// Modules, all in the same frame:
//   lipoGhost()    the pack, for previews
//   lipoCradle()   the plastic: wall, lead gap, optional strap bars
//   lipoBody()     the pack as a plain solid (views, collision checks)
//
// On a carrier (carrier.scad's grid; the same frame, the plate's centre
// under the pack's centre, Z = 0 on the plate's top):
//   lipoCarrier()       the carrier plate, the cradle on it, and the posts of
//                       a bridge (bridge.scad) across the pack's width
//   lipoBridgeBar()     the bridge's bar, a separate print, drawn flat for export
//   lipoCarrierGhost()  the pack seated, and the bar with its foam, for previews
//   lipoCarrierPlan()   → [nx, ny, barAt]; lipoCarrierSize() → [nx, ny] the cradle and
//                       posts need; lipoCarrierHeight() → the bar's top above the plate
//
// Frame: origin on the floor top, at the centre of the pack's footprint.
// X along the pack's length (the tab and lead at -X), Y across its width,
// Z up. Units: mm.
//
// Sizes: the pouch code on the label, TTWWLL = thickness in tenths of a mm,
// width, length in whole mm (602530 = 6.0 x 25 x 30). Named packs are in
// lipoPacks; lipoCodeDims("503035") decodes any other code. Codes are the
// CELL: a pack with its protection board folded at the tab end is a few mm
// longer, and pouches swell, so measure the pack and use the allowances.
//
// Use with `use <.../components/lipo-cradle/lipo-cradle.scad>`.
//-----------------------------------------------------------------------

use <../carrier/carrier.scad>   // the plate and its grid, for lipoCarrier (functions and modules only)
use <../bridge/bridge.scad>     // the posts and bar over the pack

//-- [name, thickness, width, length, note]. The cell sizes from the code, except where measured
lipoPacks = [
  ["402030",  4.0, 20, 30, ""],
  ["502030",  5.0, 20, 30, ""],
  ["602530",  6.0, 25, 30, "500 mAh in use, controller project (label read 2026-10-30)"],
  ["503035",  5.0, 30, 35, ""],
  ["403048",  4.0, 30, 48, ""],
  ["603048",  6.0, 30, 48, ""],
  ["503450",  5.0, 34, 50, ""],
  ["603450",  6.0, 34, 50, ""],
  ["103450", 10.0, 34, 50, "the 10 is whole mm: 1800-2000 mAh"],
  ["902030",  9.0, 20, 30, ""],
  ["605060",  6.0, 50, 60, ""],
  ["803860",  8.0, 38, 60, "2000 mAh class"],
  ["PKCell-2000", 8.0, 38, 60, "Pi Hut 105187, 2000 mAh, vendor size; lead 100, JST-PH"],
];

//-- decode a six-digit code: TT in tenths of a mm (20 and up), WW, LL in mm.
//-- Codes starting with 1 (10-19) are ambiguous (103450 is 10 mm thick): put them in lipoPacks
function lipoCodeDims(code) =
  let (d = [for (c = code) ord(c) - 48],
       t = d[0]*10 + d[1])
  assert(len(code) == 6 && min(d) >= 0 && max(d) <= 9, str("not a six-digit pouch code: ", code))
  assert(t >= 20, str("ambiguous thickness in ", code, ": add it to lipoPacks"))
  [t/10, d[2]*10 + d[3], d[4]*10 + d[5]];

//-- [thickness, width, length] by name, or decoded from the code
function lipoDims(name) = let (i = search([name], lipoPacks)[0])
  (i != [] && i != undef) ? [lipoPacks[i][1], lipoPacks[i][2], lipoPacks[i][3]] : lipoCodeDims(name);

lipoDefault    = "602530";

//-- The cradle
lipoClearance  = 0.4;     // each side, pack to wall (controller base fitClearance). CAL by the fit piece
lipoWall       = 1.6;
lipoWallH      = 4;       // above the floor (controller base: 4 for a 6 thick pack)
lipoLeadGap    = 12;      // gap in the wall for the lead (controller base: 12)
lipoPcmAllow   = 0;       // added to the length at the tab end, for a protection board past the cell: CAL
lipoSwell      = 0.10;    // allow 10 % on the thickness for a pouch swelling with age
lipoTopGap     = 0.5;     // above the swollen pack, under the lid
//-- strap bars: off unless strap > 0 (the strap's width)
lipoStrapGap   = 2.0;     // wall to bar, and floor to bar: room for the strap
lipoStrapBar   = 2.0;     // bar thickness (Y) and height (Z)
lipoStrapPost  = 2.0;     // posts each end of the bar

//-- headroom over the floor the lid must clear
function lipoHeadroom(name = lipoDefault, swell = lipoSwell) = lipoDims(name)[0]*(1 + swell) + lipoTopGap;

module lipoBody(name = lipoDefault, pcm = lipoPcmAllow)
{
  d = lipoDims(name);
  translate([-d[2]/2 - pcm, -d[1]/2, 0]) cube([d[2] + pcm, d[1], d[0]]);
}

module lipoGhost(name = lipoDefault, pcm = lipoPcmAllow)
{
  d = lipoDims(name);
  %color("Silver") lipoBody(name, pcm);
  //-- the lead, out of the tab end
  for (s = [-1, 1])
    %color(s < 0 ? "Black" : "Red") translate([-d[2]/2 - pcm - 15, s*1.2 - 0.6, d[0]/2 - 0.6]) cube([15, 1.2, 1.2]);
}

//-- leadSide: "-x" (default, the tab end), "+x", "-y", "+y". strap: strap width, 0 for none
module lipoCradle(name = lipoDefault, clearance = lipoClearance, h = lipoWallH, leadSide = "-x",
                  gap = lipoLeadGap, pcm = lipoPcmAllow, strap = 0)
{
  d = lipoDims(name);
  lx = d[2] + pcm; ly = d[1];
  x0 = -d[2]/2 - pcm;                                    // pack's -X end
  c = clearance; w = lipoWall;
  assert(gap < min(lx, ly) - 2, "lead gap wider than the side it's in");
  translate([0, 0, -0.01])
    difference()
    {
      translate([x0 - c - w, -ly/2 - c - w, 0]) cube([lx + 2*(c + w), ly + 2*(c + w), h + 0.01]);
      translate([x0 - c, -ly/2 - c, -1]) cube([lx + 2*c, ly + 2*c, h + 2]);
      //-- lead gap, centred on its side
      if (leadSide == "-x") translate([x0 - c - w - 1, -gap/2, -1]) cube([w + 2, gap, h + 2]);
      if (leadSide == "+x") translate([x0 + lx + c - 1, -gap/2, -1]) cube([w + 2, gap, h + 2]);
      if (leadSide == "-y") translate([x0 + lx/2 - gap/2, -ly/2 - c - w - 1, -1]) cube([gap, w + 2, h + 2]);
      if (leadSide == "+y") translate([x0 + lx/2 - gap/2, ly/2 + c - 1, -1]) cube([gap, w + 2, h + 2]);
    }
  //-- strap bars on the long sides, across the middle of the pack
  if (strap > 0)
    for (m = [0, 1])
      mirror([0, m, 0])
        translate([x0 + lx/2, ly/2 + c + w + lipoStrapGap, -0.01])
          difference()
          {
            translate([-strap/2 - 0.5 - lipoStrapPost, 0, 0])
              cube([strap + 1 + 2*lipoStrapPost, lipoStrapBar, lipoStrapGap + lipoStrapBar + 0.01]);
            translate([-strap/2 - 0.5, -1, -1]) cube([strap + 1, lipoStrapBar + 2, lipoStrapGap + 1.01]);
          }
}

//-----------------------------------------------------------------------
// On a carrier: the cradle on a carrier plate, with a bridge across the pack
//
// The pack can't be hooked, so a bridge (bridge.scad) holds it: two posts on
// the plate either side of the cradle and a separate bar that snaps into
// them with a foam pad under it. The bar crosses the pack's WIDTH (the
// shorter span, posts beside the long sides): the lead gap is in an end
// wall, and a post across the length would stand in front of it. The strap
// bars stay off: the bridge does their job.
//
// The carrier frame is the cradle's: the plate's centre under the pack's
// centre, Z = 0 on the plate's top. The size comes from the pack: the
// smallest whole-unit plate the cradle and the posts fit on. Each hole must
// keep lipoCarrierKeep clear of all plastic, for the screw head and a driver;
// lipoCarrierPlan() picks the plate, growing it or moving the bar along the
// pack when a hole would land under the cradle or a post (long packs meet
// the mid holes of a 6+ unit side); `size` and `barAt` override it.
//-----------------------------------------------------------------------

lipoCarrierRim  = 3;      // plate left solid inside the cradle wall round the window under the pack (as the fit piece)
lipoCarrierKeep = 3;      // hole centre to any plastic on the plate: the M2.5 head is O4.4, and a driver must land on it
lipoBarMargin   = 1;      // posts' inner faces to the cradle's outside, each side
lipoWindowMin   = 8;      // no window under the pack narrower than this

//-- the carrier grid pitch (10), read through `use`
function lipoCrGrid() = crSize(1, 1)[0];

//-- the cradle's outside, [x0, x1, y0, y1], in the cradle frame
function lipoCradleBox(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow) =
  let (d = lipoDims(name), o = clearance + lipoWall)
  [-d[2]/2 - pcm - o, d[2]/2 + o, -d[1]/2 - o, d[1]/2 + o];

//-- the bridge over the pack: [span, h]. span between the post centres, across the pack's
//-- width with lipoBarMargin clear of the cradle; h the bar's underside, from the pack's top
function lipoBridge(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow) =
  let (b = lipoCradleBox(name, clearance, pcm))
  [brSpanFor(b[3] - b[2], lipoBarMargin), brBarZ(lipoDims(name)[0])];

//-- the smallest nx x ny carrier the cradle and the posts fit on
function lipoCarrierSize(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = 0) =
  let (b = lipoCradleBox(name, clearance, pcm), br = lipoBridge(name, clearance, pcm), g = lipoCrGrid(),
       xr = max(-b[0], b[1], abs(barAt) + brPostY()/2),         // posts are brPostY along the pack
       yr = max(b[3], br[0]/2 + brPostX()/2))                    // and brPostX along the span
  [ceil(2*xr/g - 0.001), ceil(2*yr/g - 0.001)];

//-- the top of the bar above the carrier's top: what a lid must clear
function lipoCarrierHeight(name = lipoDefault) = brHeight(lipoBridge(name)[1]);

//-- distance from point p to the box [x0, x1, y0, y1], 0 inside it
function lipoBoxDist(p, b) =
  let (dx = max(b[0] - p[0], p[0] - b[1], 0), dy = max(b[2] - p[1], p[1] - b[3], 0)) sqrt(dx*dx + dy*dy);

//-- the plastic's footprints on the plate: the cradle, the two posts, and the bar over the
//-- holes (as wide as the posts, which cover it): a driver must reach every head
function lipoCarrierBoxes(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = 0) =
  let (br = lipoBridge(name, clearance, pcm), px = brPostY()/2, py = brPostX()/2, bl = brBarLength(br[0])/2)
  [lipoCradleBox(name, clearance, pcm),
   [barAt - px, barAt + px,  br[0]/2 - py,  br[0]/2 + py],
   [barAt - px, barAt + px, -br[0]/2 - py, -br[0]/2 + py],
   [barAt - px, barAt + px, -bl, bl]];

//-- true when every hole of an nx x ny plate keeps lipoCarrierKeep from the plastic on it
function lipoCarrierClear(nx, ny, name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = 0) =
  let (boxes = lipoCarrierBoxes(name, clearance, pcm, barAt))
  min([for (p = crHoles(nx, ny), b = boxes) lipoBoxDist(p, b)]) >= lipoCarrierKeep;

//-- true when the cradle and posts fit on an nx x ny plate
function lipoCarrierFits(nx, ny, name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = 0) =
  let (s = lipoCarrierSize(name, clearance, pcm, barAt)) s[0] <= nx && s[1] <= ny;

//-- The plan for a pack: [nx, ny, barAt], the smallest plate (then the least bar offset)
//-- whose holes clear the plastic, trying the bar along the pack while its posts stay
//-- over it and plates up to two units bigger each way. Long packs need it: a side of 6+
//-- units has a hole at its middle, which a cradle longer than ~44 lands on
function lipoCarrierPlan(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow) =
  let (s0 = lipoCarrierSize(name, clearance, pcm), L = lipoDims(name)[2] + pcm,
       c = [for (i = [0 : 2], j = [0 : 2], a = [0 : floor(L/2 - brPostY()/2)])
             let (nx = s0[0] + i, ny = s0[1] + j)
             if (lipoCarrierFits(nx, ny, name, clearance, pcm, a) && lipoCarrierClear(nx, ny, name, clearance, pcm, a))
               [nx*ny*1000 + a, nx, ny, a]],
       k = [for (e = c) e[0]])
  assert(len(c) > 0, str("no carrier up to ", s0[0] + 2, " x ", s0[1] + 2, " clears its holes for ", name))
  let (best = c[search(min(k), k)[0]]) [best[1], best[2], best[3]];

//-- the window under the pack: the plate inside the cradle less a rim, and only what
//-- carrierOpening() allows (the frame and each hole's cell stay solid)
module lipoCarrierWindow(nx, ny, name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow)
{
  d = lipoDims(name); r = lipoCarrierRim;
  wx = d[2] + pcm - 2*r; wy = d[1] - 2*r;
  if (wx >= lipoWindowMin && wy >= lipoWindowMin)
    intersection()
    {
      translate([-d[2]/2 - pcm + r, -d[1]/2 + r, -lipoCrGrid()]) cube([wx, wy, 2*lipoCrGrid()]);
      carrierOpening(nx, ny);
    }
}

//-- The carrier: plate, cradle and bridge posts. size = [nx, ny] and barAt (the bar's
//-- position along the pack) default to lipoCarrierPlan(); open cuts the window under the
//-- pack. leadSide must be an end ("-x" or "+x"): the posts stand beside the long sides
module lipoCarrier(name = lipoDefault, clearance = lipoClearance, h = lipoWallH, leadSide = "-x",
                   gap = lipoLeadGap, pcm = lipoPcmAllow, size = undef, barAt = undef, open = true)
{
  plan = lipoCarrierPlan(name, clearance, pcm);
  s  = is_undef(size) ? [plan[0], plan[1]] : size;
  at = is_undef(barAt) ? plan[2] : barAt;
  br = lipoBridge(name, clearance, pcm);
  assert(leadSide == "-x" || leadSide == "+x", "lipoCarrier: the lead leaves at an end; the bridge posts stand beside the long sides");
  assert(lipoCarrierFits(s[0], s[1], name, clearance, pcm, at),
         str("lipoCarrier: ", name, " needs a ", lipoCarrierSize(name, clearance, pcm, at), " plate, not ", s));
  assert(lipoCarrierClear(s[0], s[1], name, clearance, pcm, at),
         str("lipoCarrier: a hole of a ", s[0], " x ", s[1], " plate lands under the cradle or a post: pass a bigger size, or move the bar with barAt"));
  difference()
  {
    carrierPlate(s[0], s[1], open = false);
    if (open) lipoCarrierWindow(s[0], s[1], name, clearance, pcm);
  }
  lipoCradle(name, clearance, h, leadSide, gap, pcm);
  translate([at, 0, 0]) rotate([0, 0, 90]) bridgePosts(br[0], br[1]);
}

//-- the pack seated on its carrier, and the bar with its squashed foam, for previews
module lipoCarrierGhost(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = undef)
{
  br = lipoBridge(name, clearance, pcm);
  at = is_undef(barAt) ? lipoCarrierPlan(name, clearance, pcm)[2] : barAt;
  lipoGhost(name, pcm);
  translate([at, 0, 0]) rotate([0, 0, 90]) bridgeGhost(br[0], br[1]);
}

//-- the bar as it sits snapped in on the carrier (views, collision checks)
module lipoBridgeBarSeated(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow, barAt = undef)
{
  br = lipoBridge(name, clearance, pcm);
  at = is_undef(barAt) ? lipoCarrierPlan(name, clearance, pcm)[2] : barAt;
  translate([at, 0, 0]) rotate([0, 0, 90]) bridgeBar(br[0], br[1]);
}

//-- The bar, a separate print: drawn flat on Z = 0 on its back, top face down, feet up,
//-- along X. Export this on its own
module lipoBridgeBar(name = lipoDefault, clearance = lipoClearance, pcm = lipoPcmAllow)
{
  br = lipoBridge(name, clearance, pcm);
  translate([0, 0, brHeight(br[1])]) rotate([180, 0, 0]) bridgeBar(br[0], br[1]);
}
