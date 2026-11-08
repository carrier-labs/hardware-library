# WAGO 221 lever connector, snap clip

A WAGO 221 lever connector held flat on the floor of the box. **Push it down:** it presses on
the sloped lead-ins of two arms at its short ends, the arms flex outward, and their hooks snap
over its top edge. L-shaped stops at the corners locate the footprint. The wire-entry face is left
open, with only a 1 mm stub at each corner so the outer ports stay clear. To take it out, prise
one hook back with a fingernail and lift.

The arms stand free of the stops, so they flex from the floor. Open the levers with the WAGO out
of the clip: they swing up to about 20 above the floor.

First used in the controller project (controller base ground bus, a 221-425, 2026-11-02).

![Fit piece](render.png)

**Status:** measured. Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/wago-221/wago-221.scad>

// frame: floor top, centre of the WAGO's footprint; wire entries face -X
translate([x, y, floorTop])
{
  wagoClip("221-415");
  if ($preview) wagoGhost("221-415");
}
echo(wagoClipHeight("221-415"));   // 10.0: clear this under the lid
```

`wagoLength(name)`, `wagoDepth(name)`, `wagoHeight(name)` give the body, for placing it. The
clip needs `depth + 2 × 2.0` by `length + 2 × 2.0` of floor, and the wires need the strip length
plus their bend in front of the entry face: allow 15 for 4 mm², 20 for 6 mm².

## On a carrier

The same clip on a [carrier](../carrier/) plate. The wrapper takes the carrier frame: Z = 0
on the plate's top, the WAGO's footprint centred, entries toward −X as before.

```openscad
use <../lib/hardware-library/components/carrier/carrier.scad>
use <../lib/hardware-library/components/wago-221/wago-221.scad>

s = wagoCarrierSize("221-415");               // [3, 5]: a 30 x 50 plate
translate([x, y, floorTop])                   // floor frame, under the carrier's centre
{
  carrierBosses(s[0], s[1]);                  // "tap": add to the floor
  translate([0, 0, crSeatZ("tap")])           // 5.6 up
  {
    wagoCarrier("221-415");
    if ($preview) wagoCarrierGhost("221-415");
  }
}
// in the floor's difference():
translate([x, y, floorTop]) carrierFloorCut(s[0], s[1], floorThick, "tap");
echo(wagoCarrierEntryX("221-415"));           // -9.3: leave 15 in front of this for the wires
```

**Size.** `wagoCarrierSize(name)` picks the plate from the table: the smallest (least area,
then the narrower across X) that the clip's outline fits on with every screw head at least
0.5 clear of it, mid holes included. The 221-415 / 425 needs **3 × 5 (30 × 50)**, not the
3 × 4 its 22.6 × 34 outline suggests: a 3 × 4 plate's screws sit at (±10, ±15), under the
body's corners (±9.3, ±15) and the corner stops, with their Ø4.4 heads standing 1.4 proud of
the plate. On 3 × 5 the holes move out to (±10, ±20): each head sits beside a corner stop with
0.8 between them, clear of the body and the arms. 4 × 4 would also work, at 1600 mm² against
1500. The carrier is screwed down first; the WAGO clips in afterward and comes out without
touching the screws.

| Name | Carrier | Why |
|---|---|---|
| `221-412` | 4 × 2 (40 × 20) | its 22.8 × 17.2 outline sits between the holes at X = ±15 |
| `221-413` | 3 × 4 (30 × 40) | 4 × 3 ties on area; the narrower plate wins |
| `221-415` / `425` | 3 × 5 (30 × 50) | as above |
| `221-612` | 5 × 2 (50 × 20) | 25.1 × 20.0: the arms' outer faces lie on the plate's long edges |
| `221-613` | 3 × 5 (30 × 50) | 5 × 3 ties; the narrower plate wins |
| `221-615` | 5 × 5 (50 × 50) | a 3 × 6 or 4 × 6 plate's mid hole pair would sit under the body |

Pass `size = [nx, ny]` for a bigger plate (to line up with its neighbours, say): the wrapper
stops with an error if the heads would meet the clip.

**What holds it, and how it comes out:** the clip, unchanged: push the WAGO down, the arms
spread over the lead-ins and the hooks snap over its ends; prise one hook back with a
fingernail and lift. The WAGO's top is `wagoHeight` (8.4) above the plate, the clip
`wagoClipHeight` (10.0); the levers open to about 20 (**CAL**), with the WAGO out of the clip.

**The plate** is opened under the body (`open = true`): a pocket inset 3 from the body's
outline, and never more than `carrierOpening()` would open, so the arms and stops always stand
on solid plate. The 221-415's is 12.6 × 24. Pockets under 8 wide are left solid (the 221-412's
would be 7.2). `open = false` for a solid plate.

## Sizes

Select by item number. Length is along the row of levers (Y), depth from the entry face to the back (X).

| Name | Ways | Max | L × D × H (levers closed) | Strip | Source |
|---|---|---|---|---|---|
| `221-412` | 2 | 4 mm² | 13.2 × 18.8 × 8.6 | 11 | WAGO data sheet 221-412, 03.10.2022 (2015 UK brochure: 13.1 × 18.6 × 8.3) |
| `221-413` | 3 | 4 mm² | 18.7 × 18.6 × 8.3 | 11 | WAGO UK 221 brochure. No data sheet found: **CAL** |
| `221-415` | 5 | 4 mm² | 30.0 × 18.6 × 8.4 | 11 | WAGO data sheet 221-415, 19.04.2025; matches the 221-425 measured in the controller project |
| `221-425` | 5 | 4 mm² | 30.0 × 18.6 × 8.4 | 11 | Green Range 415: measured (the controller project's base, 2026-10) |
| `221-612` | 2 | 6 mm² | 16.0 × 21.1 × 10.1 | 12–14 | WAGO data sheet 221-612, 12.05.2023 |
| `221-613` | 3 | 6 mm² | 22.9 × 21.1 × 10.1 | 12–14 | WAGO data sheet 221-613, 04.04.2025 |
| `221-615` | 5 | 6 mm² | 36.7 × 21.1 × 10.1 | 12–14 | WAGO data sheet 221-615, 07.04.2025 |

Data sheets read from distributor copies of WAGO's own sheets (Gescan, chipdip), 2026-11-02. The
heights differ by a few tenths between sheets of the same family (8.3 / 8.4 / 8.6), and the hook
sits only 0.2 over the top, so **CAL the height** of any size before relying on it. Height with
the levers open isn't published: about 20, **CAL**.

Add a size as a row of `wagoSizes`: `[name, length, depth, height, ports, strip, max mm²]`.

## Design values

| Variable | Value | Why |
|---|---|---|
| `wagoHook` | 0.7 | CAL: how far each hook reaches in over the top edge. Set by the fit piece |
| `wagoClearance` | 0.4 | Footprint to arms and stops, each side (controller base `fitClearance`) |
| `wagoHookGap` | 0.2 | WAGO top to the hook's flat underside |
| `wagoLeadIn` | 1.4 | Sloped lead-in above the hook: the WAGO pushes the arms apart on it |
| `wagoArmThick` × `wagoArmWidth` | 1.6 × 8 | PETG arm, flexes by the hook depth to let the WAGO in |
| `wagoStopH` / `wagoStopLeg` | 3 / 4 | Corner stops, along the ends and the back |
| `wagoEntryStub` | 1.0 | Stop along the entry face: short, so the outer port's wire clears it |
| `wagoCarrierKeep` | 0.5 | On a carrier: clip to the edge of a screw head (Ø4.4), at least, so a driver reaches the head |
| `wagoCarrierRim` | 3 | Solid plate left under the body's edges round the pocket |
| `wagoCarrierOpenMin` | 8 | No pocket narrower than this (carrier's `crOpenMin`) |
| `wagoCarrierMax` | 8 | Largest plate side `wagoCarrierSize()` tries, in units |
| `wagoCarrierScrew` | `"M2.5"` | carrier's `crScrew`, repeated here: `use` doesn't carry its variables over |

The controller base's clip (`wagoClip()` in `controller-base.scad`) put the hook's tip 0.7 past
the arm's face, which leaves only 0.3 over the WAGO after the 0.4 gap. Here `wagoHook` is the
reach over the WAGO itself.

## Fit piece

`make wago-221` → `out/wago-221_fit.3mf`. Four clips for a 221-415 on an open floor. Prints base
down, no supports, in the enclosure's material. Set `name` in `fit.scad` for another size.

| Dots | Hook | Clearance |
|---|---|---|
| 1 | 0.4 | 0.4 |
| 2 | 0.7 | 0.4 |
| 3 | 1.0 | 0.4 |
| 4 | 0.7 | 0.2 |

For each: push the WAGO down. Do both hooks snap over? Does it sit without rattling? Lift it by
the levers: does it stay put? Can you prise a hook off and take it out without breaking an arm?
Write the winner into `wagoHook` / `wagoClearance` and the results table below.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
