//-----------------------------------------------------------------------
// ESP32-S3 DevKitC-1 (and the YD-ESP32-S3 clone), one USB port through a wall
//
// The board has no mounting holes. It sits on a taped pedestal between its
// pin rows, inside an outline pocket (board-pocket). It has two USB ports
// side by side on its front edge; only ONE comes through the wall, flush in
// a usb-c-port pocket. The other stays behind the wall, in a blind pocket,
// so nothing gets plugged into the wrong one. The pocket is open at the
// wall and whole at the back, under the WROOM module's overhang, which
// takes the plug's push. The long sides have gaps for the leads.
//
// To fit: tip the board nose-down a few degrees, put the socket into the
// wall, then lay the back end down onto the tape.
//
// Modules, all in the same frame:
//   s3DevkitGhost()    the board, module, ports and LED, for previews
//   s3DevkitHolder()   the plastic: pedestal and outline pocket, add to the floor
//   s3DevkitWallCut()  subtract from the wall: open port, blind port, board relief
//   s3DevkitLedCut()   subtract from the lid: a light hole over the RGB LED
//   s3DevkitLidPad()   a block under the lid pressing foam onto the module's shield
//   s3DevkitPinsGhost() the header bodies and pins (they point DOWN), for previews
//
// Frame (as usb-c-port): origin on the floor top at the wall's inner face,
// under the OPEN port's axis. +X into the box (toward the module end), Z up.
// The wall is X = -wall .. 0. "Left" and "right" are seen from outside,
// looking at the wall: the board's left edge is at +Y. Units: mm.
//
// On a carrier (carrier.scad), in the CARRIER frame (plate centre, Z = 0 on
// the plate's top, X along its length; the wall is at the -X end, the board
// centred on Y = 0):
//   s3Carrier()         the plate, the pedestal frame, the back stop, two snap
//                       hooks over the antenna end and the wall lip
//   s3CarrierGhost()    the board seated on it, pins and all
//   s3CarrierWallCut()  s3DevkitWallCut placed for the carrier: subtract from
//                       the wall at the carrier's position
//   s3CarrierSize() → [nx, ny]; s3CarrierWallX() → X of the wall's inner face
//   (the lip's outer face); s3CarrierPortY() → Y of the open port's axis;
//   s3CarrierAxisZ() → the port axis above the plate; s3CarrierHeight() → the
//   top of the tallest thing on it, for a lid
//
// Sizes: pick a row of s3Variants by name. port = "left" | "right" chooses
// which USB port comes through.
//-----------------------------------------------------------------------

//-- included, not used, so their default values (bpTape, usbcClearance...) are in scope here
include <../board-pocket/board-pocket.scad>
include <../usb-c-port/usb-c-port.scad>
//-- the carrier (crGrid, crPlate, carrierPlate) and the snap hook (shRelief, shMaxStrain, shSlot,
//-- shTabLip) are included too, for their variables, as carrier does screw-post. Neither draws
//-- anything at top level
include <../carrier/carrier.scad>
include <../snap-hook/snap-hook.scad>

//-- [name, length, width, pcb, usb type, port centres from the left edge, overhang, shell [w, h],
//--  module overhang past the back edge, LED [from the USB edge, from the left edge] or undef,
//--  header rows apart]
//-- Sources: the controller project's parts sheet and rack-end.scad
s3Variants = [
  //-- YD-ESP32-S3 clone (diymore N16R8, B0GYCQ2GBB, photographed 2026-10-30): VCC-GND drawing, STEP.
  //-- PCB CAL (STEP 1.02). LED CAL (photo; STEP 18.9 from the USB edge). N8R2 / N16R8 alike
  ["yd",           57.15, 27.94, 1.0, "usb-c", [8.2, 19.7], 0.38, [8.94, 3.2], 6.24, [19.0, 8.6], 25.40],
  //-- Espressif ESP32-S3-DevKitC-1 v1.1: DXF. Micro-USB, not USB-C. PCB 1.6 assumed;
  //-- centres from the left edge CAL (DXF x 6.0 and 19.4); LED not taken off the DXF
  ["devkitc-v1.1", 62.86, 25.40, 1.6, "micro", [6.0, 19.4], 0.87, [7.5, 2.6], 6.29, undef, 22.86],
];

//-- Header pins (YD STEP, read 2026-11-08): 2 x 22 at 2.54, the first 1.91 from each end, soldered
//-- pointing DOWN: the plastic bodies are under the board and the pins reach 7.7 below it, with
//-- 2.55 of stub above the top. CAL on the board in hand; the v1.1 is assumed the same
s3PinPitch   = 2.54;
s3PinN       = 22;
s3PinFromEnd = 1.91;    // first pin centre from each end of the board
s3PinSq      = 0.65;    // pin section
s3PinBelow   = 7.7;     // pin tip below the PCB underside (STEP: 8.70 under the top, PCB 1.02)
s3PinAbove   = 2.55;    // stub above the PCB top
s3HeaderBody = 2.5;     // header plastic under the board, s3PinPitch wide on the row
s3Variant     = "yd";
s3Port        = "right";  // CAL: the native "USB" port (gamepad, power) on the YD (the controller project's rack-end)

//-- The module: ESP32-S3-WROOM-1, 18 x 25.5 x 3.1 (Espressif datasheet), centred across the board
s3ModuleW     = 18.0;
s3ModuleL     = 25.5;
s3ModuleH     = 3.1;
s3ShellDepth  = 6.55;     // ghost only (the controller project's rack-end ghost)

//-- Holder
s3Pad         = [40, 14]; // pedestal between the pin rows (25.40 apart): the controller project's rack-end.scad
s3Rise        = 0.8;      // pocket wall above the PCB underside: stays under the module's overhang
s3Sides       = ["open", "solid", "gap", "gap"];
s3PortClear   = usbcClearance;   // per side, shell to pocket: usb-c-port's, set by its fit piece
s3MinSkin     = 0.4;      // thinnest wall left in front of the closed port
s3LedHole     = 5;        // light hole over the RGB LED (the controller project's rack-end)
//-- Micro-USB (Espressif v1.1): a plain opening for the plug, the board edge just inside the wall
s3MicroOpen   = [12, 7.5, 2];   // CAL: w, h, corner r: room for a micro-B plug overmould
s3MicroEdgeX  = 0.2;

function s3Devkit(name = s3Variant) = let (i = search([name], s3Variants)[0])
  assert(i != [] && i != undef, str("unknown S3 variant ", name)) s3Variants[i];
//-- the open and closed ports' centres from the left edge
function s3PortC(v, port)  = assert(port == "left" || port == "right", "port is left or right")
  v[5][port == "left" ? 0 : 1];
function s3OtherC(v, port) = v[5][port == "left" ? 1 : 0];
//-- Y of the board's left edge (+Y); the board spans Y = left - width .. left
function s3DevkitLeftY(variant = s3Variant, port = s3Port) = s3PortC(s3Devkit(variant), port);
function s3DevkitAxisZ(variant = s3Variant, pedestal = bpPedestal, tape = bpTape) =
  let (v = s3Devkit(variant)) boardPocketZ(pedestal, tape) + v[3] + v[7][1]/2;
//-- X of the board's USB edge
function s3DevkitEdgeX(wall, variant = s3Variant, recess) = let (v = s3Devkit(variant))
  v[4] == "usb-c" ? usbcBoardEdgeX(wall, v[6], recess) : s3MicroEdgeX;
//-- [X, Y] of the RGB LED, or undef
function s3DevkitLed(wall, variant = s3Variant, port = s3Port) = let (v = s3Devkit(variant))
  is_undef(v[9]) ? undef : [s3DevkitEdgeX(wall, variant) + v[9][0], s3PortC(v, port) - v[9][1]];

module s3Shell2D(v, grow = 0)
{
  if (v[4] == "usb-c") usbcShell2D(grow, w = v[7][0], h = v[7][1]);
  else offset(delta = grow) square(v[7], center = true);
}

module s3DevkitGhost(wall, variant = s3Variant, port = s3Port, recess, pedestal = bpPedestal, tape = bpTape)
{
  v   = s3Devkit(variant);
  ex  = s3DevkitEdgeX(wall, variant, recess);
  ly  = s3PortC(v, port);
  bz  = boardPocketZ(pedestal, tape);
  top = bz + v[3];
  translate([ex + v[1]/2, ly - v[2]/2, 0]) boardPocketGhost(v[1], v[2], v[3], s3Pad, pedestal, tape);
  %color("Silver") translate([ex + v[1] + v[8] - s3ModuleL, ly - v[2]/2 - s3ModuleW/2, top])
    cube([s3ModuleL, s3ModuleW, s3ModuleH]);
  for (c = v[5])
    %color("Silver") translate([ex - v[6], ly - c, top + v[7][1]/2]) rotate([0, 90, 0]) rotate([0, 0, 90])
      linear_extrude(s3ShellDepth) s3Shell2D(v);
  if (!is_undef(v[9]))
    %color("White") translate([ex + v[9][0] - 0.75, ly - v[9][1] - 0.75, top]) cube([1.5, 1.5, 0.6]);
}

module s3DevkitHolder(wall, variant = s3Variant, port = s3Port, recess, clearance = bpClearance,
                      pedestal = bpPedestal, tape = bpTape, rise = s3Rise)
{
  v  = s3Devkit(variant);
  ex = s3DevkitEdgeX(wall, variant, recess);
  ly = s3PortC(v, port);
  assert(v[8] <= 0 || rise < v[3] - 0.1, "pocket wall would run into the module's overhang");
  intersection()
  {
    translate([ex + v[1]/2, ly - v[2]/2, 0])
      boardPocketHolder(v[1], v[2], s3Pad, s3Sides, clearance = clearance,
                        pedestal = pedestal, tape = tape, rise = rise);
    translate([0, -100, -1]) cube([200, 200, 50]);
  }
}

//-- recess: how far the open port's face sits back from the outside (default: usb-c-port's
//-- usbcRecess, 0.62 for the YD's 0.38 overhang). The closed port's skin is recess - portClear.
module s3DevkitWallCut(wall, variant = s3Variant, port = s3Port, recess, portClear = s3PortClear,
                       pedestal = bpPedestal, tape = bpTape)
{
  v   = s3Devkit(variant);
  ex  = s3DevkitEdgeX(wall, variant, recess);
  ly  = s3PortC(v, port);
  az  = s3DevkitAxisZ(variant, pedestal, tape);
  oy  = ly - s3OtherC(v, port);           // closed port's Y
  face = ex - v[6];                       // both ports' faces
  if (v[4] == "usb-c")
    usbcWallCut(az, wall, v[6], v[2], v[3], recess, shift = v[2]/2 - ly,
                clearance = portClear, shellH = v[7][1]);
  else
    translate([-wall - 1, 0, az]) rotate([0, 90, 0]) rotate([0, 0, 90])
      linear_extrude(wall + 2) offset(r = s3MicroOpen[2]) offset(delta = -s3MicroOpen[2])
        square([s3MicroOpen[0], s3MicroOpen[1]], center = true);
  //-- closed port: blind pocket from its face back into the board relief
  assert(face - portClear + wall >= s3MinSkin - 0.01, "wall in front of the closed port under s3MinSkin: raise recess");
  translate([face - portClear, oy, az]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(-face + portClear + 0.5) s3Shell2D(v, portClear);
}

//-- light hole over the LED, through a lid whose inner face is lidZ above the floor
module s3DevkitLedCut(wall, lidZ, lidThick, variant = s3Variant, port = s3Port, d = s3LedHole)
{
  p = s3DevkitLed(wall, variant, port);
  assert(!is_undef(p), "no LED position for this variant");
  translate([p[0], p[1], lidZ - 1]) cylinder(d = d, h = lidThick + 2, $fn = 32);
}

//-- lid pad on the module's shield (the controller project's rack-end): nothing near the USB end,
//-- where BOOT and RST are
module s3DevkitLidPad(wall, lidZ, variant = s3Variant, port = s3Port, foam = bpFoam, squeeze = bpSqueeze,
                      pedestal = bpPedestal, tape = bpTape)
{
  v   = s3Devkit(variant);
  ex  = s3DevkitEdgeX(wall, variant);
  top = boardPocketZ(pedestal, tape) + v[3];
  boardLidPad([12, 14], [ex + v[1] - 8, s3PortC(v, port) - v[2]/2], top + s3ModuleH, lidZ, foam, squeeze);
}

//-- the header bodies and pins, as they are on the board: bodies under it, pins down
module s3DevkitPinsGhost(wall, variant = s3Variant, port = s3Port, recess, pedestal = bpPedestal, tape = bpTape)
{
  v  = s3Devkit(variant);
  ex = s3DevkitEdgeX(wall, variant, recess);
  cy = s3PortC(v, port) - v[2]/2;          // the board's centre line
  bz = boardPocketZ(pedestal, tape);
  for (r = [-1, 1])
  {
    %color("DimGray") translate([ex + s3PinFromEnd - s3PinPitch/2, cy + r*v[10]/2 - s3PinPitch/2, bz - s3HeaderBody])
      cube([s3PinN*s3PinPitch, s3PinPitch, s3HeaderBody]);
    for (i = [0 : s3PinN - 1])
      %color("Gold") translate([ex + s3PinFromEnd + i*s3PinPitch - s3PinSq/2, cy + r*v[10]/2 - s3PinSq/2, bz - s3PinBelow])
        cube([s3PinSq, s3PinSq, s3PinBelow + v[3] + s3PinAbove]);
  }
}

//-----------------------------------------------------------------------
// On a carrier (2026-11-08). The board sits, without tape, on a frame
// pedestal between its pin rows, tall enough that the pins (7.7 below the
// board) end just above the plate, so the carrier works on bosses, flat on
// a floor or on the bench alike. Two snap hooks over the antenna end, one
// either side of the module's overhang, hold it down; a stop under the
// overhang takes the plug's push. The USB end is held by the socket pocket
// in the box wall, and a lip across the wall end of the plate bears on the
// wall's inner face so the socket lands flush whatever the grid play.
//
// Carrier frame: origin at the plate's centre, Z = 0 on its top. The wall's
// inner face is the plate's -X edge (s3CarrierWallX()); the board is centred
// on Y = 0, so the open port's axis is at Y = s3CarrierPortY().
//-----------------------------------------------------------------------
s3CarrierWall     = 2.4;                 // the wall the carrier is made for: the board's place against
                                         // the wall's inner face depends on it. Pass the same to s3CarrierWallCut
s3CarrierPedestal = s3PinBelow + 0.3;    // 8.0: the pin tips 0.3 above the plate
s3CarrierTape     = 0;                   // no tape: the hooks hold the board down
s3PedWall         = 1.6;                 // the pedestal is a frame of this wall with a rib across, not solid
s3HookW           = 4;                   // each hook, along the board's back edge
s3HookClear       = 0.5;                 // hook arm to the module's side: the overhang between the arms locates Y
s3StopW           = 15;                  // back stop under the module's overhang (18 wide)
s3LipT            = 2.0;                 // wall lip: thickness (X), height, and how far it stops from the pin rows
s3LipH            = 3.5;
s3LipClear        = 1.0;

//-- the board's top above the plate
function s3CarrierTop(variant = s3Variant, pedestal = s3CarrierPedestal) =
  pedestal + s3CarrierTape + s3Devkit(variant)[3];
//-- the hooks' flex relief: none if the arm is long enough to flex on its own (it is at 8.0)
function s3CarrierRelief(top) = snapHookStrain(top, relief = 0) <= shMaxStrain ? 0 : shRelief;
//-- hook width: s3HookW, or what fits between the module's side and the board's edge
function s3CarrierHookW(variant = s3Variant) =
  min(s3HookW, s3Devkit(variant)[2]/2 - s3ModuleW/2 - s3HookClear);
//-- hook centre from the board's centre line
function s3CarrierHookY(variant = s3Variant) = s3ModuleW/2 + s3HookClear + s3CarrierHookW(variant)/2;
//-- Y of the open port's axis in the carrier frame (the board is centred on Y = 0)
function s3CarrierPortY(variant = s3Variant, port = s3Port) = let (v = s3Devkit(variant)) v[2]/2 - s3PortC(v, port);
//-- how far the plastic reaches from the wall's inner face: the board, and the hooks past its back edge
function s3CarrierReach(variant = s3Variant, wall = s3CarrierWall, recess, pedestal = s3CarrierPedestal, tab = false) =
  let (v = s3Devkit(variant), top = s3CarrierTop(variant, pedestal))
  s3DevkitEdgeX(wall, variant, recess) + v[1] + snapHookClear(top, relief = s3CarrierRelief(top)) + (tab ? shTabLip : 0);
//-- [nx, ny]: the smallest plate the reach fits on with the hooks out of the end hole cells (the screw
//-- heads need them), and the board across it
function s3CarrierSize(variant = s3Variant, wall = s3CarrierWall, recess, pedestal = s3CarrierPedestal, tab = false) =
  let (v = s3Devkit(variant), top = s3CarrierTop(variant, pedestal),
       across = max(v[2], 2*(s3CarrierHookY(variant) + s3CarrierHookW(variant)/2 + (s3CarrierRelief(top) > 0 ? shSlot : 0))))
  [ceil(s3CarrierReach(variant, wall, recess, pedestal, tab)/crGrid - 0.001) + 1, ceil(across/crGrid - 0.001)];
//-- X of the wall's inner face in the carrier frame: the plate's -X edge, the lip's outer face
function s3CarrierWallX(variant = s3Variant, wall = s3CarrierWall, recess, pedestal = s3CarrierPedestal, tab = false) =
  -crSize(s3CarrierSize(variant, wall, recess, pedestal, tab)[0], 1)[0]/2;
//-- the open port's axis above the plate: pass to nothing, s3CarrierWallCut knows it
function s3CarrierAxisZ(variant = s3Variant, pedestal = s3CarrierPedestal) = s3DevkitAxisZ(variant, pedestal, s3CarrierTape);
//-- the tallest thing on the carrier: the module's shield, or the hooks (their tabs) if higher
function s3CarrierHeight(variant = s3Variant, pedestal = s3CarrierPedestal, tab = false) =
  let (top = s3CarrierTop(variant, pedestal)) max(top + s3ModuleH, snapHookHeight(top, tab = tab));

//-- the pedestal as a frame: a ring of `wall` with a rib across the middle, h tall, centred
module s3PedestalFrame(pad = s3Pad, h = s3CarrierPedestal, wall = s3PedWall)
{
  translate([0, 0, -0.01]) linear_extrude(h + 0.01)
  {
    difference() { square(pad, center = true); square(pad - [2*wall, 2*wall], center = true); }
    square([wall, pad[1]], center = true);
  }
}

module s3Carrier(variant = s3Variant, port = s3Port, wall = s3CarrierWall, recess, pedestal = s3CarrierPedestal,
                 clearance = bpClearance, tab = false, rise = s3Rise)
{
  v    = s3Devkit(variant);
  n    = s3CarrierSize(variant, wall, recess, pedestal, tab);
  wx   = -crSize(n[0], n[1])[0]/2;                 // the wall's inner face
  ex   = s3DevkitEdgeX(wall, variant, recess);     // the board's USB edge from it
  back = wx + ex + v[1];                           // the board's back edge
  top  = s3CarrierTop(variant, pedestal);
  relief = s3CarrierRelief(top);
  hw   = s3CarrierHookW(variant);
  hy   = s3CarrierHookY(variant);
  lipW = v[10] - s3PinSq - 2*s3LipClear;
  lipH = min(s3LipH, pedestal + s3CarrierTape - 0.5);
  assert(hw >= 1.6, str("no room for a hook beside the module: ", hw, " wide"));
  assert(rise < v[3] - 0.1, "back stop would run into the module's overhang");
  assert(wx + ex >= wx - wall, "board edge past the wall's outside");
  difference()
  {
    union()
    {
      carrierPlate(n[0], n[1], open = false);
      //-- pedestal frame between the pin rows, centred under the board
      translate([wx + ex + v[1]/2, 0, 0]) s3PedestalFrame(s3Pad, pedestal);
      //-- back stop under the module's overhang: takes the plug's push
      translate([back + clearance, -s3StopW/2, -0.01]) cube([bpWall, s3StopW, pedestal + s3CarrierTape + rise + 0.01]);
      //-- a hook over the back edge either side of the module
      for (s = [-1, 1]) translate([back, s*hy, 0]) snapHook(top, width = hw, tab = tab, relief = relief);
      //-- the wall lip, between the pin rows
      translate([wx, -lipW/2, -0.01]) cube([s3LipT, lipW, lipH + 0.01]);
    }
    for (s = [-1, 1]) translate([back, s*hy, 0]) snapHookFloorCut(top, width = hw, floorThick = crPlate, relief = relief);
  }
  if ($preview)
  {
    s3CarrierGhost(variant, port, wall, recess, pedestal, tab);
    carrierScrewGhost(n[0], n[1]);
  }
}

//-- the board seated on the carrier, with its pins
module s3CarrierGhost(variant = s3Variant, port = s3Port, wall = s3CarrierWall, recess, pedestal = s3CarrierPedestal, tab = false)
{
  translate([s3CarrierWallX(variant, wall, recess, pedestal, tab), s3CarrierPortY(variant, port), 0])
  {
    s3DevkitGhost(wall, variant, port, recess, pedestal, s3CarrierTape);
    s3DevkitPinsGhost(wall, variant, port, recess, pedestal, s3CarrierTape);
  }
}

//-- the wall cut, in the carrier frame: place it exactly as the carrier
module s3CarrierWallCut(wall = s3CarrierWall, variant = s3Variant, port = s3Port, recess, pedestal = s3CarrierPedestal,
                        portClear = s3PortClear, tab = false)
{
  translate([s3CarrierWallX(variant, wall, recess, pedestal, tab), s3CarrierPortY(variant, port), 0])
    s3DevkitWallCut(wall, variant, port, recess, portClear, pedestal, s3CarrierTape);
}
