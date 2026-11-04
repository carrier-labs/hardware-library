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
// Frame: origin on the floor top under the centre of the board. X along the
// board, bus end (A/B) at -X, logic end (VCC/TXD/RXD/GND) at +X. Z up. Units: mm.
//
// Sizes: pick a row of rs485Variants by name.
//-----------------------------------------------------------------------

//-- included, not used, so its default values (bpTape, bpClearance...) are in scope here
include <../board-pocket/board-pocket.scad>

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
