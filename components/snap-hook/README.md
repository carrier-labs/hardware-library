# Snap hook, over a board's edge

A cantilever arm that hooks over the edge of a PCB, so a board with no mounting holes clicks
down onto a carrier instead of being taped. The board sits on a pedestal; a hook stands just
outside each of two opposite edges. **Push the board down:** its edges ride the 45° lead-ins,
the arms flex outward, and the hooks snap back over its top. To take it out, pull the board
(the hooks cam open) or lever one arm back with a fingernail; `tab = true` gives the arm a lip
to lever against.

Two things make it work in PETG at the height of a board on a 2.5 pedestal:

- **The arm stands on a tongue of floor.** A U-slot through the plate round the arm's foot
  (`snapHookFloorCut()`) leaves it on a tongue rooted 4 behind the arm. A 4 mm arm on its own
  would strain 13 % to open; with the tongue bending under it, about 3 %.
- **The hook's underside is a 45° slope**, not a flat, so the whole profile prints base down
  with no supports. The slope passes 0.15 above the board's top edge and meets the arm beside
  the board, so the two hooks also centre it sideways.

First used in the controller project (carriers for the RS485 module, 2026-11-08).

![Fit piece](render.png)

**Status:** measured. Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/snap-hook/snap-hook.scad>

top = 2.5 + 1.6;                     // the board's top above the floor: pedestal + PCB
// one hook. Frame: floor top, at the board's edge, under the hook's centre; board at -X
difference()
{
  union()
  {
    plate();
    translate([edgeX, hookY, 0]) snapHook(top);
  }
  translate([edgeX, hookY, 0]) snapHookFloorCut(top, floorThick = 1.6);
}
// two hooks facing each other across a board 15.5 wide, in the board's frame
difference()
{
  union() { plate(); snapHookPair(15.5, top, tab = [false, true]); }
  snapHookPairFloorCut(15.5, top, floorThick = 1.6);
}
echo(snapHookClear(top));            // 6.9: the plastic past the board's edge, for the carrier size
echo(snapHookHeight(top));           // 6.35: the arm's top (11.15 with a tab)
echo(snapHookStrain(top));           // 0.030: estimated strain at the root when the board goes in
```

The board needs a pedestal under it and a stop at each end: those are the wrapper's, as in
`fit.scad`. Nothing else may stand in the slot (1.0 wide round the foot, including under the
board's edge) or the tongue won't flex. `snapHook()` stops with an error if the arm would
strain more than 4 %: lengthen `relief`, raise the board, or thin the arm.

## Sizes

There's no table of bought parts: the hook fits any board edge, and the family is its
parameters. The one that matters is the arm's length, `top + 0.15`, set by the board's height.

| `top` (board top above the floor) | Arm | Strain, relief 4 | Force to hold open | Strain, no relief |
|---|---|---|---|---|
| 3.3 (0.8 PCB on 2.5) | 3.45 | 3.9 % | 58 N | 20 % |
| 4.1 (1.6 PCB on 2.5) | 4.25 | 3.0 % | 36 N | 13 % |
| 5.1 | 5.25 | 2.3 % | 23 N | 8.7 % |
| 6.5 | 6.65 | 1.7 % | 13 N | 5.4 % |
| 8.5 | 8.65 | 1.2 % | 7 N | 3.2 % |
| 10.5 | 10.65 | 0.9 % | 4 N | 2.1 % |

Worst case, the board pushed against the other hook so this one opens by reach + clearance
(1.0); 1.6 × 6 arm, printed PETG at 2 GPa, from `snapHookStrain()` and `snapHookForce()`.
Below about 8 the arm needs the relief (the 4 % assert). The force is per hook, at full
opening; pushing a board in over the 45° lead-in takes about twice that at the peak, so the
default arm asks for a firm thumb on a low board. A 1.2 arm gives 16 N and 2.3 % at `top`
4.1: pass `thick = 1.2` if the fit piece is hard to press.

Other parameters: `reach`, `clearance`, `thick`, `width`, `tab`, `relief` on every module.
`width` is along the board's edge; use two narrow hooks rather than one wide one if the edge
has parts near it.

## Dimensions

The hook holds a board, so its only dimensions are the board's: `top` is the board's top
face above the floor. The fit piece and views use the JZK RS485 module from
[rs485-max485](../rs485-max485/): 43 × 15.5, PCB 1.6 **CAL**, no holes, pins at the ends
(measured 2026-10-21), on a 2.5 pedestal, so `top` = 4.1.

## Design values

| Variable | Value | Why |
|---|---|---|
| `shReach` | 0.7 | **CAL**: how far the hook reaches back over the board's top. Set by the fit piece (the controller project's WAGO clips used 0.7) |
| `shClearance` | 0.3 | **CAL**: arm's inner face to the board's edge, PETG. Set by the fit piece |
| `shThick` × `shWidth` | 1.6 × 6 | PETG arm, as the controller project's clips. See Sizes for what it costs in force |
| `shGap` | 0.15 | Hook's underside above the board's top edge: snug, so it doesn't rattle |
| `shLeadIn` | 1.4 | Height of the 45° lead-in above the tip (controller project). It runs back at least to the arm's inner face |
| underside | 45° | So the hook prints without supports. The slope meets the arm `clearance − gap` below the board's top, beside it; the board can shift `gap` toward a hook before the slope lifts it |
| `shRelief` | 4 | Tongue of floor behind the arm, rooted at its far end. 0 for no slot: arms of 8 and more don't need it |
| `shSlot` | 1.0 | Slot width round the foot: both sides and in front, under the board's edge |
| `shMaxStrain` | 4 % | PETG: above this a snap cracks or takes a set (estimate). The assert in `snapHook()` |
| `shTab`, `shTabLip` | 4, 1.0 × 0.8 | Release tab above the lead-in, with a lip outward at the top, 45° underneath |

The tongue bends under the same moment as the arm's root, so it doesn't change the strain for
a given force; it lets the same opening happen at a quarter of the force, and so a quarter of
the strain. It bends up (the arm's foot tips outward), so it works with the carrier flat on a
floor as well as standing on bosses. `snapHookClear()` includes the tongue and slot: 6.9 past
the board's edge, so a 15.5 board with a hook each side needs 29.3, a 3-unit carrier.

## Fit piece

`make snap-hook` → `out/snap-hook_fit.3mf`. Four stations for the JZK module on one 1.6 plate
(a carrier's thickness, so the tongues behave as they will), windows between the pedestal and
the hooks. Prints base down, no supports, in PETG; PLA will crack at the longer reaches. Set
`variant` in `fit.scad` for another RS485 module.

| Dots | Reach | Clearance |
|---|---|---|
| 1 | 0.5 | 0.3 |
| 2 | 0.7 | 0.3 |
| 3 | 0.9 | 0.3 |
| 4 | 0.7 | 0.2 |

For each: push the board down. Do both hooks click over, with a thumb's push? Does it sit
flat on the pedestal without rattling, up or sideways? Lift one end and tug it sideways: does
it stay put? Pull it out: does it come without a hook cracking or staying bent? Write the
winner into `shReach` / `shClearance` and the results table below. If every station is hard
to press, print it again with `shThick` 1.2 before choosing.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
