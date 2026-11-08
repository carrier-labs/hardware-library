//-----------------------------------------------------------------------
// TTL-to-RS485 module (MAX485 and friends), on the floor
//
// These modules have no mounting holes. The board sits on a taped pedestal
// inside an outline pocket (board-pocket), with lead gaps at both ends (bus
// end and logic end) and in the long sides. In a closed box two lid pads
// press foam onto it, one inboard of each end's pin row.
//
// Modules, all in the same frame:
//   rs485Ghost()     the board, its chips, pin holes and any screw terminal
//   rs485Holder()    the plastic: pedestal and outline pocket, add to the floor
//   rs485LidPads()   blocks under the lid that press foam onto the board
//
// On a carrier (carrier.scad), the board is hooked, not taped: the same
// pedestal with no tape, the end walls with their lead gaps, no side walls,
// and two snap hooks (snap-hook.scad) over each long edge.
//   rs485Carrier()       the carrier plate with the holder on it, as plastic
//   rs485CarrierGhost()  the board seated on it, and the screws, for previews
//   rs485CarrierSize()   [nx, ny] grid units; rs485CarrierHeight() the top
//                        of the hooks, which a lid must clear
//
// Frame: origin on the floor top under the centre of the board. X along the
// board, bus end (A/B) at -X, logic end (VCC/TXD/RXD/GND) at +X. Z up. Units: mm.
// The carrier modules use the carrier frame: the same, with the plate's top
// at Z = 0 (the plate is Z = -1.6 .. 0), the plate's centre under the board's.
//
// Sizes: pick a row of rs485Variants by name.
//-----------------------------------------------------------------------

//-- included, not used, so their default values (bpTape, bpClearance, crPlate, shReach...) are in
//-- scope here. None of them draws anything
include <../board-pocket/board-pocket.scad>
include <../carrier/carrier.scad>
include <../snap-hook/snap-hook.scad>

//-- [name, length, width, pcb, tallest SMD, bus pins, logic pins, screw terminal [l, w, h] or undef]
rs485Variants = [
  //-- JZK 5-pack B09VGJCJKQ, auto-direction (MAX485 + CD4069). Outline measured 2026-10-21;
  //-- PCB CAL (probably 1.6). Bus end: A+ B- earth, bare holes. Logic: VCC TXD RXD GND
  ["jzk",    43.0, 15.5,  1.6, 2.0, 3, 4, undef],
  //-- XY-017 auto-direction (WINGONEER manual, manuals.plus/asin/B06XHH6B6R): 42.8 x 15.22 x 0.8.
  //-- Looks like the same family as the JZK; pin counts CAL
  ["xy-017", 42.8, 15.22, 0.8, 2.0, 3, 4, undef],
  //-- Classic blue MAX485 module (HW-0519 style): 44 x 14 on most listings (some 45 x 15, 46 x 12),
  //-- 4-pin header each end (RO RE DE DI / VCC B A GND), 2-way 5.08 screw terminal at the bus end.
  //-- PCB, terminal size and its place on the board CAL
  ["max485", 44.0, 14.0,  1.6, 2.0, 4, 4, [7.5, 10.2, 10.0]],
];
rs485Variant  = "jzk";

rs485PinPitch = 2.54;
rs485PinEnd   = 1.5;      // CAL: pin row centre from the board's end
rs485ChipSize = [5.0, 6.0, 1.75];   // SOIC-8, ghost only; placed either side of the middle (CAL)
//-- Holder (the controller project's receiver.scad / rack-end.scad)
rs485PadEnd   = 8.5;      // pedestal stops this far from each end: clear of the pin stubs
rs485PadSide  = 3.25;     // and this far from each long side (26 x 9 on the JZK)
rs485EndGap   = 10;       // lead gap at the ends: the 4-pin row is 7.62 across, plus wire
rs485SideGap  = 6;
rs485PadInset = 6;        // lid pads: this far inboard of each end
rs485PadLen   = 6;
//-- Carrier: the board hooked down, no tape
rs485HookX    = 10;       // the two hook pairs sit this far either side of the board's centre along X:
                          // clear of the chips, and their relief slots stop 1 short of the corner hole cells

function rs485(name = rs485Variant) = let (i = search([name], rs485Variants)[0])
  assert(i != [] && i != undef, str("unknown RS485 variant ", name)) rs485Variants[i];
function rs485Pad(variant = rs485Variant) = let (v = rs485(variant))
  [v[1] - 2*rs485PadEnd, v[2] - 2*rs485PadSide];
//-- PCB top above the floor
function rs485Top(variant = rs485Variant, pedestal = bpPedestal, tape = bpTape) =
  boardPocketZ(pedestal, tape) + rs485(variant)[3];

module rs485Ghost(variant = rs485Variant, pedestal = bpPedestal, tape = bpTape)
{
  v   = rs485(variant);
  top = rs485Top(variant, pedestal, tape);
  boardPocketGhost(v[1], v[2], v[3], rs485Pad(variant), pedestal, tape);
  for (x = [-1, 1])
    %color("Black") translate([x*5 - rs485ChipSize[0]/2, -rs485ChipSize[1]/2, top]) cube(rs485ChipSize);
  //-- pin rows across each end
  for (e = [[-1, v[5]], [1, v[6]]], i = [0 : e[1] - 1])
    %color("Gold") translate([e[0]*(v[1]/2 - rs485PinEnd), (i - (e[1] - 1)/2)*rs485PinPitch, top - v[3] - 0.01])
      cylinder(d = 1.0, h = v[3] + 0.02, $fn = 12);
  if (!is_undef(v[7]))
    %color("RoyalBlue") translate([-v[1]/2 + 3, -v[7][1]/2, top]) cube(v[7]);
}

module rs485Holder(variant = rs485Variant, sides = "gap", clearance = bpClearance,
                   pedestal = bpPedestal, tape = bpTape, rise = bpRise)
{
  v = rs485(variant);
  boardPocketHolder(v[1], v[2], rs485Pad(variant), sides,
                    [rs485EndGap, rs485EndGap, rs485SideGap, rs485SideGap],
                    clearance, pedestal, tape, bpWall, rise);
}

//-- lidZ: the lid's inner face above the floor top. With a screw terminal, the bus-end pad
//-- moves inboard of it
module rs485LidPads(lidZ, variant = rs485Variant, foam = bpFoam, squeeze = bpSqueeze,
                    pedestal = bpPedestal, tape = bpTape)
{
  v   = rs485(variant);
  top = rs485Top(variant, pedestal, tape);
  busIn = is_undef(v[7]) ? rs485PadInset : 3 + v[7][0] + 1;
  for (x = [-v[1]/2 + busIn + rs485PadLen/2, v[1]/2 - rs485PadInset - rs485PadLen/2])
    boardLidPad([rs485PadLen, v[2] - 3], [x, 0], top, lidZ, foam, squeeze);
}

//-----------------------------------------------------------------------
// On a carrier. Carrier frame: origin at the plate's centre, Z = 0 on the
// plate's top, the board along X as above. The board sits on the pedestal
// with no tape and the end walls stop it along X; two snap hooks over each
// long edge hold it down and centre it across. Push the board down to fit
// it; lift one end to take it out (the hooks' 45 deg undersides cam open).
//-----------------------------------------------------------------------

//-- the board's top above the plate: pedestal + PCB, no tape (4.1 on the JZK)
function rs485CarrierTop(variant = rs485Variant, pedestal = bpPedestal) = pedestal + rs485(variant)[3];

//-- the carrier in grid units, the smallest that takes the holder: along X the pocket's end
//-- walls, across Y the hooks and their relief slots (5 x 3 for every variant in the table)
function rs485CarrierSize(variant = rs485Variant, clearance = bpClearance, wall = bpWall, pedestal = bpPedestal,
                          reach = shReach, hookClear = shClearance, thick = shThick, relief = shRelief) =
  let (v = rs485(variant), top = rs485CarrierTop(variant, pedestal),
       L = v[1] + 2*(clearance + wall),
       W = v[2] + 2*snapHookClear(top, reach, hookClear, thick, relief))
  [ceil(L/crGrid - 1e-6), ceil(W/crGrid - 1e-6)];

//-- the tallest plastic above the plate: the hooks' tops (6.35 on the JZK, 11.15 with tabs)
function rs485CarrierHeight(variant = rs485Variant, tab = false, pedestal = bpPedestal,
                            reach = shReach, hookClear = shClearance) =
  snapHookHeight(rs485CarrierTop(variant, pedestal), reach, hookClear, tab);

//-- The carrier with its holder, as plastic. tab: release tabs on the +Y pair of hooks.
//-- hookClear is the hook arm to the board's edge (snap-hook's clearance); clearance is the
//-- end walls to the board's ends (board-pocket's)
module rs485Carrier(variant = rs485Variant, tab = false, hookX = rs485HookX, reach = shReach,
                    hookClear = shClearance, thick = shThick, width = shWidth, relief = shRelief,
                    clearance = bpClearance, pedestal = bpPedestal, rise = bpRise)
{
  v   = rs485(variant);
  top = rs485CarrierTop(variant, pedestal);
  s   = rs485CarrierSize(variant, clearance, bpWall, pedestal, reach, hookClear, thick, relief);
  nx  = s[0]; ny = s[1];
  //-- the relief slots must stay out of the corner holes' grid cells
  cellX = crCoord(nx, nx - 1) - crGrid/2;
  assert(hookX + width/2 + shSlot <= cellX,
         str("hooks at ", hookX, " run into the corner hole cells: keep hookX + width/2 + ", shSlot, " under ", cellX));
  assert(hookX - width/2 - shSlot >= 0, "the two hook pairs overlap");
  difference()
  {
    union()
    {
      carrierPlate(nx, ny, open = false);              // solid: the hooks' tongues need the plate
      //-- pedestal and end walls with lead gaps, no tape; no side walls, the hooks stand there
      rs485Holder(variant, ["gap", "gap", "open", "open"], clearance, pedestal, 0, rise);
      for (x = [-hookX, hookX])
        translate([x, 0, 0]) rotate([0, 0, 90])
          snapHookPair(v[2], top, reach, hookClear, thick, width, [false, tab], relief);
    }
    for (x = [-hookX, hookX])
      translate([x, 0, 0]) rotate([0, 0, 90])
        snapHookPairFloorCut(v[2], top, reach, hookClear, thick, width, crPlate, relief);
  }
}

//-- the board seated on the carrier, and the carrier's screws, for previews
module rs485CarrierGhost(variant = rs485Variant, how = crHow, pedestal = bpPedestal, clearance = bpClearance,
                         reach = shReach, hookClear = shClearance, thick = shThick, relief = shRelief)
{
  s = rs485CarrierSize(variant, clearance, bpWall, pedestal, reach, hookClear, thick, relief);
  rs485Ghost(variant, pedestal, 0);
  carrierScrewGhost(s[0], s[1], how);
}
