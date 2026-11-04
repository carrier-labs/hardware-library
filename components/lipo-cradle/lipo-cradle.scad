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
