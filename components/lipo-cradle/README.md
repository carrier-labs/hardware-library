# LiPo pouch cell, low cradle

A low open wall round a LiPo pouch pack, with a gap in one side for the lead. The pack drops
in and the lid keeps it down. If nothing presses on it from above, turn on the **strap bars**:
two bars beside the long walls, raised off the floor, for a hook-and-loop strap. The strap goes
over the pack, down outside the wall, under the bar and back up.

The cradle only locates the pack. Nothing should press on the pouch: leave headroom for it to
swell (`lipoHeadroom()`), and keep it away from sharp edges and screw tips.

First used in the controller project (controller base, 602530 500 mAh pack, 2026-11-02).

![Fit piece](render.png)

**Status:** measured (sizes from the pouch code). Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/lipo-cradle/lipo-cradle.scad>

// frame: floor top, centre of the pack's footprint; +X along its length, lead at -X
translate([x, y, floorTop])
{
  lipoCradle("602530", leadSide = "-x");          // strap = 10 adds the strap bars
  if ($preview) lipoGhost("602530");
}
echo(lipoHeadroom("602530"));   // 7.1: the lid must clear this above the floor
```

`leadSide` is `"-x"` (the tab end, default), `"+x"`, `"-y"` or `"+y"`; `gap` sets its width.
`pcm` adds length at the tab end for a protection board that sticks out past the cell.

## On a carrier

On the [carrier](../carrier/) grid the cradle sits on a plate with a [bridge](../bridge/) across
the pack: two posts beside its long sides and a separate bar that snaps into them with a pad of
foam under it. The strap bars stay off; the bridge does their job. The carrier frame is the
cradle's: the plate's centre under the pack's centre, Z = 0 on the plate's top.

```openscad
use <../lib/hardware-library/components/carrier/carrier.scad>
use <../lib/hardware-library/components/lipo-cradle/lipo-cradle.scad>

plan = lipoCarrierPlan("602530");          // [4, 5, 0]: a 4 x 5 plate, the bar over the pack's middle
nx = plan[0]; ny = plan[1];
translate([x, y, floorTop])                // floor frame: floor top, under the carrier's centre
{
  carrierBosses(nx, ny);                   // "tap": add to the floor
  translate([0, 0, crSeatZ()]) { lipoCarrier("602530"); if ($preview) lipoCarrierGhost("602530"); }
}
translate([x, y, floorTop]) carrierFloorCut(nx, ny, floorThick);   // in the floor's difference()
echo(lipoCarrierHeight("602530"));         // 10: the bar's top above the plate, which a lid must clear

lipoBridgeBar("602530");                   // the bar: export this on its own
```

**Size: 4 × 5 (40 × 50) for the 602530.** The cradle is 34 × 29 outside; the bar crosses the
pack's **width**, so the posts stand beside the long sides, 36.5 apart (1 clear of the cradle each
side) and 42 over all: 5 units across the pack and 4 along it. Across the length it would be 5 × 3,
but the −X post would stand in front of the lead gap in the end wall, so the shorter span it is;
`leadSide` must be an end. The plate stays solid under the posts and the cradle wall (`open = false`
to `carrierPlate`), with a window under the pack 3 inside the wall (24 × 19) as the fit piece has;
`open = false` keeps it whole. The bar is its own print, `lipoBridgeBar(name)`, drawn flat on its
back, feet up.

What holds the pack: the bar's ends sit on the post tops, 8 above the plate (pack 6 + 3 foam − 1
squeeze), so the foam, not a hard edge, presses the pouch; a pouch that swells pushes into the foam.
To take it out, press one barb in with a thumbnail and lift that end, or squeeze both and lift the
bar off, then lift the pack; the lead leaves through the end wall's gap and over the plate's −X edge
(it can drop into the 4 mm under a carrier on bosses). The screws' heads need a driver: nothing on the
plate comes within 3 of a hole's centre (`lipoCarrierKeep`), and `lipoCarrier()` stops if it would.

`lipoCarrierSize(name)` is the smallest plate the cradle and posts fit on; `lipoCarrierPlan(name)`
→ `[nx, ny, barAt]` is the one to use: on a side of 6 units or more the carrier puts a hole near
its middle, which a cradle longer than about 44 lands on, so for the longer packs it moves the bar
along the pack (`barAt`) and grows the plate until every hole is clear. Pass `size` or `barAt` to
`lipoCarrier()` to override it. `lipoBridge(name)` → `[span, h]`.

| Pack | Cradle outside | Carrier | Bar at | Bar top above the plate |
|---|---|---|---|---|
| 402030 / 502030 / 902030 | 34 × 24 | 4 × 4 | 0 | 8 / 9 / 13 |
| **602530** | 34 × 29 | **4 × 5** | 0 | 10 |
| 503035 | 39 × 34 | 4 × 5 | 0 | 9 |
| 403048 / 603048 | 52 × 34 | 6 × 5 | 4 | 8 / 10 |
| 503450 / 603450 / 103450 | 54 × 38 | 7 × 6 | 9 | 9 / 10 / 14 |
| 605060 | 64 × 54 | 8 × 7 | 4 | 10 |
| 803860 / PKCell-2000 | 64 × 42 | 8 × 6 | 4 | 12 |

The bridge's barb and foot clearance, and the foam, are the bridge's **CAL** values; the cradle's
clearance is this part's. Nothing new to calibrate here.

## Sizes

LiPo pouch cells are named by size: **TTWWLL**, thickness in tenths of a mm, then width and
length in whole mm. 602530 = 6.0 × 25 × 30. Thicknesses of 10 mm and more break the pattern
(103450 is 10 thick, not 1.0), so codes starting with 1 must be in the table. The code is the
**cell**: the pack round it is usually a little bigger. Sellers round the length (±5 % is common),
the protection board is often folded over the tab end, adding a few mm, and the tape adds a few
tenths. The code says nothing about capacity. Measure the pack in hand.

Select by name: a row of `lipoPacks`, or any six-digit code, which `lipoCodeDims()` decodes.

| Name | T × W × L | Note |
|---|---|---|
| `402030` | 4.0 × 20 × 30 | |
| `502030` | 5.0 × 20 × 30 | |
| `602530` | 6.0 × 25 × 30 | 500 mAh, in use in the controller project. Label read 2026-10-30 (the listing's 403048 was wrong). **CAL**: not yet measured |
| `503035` | 5.0 × 30 × 35 | |
| `403048` / `603048` | 4.0 / 6.0 × 30 × 48 | |
| `503450` / `603450` | 5.0 / 6.0 × 34 × 50 | |
| `103450` | 10 × 34 × 50 | 1800–2000 mAh class |
| `902030` | 9.0 × 20 × 30 | |
| `605060` | 6.0 × 50 × 60 | |
| `803860` | 8.0 × 38 × 60 | 2000 mAh class |
| `PKCell-2000` | 8 × 38 × 60 | Pi Hut 105187: vendor size of the pack; lead about 100, JST-PH 2.0. Its code would be 803860, but it isn't on the listing |

Sources: the TTWWLL convention as sellers state it (e.g. Zaitronics 603450, 103450 tables); the
the controller project's parts sheet for the two packs in hand. Everything here is nominal until a pack is measured.

## Design values

| Variable | Value | Why |
|---|---|---|
| `lipoClearance` | 0.4 per side | CAL: pack to wall (controller base `fitClearance`). Set by the fit piece |
| `lipoWall` × `lipoWallH` | 1.6 × 4 | Low wall: locates the pack, easy to lift out (controller base) |
| `lipoLeadGap` | 12 | Gap for the lead and its plug (controller base) |
| `lipoPcmAllow` | 0 | Length added at the tab end for a protection board. CAL per pack |
| `lipoSwell` | 10 % | Headroom over the thickness for a pouch that swells with age. A visibly swollen pack is scrap |
| `lipoTopGap` | 0.5 | Above the swollen pack, under the lid |
| `lipoStrapGap` / `lipoStrapBar` | 2.0 / 2.0 | Strap bars: 2 from the wall and off the floor, 2 × 2 bar. Bridges the strap width + 1 |
| `lipoBarMargin` | 1 | On a carrier: the bridge posts' inner faces to the cradle's outside, each side (`brSpanFor`) |
| `lipoCarrierRim` | 3 | Plate left solid inside the cradle wall round the window under the pack, as the fit piece's pads |
| `lipoWindowMin` | 8 | No window under a pack narrower than this: not worth the plastic |
| `lipoCarrierKeep` | 3 | Hole centre to any plastic on the carrier: the M2.5 head is Ø4.4 and a driver has to land on it |

## Fit piece

`make lipo-cradle` → `out/lipo-cradle_fit.3mf`. Four cradles for the 602530 on open floor pads.
Prints base down, no supports, in the enclosure's material. Set `name` in `fit.scad` for another
pack, and `pcm` if its protection board makes it longer.

| Dots | Clearance | Strap bars |
|---|---|---|
| 1 | 0.2 | — |
| 2 | 0.4 | — |
| 3 | 0.6 | — |
| 4 | 0.4 | for a 10 wide strap |

For each: does the pack drop in without pressing on the pouch? How far does it slide about? Does
the lead leave through the gap without a sharp bend? On 4: does the strap thread under both bars
and hold the pack down? Write the winner into `lipoClearance` and the results table below.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
