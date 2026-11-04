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
//
// Frame (as usb-c-port): origin on the floor top at the wall's inner face,
// under the OPEN port's axis. +X into the box (toward the module end), Z up.
// The wall is X = -wall .. 0. "Left" and "right" are seen from outside,
// looking at the wall: the board's left edge is at +Y. Units: mm.
//
// Sizes: pick a row of s3Variants by name. port = "left" | "right" chooses
// which USB port comes through.
//-----------------------------------------------------------------------

//-- included, not used, so their default values (bpTape, usbcClearance...) are in scope here
include <../board-pocket/board-pocket.scad>
include <../usb-c-port/usb-c-port.scad>

//-- [name, length, width, pcb, usb type, port centres from the left edge, overhang, shell [w, h],
//--  module overhang past the back edge, LED [from the USB edge, from the left edge] or undef]
//-- Sources: the controller project's parts sheet and rack-end.scad
s3Variants = [
  //-- YD-ESP32-S3 clone (diymore N16R8, B0GYCQ2GBB, photographed 2026-10-30): VCC-GND drawing, STEP.
  //-- PCB CAL (STEP 1.02). LED CAL (photo; STEP 18.9 from the USB edge). N8R2 / N16R8 alike
  ["yd",           57.15, 27.94, 1.0, "usb-c", [8.2, 19.7], 0.38, [8.94, 3.2], 6.24, [19.0, 8.6]],
  //-- Espressif ESP32-S3-DevKitC-1 v1.1: DXF. Micro-USB, not USB-C. PCB 1.6 assumed;
  //-- centres from the left edge CAL (DXF x 6.0 and 19.4); LED not taken off the DXF
  ["devkitc-v1.1", 62.86, 25.40, 1.6, "micro", [6.0, 19.4], 0.87, [7.5, 2.6], 6.29, undef],
];
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
