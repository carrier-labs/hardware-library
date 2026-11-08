# RS485 module (MAX485), on the floor

A TTL-to-RS485 module. The JZK one we use has no mounting holes, so it sits on a taped pedestal
in an outline pocket ([board-pocket](../board-pocket/)). There are lead gaps at the **bus end**
(A+, B−, earth) and the **logic end** (VCC, TXD, RXD, GND), 10 wide so a 4-pin row's wires
fit through, and 6 wide in both long sides. In a closed box two lid pads press foam onto it, one
inboard of each end's pin row. With a screw terminal, the bus-end pad moves inboard of it.

There's no wall port: the leads go wherever the box takes them. On a [carrier](../carrier/) the
board is hooked rather than taped (see On a carrier). First used in the controller project (room
receiver and rack-ends, 2026-10-30).

![Fit piece](render.png)

**Status:** measured. Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/rs485-max485/rs485-max485.scad>

// frame: floor top, under the centre of the board; bus end at -X
translate([x, y, floorTop]) rotate([0, 0, a])
{
  rs485Holder();                    // JZK
  if ($preview) rs485Ghost();
}
// on the lid (lidZ = the lid's inner face above the floor top):
translate([x, y, floorTop]) rotate([0, 0, a]) rs485LidPads(lidZ = 12);
echo(rs485Top());                   // board top above the floor: 5.1
```

The holder takes 46.2 × 18.7 of floor. `sides` works as in board-pocket if a side needs to be
solid or open.

## On a carrier

`rs485Carrier()` is the same part on a **5 × 3 carrier** (50 × 30), held by snap hooks instead
of tape and lid pads. Carrier frame: origin at the plate's centre, Z = 0 on the plate's top, the
board along X as above. The file `include`s `carrier.scad` and `snap-hook.scad` (neither draws
anything) so their variables are the defaults here.

```openscad
use <../lib/hardware-library/components/carrier/carrier.scad>
use <../lib/hardware-library/components/rs485-max485/rs485-max485.scad>

size = rs485CarrierSize();                           // [5, 3]
// floor frame: floor top, under the carrier's centre
translate([x, y, floorTop])
{
  carrierBosses(size[0], size[1]);                   // "tap": add to the floor
  translate([0, 0, crSeatZ()])                       // 5.6 up
  {
    rs485Carrier();                                  // JZK, no release tabs
    if ($preview) rs485CarrierGhost();               // the board seated, and the screws
  }
}
// in the floor's difference():
translate([x, y, floorTop]) carrierFloorCut(size[0], size[1], floorThick, "tap");
echo(rs485CarrierTop());                             // board top above the plate: 4.1
echo(rs485CarrierHeight());                          // tallest plastic: 6.35 (11.15 with tab = true)
```

**What holds it.** The 26 × 9 × 2.5 pedestal, with no tape, and the two end walls with their
10 wide lead gaps, which stop the board along X; no side walls. Two [snap hooks](../snap-hook/)
stand over each long edge, at X = ±10, each on a tongue of plate cut free by a U-slot through
the carrier. Push the board down: its edges ride the 45° lead-ins and the four hooks snap back
over its top, 4.1 above the plate; their 45° undersides also centre it across. To take it out,
lift one end of the board: the two hooks at that end cam open and it pivots out (the end wall
is only 3.5 tall, so a fingernail under the board's end does it). `tab = true` adds a lever lip
to the +Y pair, which raises the tallest plastic from 6.35 to 11.15.

**Why 5 × 3.** The end walls need 46.2 along the board, so 5 units; each hook with its arm,
tongue and slot needs `snapHookClear()` = 6.9 past the board's edge, 15.5 + 2 × 6.9 = 29.3
across, so 3. A 5 × 2 has no room for the slots; a 4 × 3 would cut the end walls. The plate is
solid (`open = false`): the tongues need it, and the pedestal sits where a window would be. The
slots stop 1 short of the corner holes' grid cells (`rs485Carrier` asserts this), and 1.35 of
plate is left between each tongue's root and the plate's edge. `rs485CarrierSize()` works it
out from the table, so another module gets its own size; all three rows come out 5 × 3.

The hooks' reach (0.7), clearance (0.3) and tongue (4) are snap-hook's **CAL** values: print
snap-hook's fit piece, which is this module on four such stations, before a carrier. On the
XY-017's 0.8 PCB the arm is 3.45 and the estimated strain 3.9 %, right at snap-hook's 4 %
limit; pass `thick = 1.2` if its hooks are stiff. Lid pads are not needed on a carrier.

Parameters: `variant`, `tab`, `hookX`, then snap-hook's `reach`, `hookClear`, `thick`,
`width`, `relief`, and board-pocket's `clearance` (end walls to the board), `pedestal`, `rise`.

## Sizes

Pick a row of `rs485Variants` with `variant = "..."`.

| Variant | Board | PCB | Pins (bus / logic) | Source |
|---|---|---|---|---|
| `jzk` (default) | 43.0 × 15.5 | 1.6 **CAL** | 3 holes / 4 holes, no terminal | Measured 2026-10-21 (JZK 5-pack, B09VGJCJKQ) |
| `xy-017` | 42.8 × 15.22 | 0.8 | 3 / 4 **CAL** | [WINGONEER XY-017 manual](https://manuals.plus/asin/B06XHH6B6R). Looks like the JZK's family |
| `max485` | 44.0 × 14.0 | 1.6 **CAL** | 4-pin header each end, 2-way 5.08 screw terminal at the bus end | Most listings, e.g. [Kunkune](https://kunkune.co.uk/shop/communication-boards/max485-ttl-to-rs-485-converter-module/), [ElectroPeak](https://electropeak.com/ttl-rs485); some say 45 × 15 or 46 × 12. Terminal size and place **CAL** |

The `max485` is the classic blue module with RO, RE, DE and DI to drive by hand; the other two
switch direction themselves.

## Dimensions

JZK from the controller project's parts sheet (measured and photographed 2026-10-21).

| Item | Value (mm) | Source |
|---|---|---|
| Board | 43 × 15.5 | Measured 2026-10-21 |
| PCB | 1.6 | **CAL**, probably 1.6. The XY-017 manual says 0.8 for its board |
| Holes | None | Photo |
| Bus end | A+, B−, earth: 3 bare plated holes, no screw terminal fitted | Photo |
| Logic end | VCC, TXD, RXD, GND: 4 holes at 2.54, unpopulated | Photo |
| `rs485PinEnd` | 1.5 from the end to the pin row | **CAL**, ghost only |
| Tallest part | About 2 (SMB diodes, SOIC chips) | Photo |
| Chips | MAX485 ESA + CD4069. A MAX485 is rated 4.75–5.25 V: the controller project runs it at 3.3 V on bench tests | Photo |
| Termination | 120 Ω, by shorting the R0 (R13) pads. Meter A+ to B− | Listing, photo |

## Design values

| Variable | Value | Why |
|---|---|---|
| `rs485PadEnd`, `rs485PadSide` | 8.5, 3.25 | Pedestal stops this far in from the ends and sides: 26 × 9 on the JZK, clear of the pin stubs (controller project) |
| `rs485EndGap` | 10 | The 4-pin row is 7.62 across, plus the wires. The controller project used 6 |
| `rs485SideGap` | 6 | As the controller project |
| `rs485PadInset`, `rs485PadLen` | 6, 6 | Lid pads 6 long, 6 inboard of each end, the board's width less 3 (controller project) |
| Pedestal, tape, outline gap, wall, foam | 2.5, 1.0, 0.4, 1.2, 3.0 squeezed 1.0 | board-pocket's defaults |
| `rs485HookX` | 10 | Carrier: the two hook pairs sit this far either side of the board's centre. Clear of the chips at ±5, 20 apart on a 43 board, and the 8 wide relief slots (X 6..14) stop 1 short of the corner holes' 10 × 10 cells |
| Carrier size | 5 × 3, solid | `rs485CarrierSize()`: 46.2 along the board (end walls), 29.3 across (hooks and slots, 6.9 past each edge) |
| Carrier board top | 4.1 | `rs485CarrierTop()`: 2.5 pedestal, no tape, 1.6 PCB. The hooks' `top` |
| Carrier hooks | reach 0.7, clearance 0.3, 1.6 × 6, tongue 4 | snap-hook's defaults, **CAL** there. Tallest plastic 6.35, 11.15 with tabs (`rs485CarrierHeight()`) |
| Carrier end walls | 1.2, top at 3.5 | board-pocket's wall and rise over the board's underside: they stop the board along X, 1.0 up its 1.6 edge, and leave its end free to lift |

## Fit piece

`make rs485-max485` → `out/rs485-max485_fit.3mf`. It tests the lid hold-down: four JZK pockets,
each with a bridge across it where the logic-end lid pad would be. Stick a 3 mm foam pad under
each bridge. The stations vary how far the foam gets squashed, so they also show up a PCB
thinner or thicker than 1.6. The ends are open so the board can slide in under the foam; the
real holder has end walls. Prints base down, no supports (the bridges span about 20).

| Dots | Foam squeeze |
|---|---|
| 1 | 0.5 |
| 2 | 1.0 |
| 3 | 1.5 |
| 4 | 2.0 |

Put tape on the pedestal with its liner on and slide the board in from the bus end. Can you,
without forcing? Does the foam hold it firmly without bowing the board? Does it stay put when
you tug it? Does the foam spring back afterwards? Write the winner into `bpSqueeze` (or pass
`squeeze`) and the results table below. The outline gap is tested by board-pocket's fit piece.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
