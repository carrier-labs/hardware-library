//-----------------------------------------------------------------------
// ESP32-C3 Super Mini, USB-C through a wall
//
// The board has no mounting holes. It sits on a taped pedestal inside an
// outline pocket (board-pocket), with its USB-C socket in a flush pocket in
// the box wall (usb-c-port). The pocket is open at the wall, where the board's
// end tucks into the wall's relief, and whole at the antenna end, which takes
// the plug's push. Its long sides have gaps for the leads.
//
// To fit: tip the board nose-down a few degrees, put the socket into the
// wall, then lay the antenna end down onto the tape.
//
// Modules, all in the same frame:
//   c3MiniGhost()    the board, socket, buttons and antenna, for previews
//   c3MiniHolder()   the plastic: pedestal and outline pocket, add to the floor
//   c3MiniWallCut()  subtract from the wall: the socket pocket and board relief
//   c3MiniLidPads()  blocks under the lid that press foam onto the board
//
// Frame (as usb-c-port): origin on the floor top at the wall's inner face,
// under the socket's axis. +X into the box (toward the antenna end), Z up.
// The wall is X = -wall .. 0. Units: mm.
//
// The socket height isn't chosen: it follows from the pedestal, the tape and
// the PCB (c3MiniAxisZ). Sizes: pick a row of c3Variants by name, or pass
// length / pcb to override one value.
//-----------------------------------------------------------------------

//-- included, not used, so their default values (bpTape, usbcClearance...) are in scope here
include <../board-pocket/board-pocket.scad>
include <../usb-c-port/usb-c-port.scad>

//-- [name, length, width, pcb, USB-C overhang]. Source: the controller project's parts sheet
c3Variants = [
  ["supermini",     22.52, 18.0, 1.0, 1.5],   // diymore 4-pack B0DS23ML1L: STEP outline, PCB CAL (model 0.9)
  ["supermini-1.6", 22.52, 18.0, 1.6, 1.5],   // sellers listing a 1.6 PCB
  ["supermini-24",  24.0,  18.0, 1.0, 1.5],   // longest seller listing (22.5-24): CAL
  ["supermini-plus",22.52, 18.0, 1.0, 1.5],   // SuperMini Plus (V2): same footprint (mischianti.org); rest CAL
];
c3Variant     = "supermini";

//-- The socket: 9.0 x 3.12 on the STEP. The wall pocket uses usb-c-port's 8.94 shell
c3UsbW        = 9.0;      // from the STEP: its wall pocket is cut to this
c3UsbH        = 3.12;     // CAL
c3UsbDepth    = 7.35;     // ghost only: usb-c-port's typical shell
c3PortClear   = usbcClearance;   // per side, shell to wall pocket: usb-c-port's, set by its fit piece

//-- On the board (ghost and lid pads)
c3ButtonX     = 8.8;      // BOOT / RST centres from the USB edge
c3ButtonY     = 2.95;     // either side of the centre line
c3ButtonH     = 1.7;
c3ButtonSize  = 3.0;      // CAL: ghost only
c3AntennaSize = [2.0, 3.2, 1.2];   // CAL: ceramic chip at the far end, ghost only
c3PinPitch    = 15.24;    // header rows, along the long sides

//-- Holder
c3Pad         = [14, 10]; // pedestal: between the pin rows (the controller project's receiver.scad)
c3Sides       = ["open", "solid", "gap", "gap"];   // wall end, antenna end, long sides

function c3Mini(name = c3Variant) = let (i = search([name], c3Variants)[0])
  assert(i != [] && i != undef, str("unknown C3 variant ", name)) c3Variants[i];
//-- [length, width, pcb, overhang] with overrides
function c3MiniDims(variant = c3Variant, length, pcb) = let (v = c3Mini(variant))
  [is_undef(length) ? v[1] : length, v[2], is_undef(pcb) ? v[3] : pcb, v[4]];
function c3MiniAxisZ(pcb, pedestal = bpPedestal, tape = bpTape) =
  boardPocketZ(pedestal, tape) + pcb + c3UsbH/2;
//-- X of the board's USB edge (negative: inside the wall's relief)
function c3MiniEdgeX(wall, variant = c3Variant) = usbcBoardEdgeX(wall, c3Mini(variant)[4]);

module c3MiniGhost(wall, variant = c3Variant, length, pcb, pedestal = bpPedestal, tape = bpTape)
{
  d  = c3MiniDims(variant, length, pcb);
  ex = usbcBoardEdgeX(wall, d[3]);
  bz = boardPocketZ(pedestal, tape);
  top = bz + d[2];
  translate([ex + d[0]/2, 0, 0]) boardPocketGhost(d[0], d[1], d[2], c3Pad, pedestal, tape);
  %color("Silver") translate([ex - d[3], 0, top + c3UsbH/2]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(c3UsbDepth) usbcShell2D(w = c3UsbW, h = c3UsbH);
  for (s = [-1, 1])
    %color("Black") translate([ex + c3ButtonX - c3ButtonSize/2, s*c3ButtonY - c3ButtonSize/2, top])
      cube([c3ButtonSize, c3ButtonSize, c3ButtonH]);
  %color("Tan") translate([ex + d[0] - 1 - c3AntennaSize[0], -c3AntennaSize[1]/2, top]) cube(c3AntennaSize);
}

module c3MiniHolder(wall, variant = c3Variant, length, pcb, clearance = bpClearance,
                    pedestal = bpPedestal, tape = bpTape, rise = bpRise)
{
  d  = c3MiniDims(variant, length, pcb);
  ex = usbcBoardEdgeX(wall, d[3]);
  //-- the pocket's wall end is open; anything left inside the wall goes
  intersection()
  {
    translate([ex + d[0]/2, 0, 0])
      boardPocketHolder(d[0], d[1], c3Pad, c3Sides, clearance = clearance,
                        pedestal = pedestal, tape = tape, rise = rise);
    translate([0, -50, -1]) cube([100, 100, 50]);
  }
}

module c3MiniWallCut(wall, variant = c3Variant, length, pcb, portClear = c3PortClear,
                     pedestal = bpPedestal, tape = bpTape)
{
  d = c3MiniDims(variant, length, pcb);
  usbcWallCut(c3MiniAxisZ(d[2], pedestal, tape), wall, d[3], d[1], d[2],
              clearance = portClear, shellH = c3UsbH, shellW = c3UsbW);
}

//-- Lid pads (the controller project's receiver): one across the antenna end, a narrow one on the socket
//-- that keeps the foam off BOOT/RST. lidZ: the lid's inner face above the floor top.
module c3MiniLidPads(wall, lidZ, variant = c3Variant, length, pcb, foam = bpFoam, squeeze = bpSqueeze,
                     pedestal = bpPedestal, tape = bpTape)
{
  d   = c3MiniDims(variant, length, pcb);
  ex  = usbcBoardEdgeX(wall, d[3]);
  top = boardPocketZ(pedestal, tape) + d[2];
  boardLidPad([5, d[1] - 6], [ex + d[0] - 3.5, 0], top, lidZ, foam, squeeze);
  boardLidPad([4, 5], [max(ex - d[3], 0) + 0.5 + 2, 0], top + c3UsbH, lidZ, foam, squeeze);
}
