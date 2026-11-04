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
