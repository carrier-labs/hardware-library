# Carrier: parts on a 10 mm M2.5 grid

Enclosures in this library don't hold parts directly. Every bought part sits on a small printed
**carrier**: a plate of whole 10 mm grid units with M2.5 holes at its corners, and that part's
holder on top. A box floor offers only the grid points a design uses; a **bench plate** is the
whole grid, for prototyping. A carrier never knows which it is on, so a layout proved on the bench
moves into a box unchanged, and a part can be swapped by unscrewing its carrier. A custom PCB,
later, is a carrier with no part.

This README is the system's front page: the standard, then the two pieces of plastic that build
on it. First planned for the controller project (base, receiver and rack units, 2026-11-08).

![Fit piece](render.png)

**Status:** measured (the standard is a design; its one CAL number is the tap hole). Fit piece
not yet printed.

## The standard

| | |
|---|---|
| Grid | 10 mm pitch |
| Screw | M2.5, from above through the carrier. M2.5 × 6 is the standard length |
| Carrier | nx × ny whole grid units (5 × 2 = 50 × 20). Plate 1.6 thick |
| Holes | Ø2.9 on the grid points inset 5 from each edge: the four corners. A side 6 units or longer also gets a hole near its middle (one pair) |
| Fixing `"tap"` (default) | The screw cuts its own thread in a Ø2.1 blind hole in a Ø6 × 4 boss on the floor. Carriers stand on their bosses, leaving 4 mm under them for wires. Top of carrier 5.6 above the floor |
| Fixing `"nut"` | Carrier flat on the floor, Ø2.9 through, M2.5 nut trapped under a 2.4+ floor (`screwPostFloorCut`). Top 1.6 above the floor. For anything you'll undo often |
| Bench plate | 4 thick, Ø2.1 tap hole on every grid point (no nuts), 0.8 chamfer top and bottom |
| Frame | Carrier: origin at the plate's centre, Z = 0 on its **top** face, X along nx. A holder's frame (floor top) drops straight onto it |

Later option, not built: heat-set inserts in the bosses.

A 1 × 1 carrier has one hole; 1-wide strips have two, one at each end. A side of 6+ units gets
its middle hole on the grid point nearest the middle, which on an even side is the one just
below it (6 units: at −5, not 0). Never a hole in the middle of the plate.

## Use

A part's carrier is a wrapper: the plate, then the part's holder at Z = 0.

```openscad
use <../lib/hardware-library/components/carrier/carrier.scad>
use <../lib/hardware-library/components/rs485-max485/rs485-max485.scad>

// a 5 x 2 carrier for the RS485 module; solid, its holder needs the whole plate
module rs485Carrier()
{
  carrierPlate(5, 2, open = false);
  rs485Holder();
  if ($preview) { rs485Ghost(); carrierScrewGhost(5, 2); }
}
```

In a box floor, offer it the grid points (floor frame: floor top, under the carrier's centre):

```openscad
translate([x, y, floorTop])
{
  carrierBosses(5, 2);                               // "tap": add to the floor
  translate([0, 0, crSeatZ("tap")]) rs485Carrier();  // 5.6 up
}
// in the floor's difference(), whichever fixing:
translate([x, y, floorTop]) carrierFloorCut(5, 2, floorThick, "tap");
```

For `"nut"`, leave the bosses out, seat at `crSeatZ("nut")` (1.6) and cut with `"nut"`: the
floor must be 2.4 or more. **Always subtract `carrierFloorCut`**: with `"tap"` it runs the pilot
hole 0.9 on into the floor, because a Ø6 × 4 boss is shorter than an M2.5 × 6 reaches through a
1.6 plate (floor at least 1.5; a 5 mm screw stays inside the boss).

On the bench: `benchPlate(6, 6)`, and `crOnBench(6, 6, nx, ny, i, j)` gives where to put a
carrier so its −X −Y hole lands on bench grid point (i, j). `carrierGhost(nx, ny)` is the plate
as a ghost, for a part's own preview; `carrierScrewGhost(nx, ny, how)` the screws and nuts.

`crSize(nx, ny)` → [L, W]; `crHoles(nx, ny)` → the hole centres; `crSeatZ(how)` → the carrier
top above the floor (`"tap"` 5.6, `"nut"` and `"bench"` 1.6).

## Sizes

Any nx × ny. Carriers the controller project plans, from its parts' footprints:

| Part | Carrier | Open? |
|---|---|---|
| TTL-RS485 module (JZK, 43 × 15.5) | 5 × 3 | solid: the hooks' relief slots need plate |
| WAGO 221-415 clip | 3 × 5 | opened under the body; on a 3 × 4 the screw heads land under its corners |
| 602530 LiPo cradle | 4 × 5 | window under the pack; the bridge posts need the width |
| FireBeetle 2 on M2 posts | 7 × 3 | open, with the mid hole pair |
| ESP32-S3 DevKitC-1 pocket | 7 × 3 | solid; a unit longer than the hooks need so their feet stay out of the screw-head cells |

The screw heads (Ø4.4, 1.4 proud) sit on the plate at every hole: keep the holder's plastic clear of a
10 × 10 cell round each hole, or at least head radius + 0.5 from its centre, and leave a driver room above. That
rule, not the holder's outline, is what usually sets the size.

Smallest useful: 2 × 2 (a single WAGO 221-412). Plates whose opening would be narrower than 8
stay solid (2 × 2, 3 × 1, 4 × 1).

## Dimensions

| Variable | Value (mm) | Source |
|---|---|---|
| `crGrid` | 10 | The standard, 2026-11-08 |
| `crScrew` | `"M2.5"` | The standard; the kit is an M2.5 stainless assortment 4–25 with nuts |
| `crHole` | 2.9 | screw-post: Ø2.5 + 0.4 clearance |
| `crTap` | 2.1 | screw-post's tap hole for M2.5 (~0.8 × Ø). **CAL**: the fit piece tries 1.9–2.2 |
| `crPlate` | 1.6 | The standard |
| `crInset` | 5 | Half a grid: the holes sit on grid points |
| `crBossH` × `crBossDia` | 4 × Ø6 | The standard; Ø6 is screw-post's M2.5 post |
| `crBenchThick` | 4 | The standard |
| `crScrewLen` | 6 | The standard: M2.5 × 6 |
| Screw head | Ø4.4 × 1.4 | screw-post: measured on the kit's M2.5 |
| Nut | 5.0 AF × 2.0 | screw-post: ISO 4032 |

## Design values

| Variable | Value | Why |
|---|---|---|
| `crMidFrom` | 6 | A side this long gets a middle hole pair, so a 70 plate can't bow off its bosses |
| `crFrame` | 3 | Solid border round an open plate's window |
| `crRib` | 2 | Rib across the window at each mid hole pair |
| `crOpenMin` | 8 | Smaller windows aren't worth the plastic they save |
| Hole cells | 10 × 10 | Each hole's grid cell stays solid: 3.55 round the hole, more than the 3 asked |
| `crTapRunout` | 0.5 | Pilot hole past the screw's tip, so it never bottoms |
| `crFloorSkin` | 0.6 | Floor left whole under a pilot hole |
| `crFloorNut` | 2.4 | Thinnest floor for `"nut"`: a 2.0 nut and 0.4 over it |
| `crBenchChamfer` | 0.8 | Bench edges, top and bottom; 45°, prints without support |
| Lead-in | 0.4 × 45° | On every tap hole, so the screw starts square (as screw-post) |

## Fit piece

`make carrier` → `out/carrier_fit.3mf`. A 5 × 2 piece of bench plate (50 × 20 × 4), base down,
no supports, in the enclosure's material. Drive an M2.5 × 6 into each tap hole with a
screwdriver; drop one through the Ø2.9 hole.

| Dots | Tap hole |
|---|---|
| 1 | 1.9 |
| 2 | 2.0 |
| 3 | 2.1 (the standard) |
| 4 | 2.2 |
| "2.9" | clearance hole |

Checks: does the screw cut a thread rather than force one? Does the head pull down firm, and
stay firm after taking it out and back in twice? Does the plate stay whole round the hole, no
split and no bulge underneath? Does a screw drop through the 2.9? Write the winner into `crTap`
(it is screw-post's tap hole plus `screwTapClear`: set that if it should move for every M2.5
post, or `crTap` if only here) and the table below.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
