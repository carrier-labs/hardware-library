# ESP32-S3 DevKitC, one USB port through a wall

The S3 DevKitC-1, and the YD-ESP32-S3 clone we actually have, has no mounting holes and two USB
ports side by side on its front edge. It sits on a taped pedestal between its pin rows in an
outline pocket ([board-pocket](../board-pocket/)). **Only one port comes through the wall**,
flush in a [usb-c-port](../usb-c-port/) pocket; the other stays behind the wall in a blind
pocket, so nothing gets plugged into the wrong one. `port = "left" | "right"` (seen from
outside) picks which.

The pocket is **open at the wall** and **whole at the back**, under the WROOM module's overhang,
which takes the plug's push. The long sides have gaps for the leads. A lid pad presses foam onto
the module's shield (nothing near the USB end, where BOOT and RST are), and `s3DevkitLedCut()`
makes an optional light hole in the lid over the RGB LED.

**To fit it:** tip the board nose-down a few degrees, put the socket into the wall, then lay the
back end down onto the tape.

The YD's ports overhang the board by only 0.38, so the open port's face sits back 0.62 from the
outside (usb-c-port's `usbcRecess`). The closed port sits just as far forward, so the wall left
in front of it is the recess less the clearance: **0.47**, a single printed line. Pass a bigger
`recess` for a stiffer skin, at the cost of the open port sitting further back: the fit piece
tests 0.8 and 1.0.

First used in the controller project (rack-ends, 2026-10-30), where the port came out through a plain opening.

![Fit piece](render.png)

**Status:** measured. Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/esp32-s3-devkitc/esp32-s3-devkitc.scad>

// frame: floor top, wall inner face, under the OPEN port's axis; +X into the box
translate([wallInnerX, usbY, floorTop])
{
  s3DevkitHolder(wall = 2.4);                 // YD clone, right-hand port
  if ($preview) s3DevkitGhost(wall = 2.4);
}
// in the wall's difference():
translate([wallInnerX, usbY, floorTop]) s3DevkitWallCut(wall = 2.4);
// on the lid (lidZ = the lid's inner face above the floor top):
translate([wallInnerX, usbY, floorTop]) s3DevkitLidPad(wall = 2.4, lidZ = 12);
// in the lid's difference():
translate([wallInnerX, usbY, floorTop]) s3DevkitLedCut(wall = 2.4, lidZ = 12, lidThick = 2);
```

The board's left edge (seen from outside) is at `+Y = s3DevkitLeftY()`, so the board spans
`Y = s3DevkitLeftY() - 27.94 .. s3DevkitLeftY()`. The YD holder needs about 62 of floor behind
the wall's inner face (the module overhangs the pocket's back wall) and 31.1 across.

## On a carrier

The same board on a [carrier](../carrier/): a 7 × 3 plate with a frame pedestal between the pin
rows, two [snap hooks](../snap-hook/) over the antenna end, a stop under the module and a lip
that registers on the box wall. In the floor frame (floor top, under the carrier's centre):

```openscad
use <../lib/hardware-library/components/carrier/carrier.scad>
use <../lib/hardware-library/components/esp32-s3-devkitc/esp32-s3-devkitc.scad>

n  = s3CarrierSize();                            // [7, 3]
cx = wallInnerX - s3CarrierWallX();              // the plate's -X edge on the wall's inner face
translate([cx, cy, floorTop])
{
  carrierBosses(n[0], n[1]);                     // "tap": add to the floor
  translate([0, 0, crSeatZ()]) s3Carrier(wall = 2.4);   // 5.6 up; the board and screws ghost in preview
}
// in the floor's difference():
translate([cx, cy, floorTop]) carrierFloorCut(n[0], n[1], floorThick, "tap");
// in the wall's difference(), at the SAME place as the carrier:
translate([cx, cy, floorTop + crSeatZ()]) s3CarrierWallCut(wall = 2.4);
```

**Where it goes.** The carrier's −X edge is the wall: `s3CarrierWallX()` (−35) is the X of the
wall's inner face in the carrier frame. The board is centred on the carrier's Y axis; the open
port's axis is at `s3CarrierPortY()` across (−5.73 for the right-hand port) and
`s3CarrierAxisZ()` (10.6) above the plate, and `s3CarrierWallCut()` puts `s3DevkitWallCut` there
for you. The carrier is made for one wall thickness: the socket face sits `recess` back from the
outside, so the board's edge is `wall − 1.0` inside the inner face (1.4 for a 2.4 wall), and the
pedestal, stop and hooks are placed from it. Pass the same `wall` (and `recess`) to `s3Carrier()`
and `s3CarrierWallCut()`.

**The lip.** A 2.0 × 22.75 bar, 3.5 tall, across the wall end of the plate between the pin rows;
its outer face is the plate's edge. Place the grid so that face lands on the wall's inner face:
the holes' 0.4 play then lets you push the carrier against the wall as you tighten the screws,
and the socket is flush however the grid came out. The wall's board relief starts at 7.7 above
the plate, well above the lip.

**Size: 7 × 3, and why.** The hooks stand 1.9 past the board's back edge (no flex relief at this
height), so the plastic reaches 57.65 from the wall's inner face. That fits a 6-unit plate, but
the hooks' feet would then share a grid cell with the corner holes and sit under the screw
heads, so `s3CarrierSize()` adds a unit to keep the hooks out of the end cells (they stand at
X = 21–23 of 70; the corner holes are at 30). The plate stays solid (`open = false`): the
pedestal frame, the lip, the stop and the hooks all stand on it, and what would be left to open
is two strips 5 wide, under the carrier's 8 minimum. The Espressif v1.1 works out at 8 × 3.

**The pins set the height.** The YD's header pins point **down**: the STEP has the header
bodies under the board and the pins reaching 7.7 below its underside (**CAL**: measure the board
in hand). On a 2.5 pedestal the board would stand on its pins, 4.2 off the tape, so the carrier's
pedestal is `s3CarrierPedestal` = 7.7 + 0.3 = 8.0: the pins end 0.3 above the plate, and the
carrier works on bosses, flat on a floor or on the bench alike. No tape: the hooks hold the board
down. The pedestal is a frame (1.6 walls, a rib across), not a 4.5 cm³ block. If the pins turn
out shorter, `s3Carrier(pedestal = ...)` takes any height: below about 5.5 the hooks get a flex
relief slot automatically, and the plate grows to 8 × 3 to keep the slots out of the end cells.

**What holds it, and how it comes out.** At the front, the open socket in the wall's pocket
(0.15 a side), as in the box holder. At the back, two 4-wide snap hooks over the board's back
edge, one either side of the module's overhang and 0.5 clear of it, so the overhang between the
arms also locates the back end across the plate. Reach 0.7, 0.15 above the board top: the
snap-hook defaults (**CAL**, its fit piece); the nearest pin stubs are 1.59 from the back edge,
so a 0.9 reach clears them too. At a board top of 9.0 the arms are 9.15 long: 2.9 % strain and
about 11 N each to open, so no relief slot. A 15 × 1.2 stop, 8.8 tall, stands 0.4 behind the
back edge under the module and takes the plug's push, as the pocket's back wall did. Nothing
sits on the long edges: the pin stubs are there. To fit the board: socket into the wall first,
nose-down, then press the back end down; the edge rides the lead-ins and the hooks click over.
To take it out: lift the back by the module (the hooks cam open) and draw the socket out of the
wall. `tab = true` adds a release lip to each hook (their top goes from 11.25 to 16.05; the
module's top is 12.1: `s3CarrierHeight()` gives a lid the tallest thing on the carrier).

**Side hooks over the pin rows:** not on a 3-wide plate. It is only 1.03 wider than the board a
side and an arm needs 1.9, and the stubs stand 2.55 proud of the board top on 2.54 centres.
Future, on a 4-wide plate: a narrow hook over the long edge between two stubs.

## Sizes

Pick a row of `s3Variants` with `variant = "..."`. N8R2 and N16R8 boards are the same size.

| Variant | Board | PCB | USB | Port centres from the left | Overhang | Module past the back |
|---|---|---|---|---|---|---|
| `yd` (default) | 57.15 × 27.94 | 1.0 **CAL** | 2 × USB-C, 8.94 × 3.2 | 8.2, 19.7 | 0.38 | 6.24 |
| `devkitc-v1.1` | 62.86 × 25.40 | 1.6 assumed | 2 × micro-USB | 6.0, 19.4 **CAL** | 0.87 | 6.29 |

The Espressif v1.1 has micro-USB, which usb-c-port doesn't cover: its wall cut is a plain
12 × 7.5 opening for the plug (**CAL**), with the board's edge 0.2 inside the box. Its LED
position isn't known, so it has no light hole.

## Dimensions

From the controller project's parts sheet and `rack-end/rack-end.scad`. D = drawing,
S = STEP ([YD-ESP32-S3](https://raw.githubusercontent.com/shkuznetsov/YD-ESP32-S3/main/YD-ESP32-S3.step),
[VCC-GND drawing](https://github.com/vcc-gnd/YD-ESP32-S3/blob/main/5-public-YD-ESP32-S3-Hardware%20info/ESP32-S3-Metric.pdf),
[Espressif v1.1 DXF](https://dl.espressif.com/dl/schematics/esp_idf/DXF_ESP32-S3-DevKitC-1_V1.1_20220429.dxf)).

| Item | Value (mm) | Source |
|---|---|---|
| YD board | 57.15 × 27.94 | D (VCC-GND); 57 × 28 on the diymore leaflet |
| YD PCB | 1.0 | S says 1.02. **CAL** |
| YD USB-C | 8.94 × 3.2, overhang 0.38, centres 8.2 and 19.7 from the left seen from the front | S, rack-end.scad |
| Native USB port | `s3Port = "right"` | **CAL** (controller project's rack-end): the one the PC sees as "USB JTAG/serial debug unit" |
| WROOM-1 module | 18 × 25.5 × 3.1, centred across the board, 6.24 past the back edge | Espressif datasheet; overhang S |
| RGB LED (GPIO48) | 19.0 from the USB edge, 8.6 from the left | **CAL**: photo 2026-10-30; STEP says 18.9 |
| Header rows | 25.40 apart (v1.1: 22.86), 2 × 22 at 2.54, first pin 1.91 from each end | D, S |
| Header pins | Soldered pointing **down**: bodies 2.5 under the board, pins 0.65 square to 7.7 below its underside, 2.55 of stub on top | S, read 2026-11-08. **CAL** on the board in hand: at 7.7 the box holder's 2.5 pedestal is 4.2 too low for it |
| v1.1 board, ports | 62.86 × 25.40; micro-USB centres 6.0 and 19.4, overhang 0.87; module 6.29 past | DXF. Which edge the centres are from: **CAL** |
| Mounting holes | None on either | D, S |

## Design values

| Variable | Value | Why |
|---|---|---|
| `s3Pad` | 40 × 14 | Pedestal between the pin rows (controller project's rack-end) |
| `s3Rise` | 0.8 | Pocket wall above the underside: stays under the module's overhang (PCB top at 1.0) |
| `s3Sides` | open · solid · gap · gap | Wall end open; the back takes the plug's push |
| `s3PortClear` | usb-c-port's 0.15 | Both ports' pockets |
| `s3MinSkin` | 0.4 | Thinnest wall allowed in front of the closed port |
| `s3LedHole` | 5 | Light hole over the LED (controller project's rack-end) |
| Lid pad | 12 × 14 on the module's shield | the controller project's rack-end |
| `s3MicroOpen` | 12 × 7.5, r 2 | **CAL**: plain opening for a micro-B plug (v1.1 only) |
| `s3CarrierWall` | 2.4 | The wall the carrier is made for (the controller project's); pass yours |
| `s3CarrierPedestal` | 8.0 | `s3PinBelow` + 0.3: the pins end just above the plate, any fixing |
| `s3CarrierTape` | 0 | The hooks hold the board down; nothing to squash |
| `s3PedWall` | 1.6 | The 8-tall pedestal is a frame with a rib across, not a block |
| `s3HookW`, `s3HookClear` | 4, 0.5 | Hook width along the back edge; arm to the module's side. The width shrinks to what fits (3.2 on the v1.1) |
| `s3StopW` | 15 | Back stop under the 18-wide module; `bpWall` thick, `s3Rise` above the board's underside |
| `s3LipT` × `s3LipH`, `s3LipClear` | 2.0 × 3.5, 1.0 | Wall lip; stops 1.0 from the pin rows' faces, so 22.75 wide |
| Carrier size rule | reach + 1 unit | The hooks keep out of the end hole cells, where the screw heads sit |

## Fit piece

`make esp32-s3-devkitc` → `out/esp32-s3-devkitc_fit.3mf`. A full holder is over 60 long, so
each station is only the USB end: the wall with both ports and the first 18 of the pocket and
pedestal. Hold the board's far end level while you test. Set up for the YD, right-hand port open,
2.4 wall.

| Dots | Open port's face back from outside | Closed port's skin | Tape |
|---|---|---|---|
| 1 | 0.62 | 0.47 | 1.0 |
| 2 | 0.8 | 0.65 | 1.0 |
| 3 | 1.0 | 0.85 | 1.0 |
| 4 | 0.62 | 0.47 | 0.7 |

Tip the board in and lay it level on the tape (liner on). Is the open socket centred in its
pocket? Plug a cable in: does it seat fully and click with the face that far back? Is the skin
over the closed port whole and stiff, and does that port clear its pocket? Write the winner into
`recess` / `bpTape` and the results table below.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
