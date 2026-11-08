//-----------------------------------------------------------------------
// WAGO 221 lever connector, held in a snap clip on the floor
//
// Push it down between two arms: the WAGO presses on the sloped lead-ins,
// the arms flex outward, and their hooks snap over its top edge at each
// short end. L-shaped corner stops locate the footprint. The wire-entry face
// is left open, with only a short stub at each corner so the outer ports
// stay clear. Lift the hooks with a fingernail to take it out.
//
// Three modules, all in the same frame:
//   wagoGhost()   the connector, for previews
//   wagoClip()    the plastic: two arms with hooks and four corner stops
//   wagoBody()    the connector as a plain solid (views, collision checks)
//
// On a carrier (carrier.scad's 10 mm M2.5 grid), in the carrier frame, which
// is this frame with Z = 0 on the plate's top:
//   wagoCarrier()        the plate with the clip on it, the plate opened under the body
//   wagoCarrierGhost()   the WAGO seated, and the screws, for previews
//   wagoCarrierSize()    [nx, ny]: the smallest plate whose screw heads clear the clip
//   wagoCarrierEntryX()  X of the wire-entry face, for the room the wires need
//
// Frame: origin on the floor top, at the centre of the WAGO's footprint.
// +X from the wire-entry face to the back (entries face -X), Y along the row
// of levers (the short ends at +-Y), Z up. Units: mm.
//
// Sizes: "221-412", "221-413", "221-415" (4 mm², 2/3/5 way), "221-425" (same
// body as the 415), "221-612", "221-613", "221-615" (6 mm²). Select by name;
// wagoSize(name) gives the row of wagoSizes.
//
// Use with `use <.../components/wago-221/wago-221.scad>`.
//-----------------------------------------------------------------------

use <../carrier/carrier.scad>   // the plate, its grid and hole list; it draws nothing

//-- [name, length (Y), depth (X), height levers closed, ports, strip length, max mm²]
//-- WAGO data sheets unless noted; see the README for each source
wagoSizes = [
  ["221-412", 13.2, 18.8, 8.6, 2, 11, 4],     // data sheet 03.10.2022 (brochure: 13.1 x 18.6 x 8.3)
  ["221-413", 18.7, 18.6, 8.3, 3, 11, 4],     // WAGO UK brochure, no data sheet found: CAL
  ["221-415", 30.0, 18.6, 8.4, 5, 11, 4],     // data sheet 19.04.2025; measured on a 221-425, controller project
  ["221-425", 30.0, 18.6, 8.4, 5, 11, 4],     // Green Range 415: measured 2026-10 (the controller project's base)
  ["221-612", 16.0, 21.1, 10.1, 2, 13, 6],    // data sheet 12.05.2023 (strip 12-14)
  ["221-613", 22.9, 21.1, 10.1, 3, 13, 6],    // data sheet 04.04.2025
  ["221-615", 36.7, 21.1, 10.1, 5, 13, 6],    // data sheet 07.04.2025
];

function wagoSize(name) = let (i = search([name], wagoSizes)[0])
  assert(i != [] && i != undef, str("unknown WAGO ", name)) wagoSizes[i];
function wagoLength(name) = wagoSize(name)[1];
function wagoDepth(name)  = wagoSize(name)[2];
function wagoHeight(name) = wagoSize(name)[3];
function wagoPorts(name)  = wagoSize(name)[4];
function wagoStrip(name)  = wagoSize(name)[5];

wagoDefault    = "221-415";

//-- The clip
wagoClearance  = 0.4;     // each end and side, footprint to arm / stop (controller base fitClearance)
wagoHook       = 0.7;     // CAL: how far each hook reaches in over the WAGO's top edge. Set by the fit piece
wagoHookGap    = 0.2;     // WAGO top to the hook's flat underside
wagoLeadIn     = 1.4;     // height of the sloped lead-in above the hook
wagoArmThick   = 1.6;     // PETG arm (controller base); flexes outward by the hook to let the WAGO in
wagoArmWidth   = 8;       // across X, centred on the depth
wagoStopH      = 3;       // corner stops, above the floor
wagoStopLeg    = 4;       // stop legs along the ends and the back
wagoStopWall   = 1.6;
wagoEntryStub  = 1.0;     // stop leg along the entry face: short, clear of the outer port

//-- height of the clip above the floor: room needed under a lid (the levers open to
//-- about 20 above the floor, CAL; you only open them with the WAGO out of the clip)
function wagoClipHeight(name = wagoDefault) = wagoHeight(name) + wagoHookGap + wagoLeadIn;

module wagoBody(name = wagoDefault)
{
  translate([-wagoDepth(name)/2, -wagoLength(name)/2, 0])
    cube([wagoDepth(name), wagoLength(name), wagoHeight(name)]);
}

module wagoGhost(name = wagoDefault)
{
  L = wagoLength(name); D = wagoDepth(name); H = wagoHeight(name); n = wagoPorts(name);
  %color("Orange") difference()
  {
    wagoBody(name);
    //-- a conductor entry per port, on the -X face
    for (i = [0 : n - 1])
      translate([-D/2 - 1, (i - (n - 1)/2)*L/n, H*0.4]) rotate([0, 90, 0]) cylinder(d = L/n*0.55, h = 6, $fn = 16);
  }
}

module wagoClip(name = wagoDefault, clearance = wagoClearance, hook = wagoHook)
{
  L = wagoLength(name); D = wagoDepth(name);
  c = clearance;
  H = wagoHeight(name) + wagoHookGap;           // hook underside
  t = wagoArmThick;
  reach = c + hook;                             // hook tip past the arm's inner face
  leg = min(wagoStopLeg, D/2 - wagoArmWidth/2 - 0.8);   // stays clear of the arm, so it flexes
  assert(leg >= 1.5, "WAGO too shallow for the corner stops beside the arms");

  //-- arms: inner face at L/2 + c, hook toward the WAGO, free from the floor so they flex
  for (m = [0, 1])
    mirror([0, m, 0])
      translate([-wagoArmWidth/2, L/2 + c, -0.01])
        rotate([90, 0, 90]) linear_extrude(wagoArmWidth)
          polygon([[0, 0], [t, 0], [t, H + 0.01 + wagoLeadIn], [0, H + 0.01 + wagoLeadIn],
                   [-reach, H + 0.01], [0, H + 0.01]]);
  //-- corner stops, outside the footprint: a leg along each end, one along the back,
  //-- and a short stub along the entry face
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*(D/2 + c), sy*(L/2 + c), -0.01])
      mirror([sx < 0 ? 1 : 0, 0, 0]) mirror([0, sy < 0 ? 1 : 0, 0])
      {
        //-- along the end (Y face): from the corner inward in -X
        translate([-leg, 0, 0]) cube([leg + wagoStopWall, wagoStopWall, wagoStopH + 0.01]);
        //-- along the side (X face): from the corner inward in -Y
        sideLeg = sx < 0 ? wagoEntryStub : leg;
        translate([0, -sideLeg, 0]) cube([wagoStopWall, sideLeg + wagoStopWall, wagoStopH + 0.01]);
      }
}

//-----------------------------------------------------------------------
// On a carrier
//
// The clip on a carrier plate (carrier.scad). The plate's screws go in from
// above, heads on the plate's top, so the clip's outline (body, arms and
// stops) must stay clear of every head: wagoCarrierSize() tries every plate
// up to wagoCarrierMax units a side and takes the smallest that fits the
// clip with each hole at least a head's radius + wagoCarrierKeep outside
// the clip's outline. Least area wins, then the narrower across X. The
// carrier is screwed down first; the WAGO clips in after.
//
// The plate is opened under the WAGO's body (a pocket inset wagoCarrierRim
// from its outline, and only where carrierOpening() would open the plate),
// so the arms and stops always stand on solid plate. Pass open = false for
// a solid plate.
//-----------------------------------------------------------------------

wagoCarrierScrew   = "M2.5";   // carrier's crScrew: its head sets the keep-out round each hole
wagoCarrierKeep    = 0.5;      // clip to the edge of a screw head, at least: room for the driver
wagoCarrierRim     = 3;        // solid plate left under the body's edges when the plate is open
wagoCarrierOpenMin = 8;        // no pocket narrower than this (carrier's crOpenMin)
wagoCarrierMax     = 8;        // largest plate side tried, in grid units

//-- the clip's outline: [across X, along Y], the stops' and arms' outer faces
function wagoClipOutline(name = wagoDefault, clearance = wagoClearance) =
  [wagoDepth(name) + 2*(clearance + wagoStopWall),
   wagoLength(name) + 2*(clearance + max(wagoArmThick, wagoStopWall))];

//-- does an nx x ny plate take the clip: the outline fits on it, and every hole's head
//-- (and the driver on it) is clear of the outline
function wagoCarrierFits(nx, ny, name = wagoDefault, clearance = wagoClearance) =
  let (s = crSize(nx, ny), o = wagoClipOutline(name, clearance),
       keep = screwHeadDia(wagoCarrierScrew)/2 + wagoCarrierKeep)
  o[0] <= s[0] + 0.01 && o[1] <= s[1] + 0.01 &&
  [for (p = crHoles(nx, ny)) if (abs(p[0]) < o[0]/2 + keep && abs(p[1]) < o[1]/2 + keep) p] == [];

//-- the smallest carrier for the clip: least area, then the narrower across X
function wagoCarrierSize(name = wagoDefault, clearance = wagoClearance) =
  let (fits = [for (ny = [1 : wagoCarrierMax], nx = [1 : wagoCarrierMax])
                 if (wagoCarrierFits(nx, ny, name, clearance)) [nx*ny, nx]])
  assert(len(fits) > 0, str("no carrier up to ", wagoCarrierMax, " x ", wagoCarrierMax, " takes a ", name))
  let (area = min([for (f = fits) f[0]]), nx = min([for (f = fits) if (f[0] == area) f[1]]))
  [nx, area/nx];

//-- X of the wire-entry face in the carrier frame: the wires need the strip length and
//-- their bend in front of it (allow 15 for 4 mm², 20 for 6 mm²), past the plate's edge
function wagoCarrierEntryX(name = wagoDefault) = -wagoDepth(name)/2;

//-- the plate with the clip on it. size: [nx, ny] to use a bigger plate than the smallest
//-- (it must still take the clip); open: pocket the plate under the body
module wagoCarrier(name = wagoDefault, clearance = wagoClearance, hook = wagoHook, open = true, size = undef)
{
  s = is_undef(size) ? wagoCarrierSize(name, clearance) : size;
  assert(wagoCarrierFits(s[0], s[1], name, clearance),
         str("a ", s[0], " x ", s[1], " carrier doesn't take a ", name, ": its screw heads meet the clip, or it is too small"));
  difference()
  {
    union()
    {
      carrierPlate(s[0], s[1], open = false);
      wagoClip(name, clearance, hook);
    }
    if (open) wagoCarrierPocket(name, s);
  }
}

//-- what wagoCarrier(open = true) cuts away: the plate under the body, inset rim from
//-- its outline, and never more than carrierOpening() would open
module wagoCarrierPocket(name = wagoDefault, size, rim = wagoCarrierRim)
{
  w = wagoDepth(name) - 2*rim; l = wagoLength(name) - 2*rim;
  if (w >= wagoCarrierOpenMin && l >= wagoCarrierOpenMin)
    intersection()
    {
      carrierOpening(size[0], size[1]);
      translate([-w/2, -l/2, -5]) cube([w, l, 10]);
    }
}

//-- the WAGO seated on its carrier, and the carrier's screws, for previews
module wagoCarrierGhost(name = wagoDefault, clearance = wagoClearance, how = "tap")
{
  s = wagoCarrierSize(name, clearance);
  wagoGhost(name);
  carrierScrewGhost(s[0], s[1], how);
}
