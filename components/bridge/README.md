# Bridge, a snap-in bar over a soft part

For a part that can't be hooked: a LiPo pouch, or anything soft or without an edge to catch.
Two **posts** stand on the carrier either side of the part, and a **separate printed bar**
snaps down into them with a pad of self-adhesive foam stuck under it. The bar's ends sit on
the post tops, so how far the foam is squashed is set by the posts, not by the snap: the
foam takes up the part's tolerance and holds it down without a hard edge on it.

**The snap.** A flat foot hangs from each end of the bar into a slot in its post. The top of
the slot (the mouth) locates the foot; below it the slot is wider, so the foot can flex
inward. A barb on the foot's outer face rides over the post's outer wall on the way down and
catches under its lip. The outer wall is open below the lip, so the barb shows there.

**Release:** press a barb in through that opening with a thumbnail and lift that end; or
squeeze both barbs between finger and thumb (the bar's ends are flush with the posts' outer
faces, so that is a natural grip) and lift the bar off whole. With one end lifted, the other
comes free when you press its barb.

First used in the controller project (controller base, over the 602530 pack, 2026-11-08).

![Fit piece](render.png)

**Status:** measured. Fit piece not yet printed.

## Use

```openscad
use <../lib/hardware-library/components/bridge/bridge.scad>
use <../lib/hardware-library/components/lipo-cradle/lipo-cradle.scad>

// on a carrier. Frame: carrier top, centre of the span; the bar runs along X
span = brSpanFor(29);            // 36.5: over a 602530's cradle, 29 across, 1 clear each side
h    = brBarZ(6.0);              // 8: the pack's top is 6 up; 3 foam squashed by 1
lipoCradle("602530");            // the pack along the carrier's X, lead at -X
rotate([0, 0, 90])               // the bar across the pack's width
{
  bridgePosts(span, h);          // add to the carrier
  if ($preview) bridgeGhost(span, h);
}
echo(brHeight(h));               // 10: the bar's top, which a lid must clear
```

The bar is its own print: `rotate([180, 0, 0]) bridgeBar(span, h);` exported on its own
lands it top face down, feet up, as it should print. Stick the foam under it (between the
posts: `brInside(span)` long, less a couple of mm) and snap it on.

`span` is between the post centres. The part and whatever holds it must fit in
`brInside(span)` = span − 5.5; `brSpanFor(w, margin)` gives the span that leaves `margin`
each side of something `w` wide. `brBarZ(partTop)` is the bar's underside, `brHeight(h)` its
top. All the modules take `width`, `clearance`, `barb` and `foot`, defaulting to the
variables; pass the same values to the posts and the bar.

## Sizes

Nothing in the bridge knows what is under it: three numbers size it.

| | Range | Set by |
|---|---|---|
| `span` | any | the holder's outside plus a margin: `brSpanFor()` |
| `width` | 4 and up; 8 default | how wide a foam pad you want on the part |
| `h` | 6 and up | the part's top: `brBarZ()`. Below 6 the feet are too short to flex |

Worked out for the packs in [lipo-cradle](../lipo-cradle/), each in its cradle (0.4 clearance,
1.6 wall), the bar across the pack's width:

| Pack | Thick × wide | Cradle outside | `span` | `h` |
|---|---|---|---|---|
| 602530 | 6.0 × 25 | 29 | 36.5 | 8 |
| 503035 | 5.0 × 30 | 34 | 41.5 | 7 |
| 603450 | 6.0 × 34 | 38 | 45.5 | 8 |
| 803860 / PKCell 2000 | 8.0 × 38 | 42 | 49.5 | 10 |

A 10 thick 103450 wants h = 12 and a 13 long foot: fine. A 4 thick 402030 gives h = 6, the
shortest the feet allow.

## Dimensions

None of its own: the bar and posts are all design values, and the part under them comes
from its own component.

## Design values

| Variable | Value | Why |
|---|---|---|
| `brWidth` | 8 | Bar width; the foot is the full width |
| `brBarThick` | 2.0 | Bar thickness |
| `brFoot` | 1.2 | Foot thickness: three 0.4 perimeters, thin enough to flex 0.7 over 7 |
| `brFootStop` | 1.0 | Foot tip above the carrier, so the bar always lands on the post tops |
| `brBarbLand` | 0.8 | The barb's flat face between the lead-in and the catch face |
| `brFoam` / `brSqueeze` | 3.0 / 1.0 | **CAL**: board-pocket's lid pad foam, and how far it squashes |
| `brBarb` | 0.5 | **CAL**: how far the barb reaches under the lip, from the lip's inner face |
| `brFootClear` | 0.2 | **CAL**: per side, foot to the slot's mouth and sides. Set by the fit piece |
| `brCatchGap` | 0.2 | Catch face to the lip when the bar sits on the posts. The catch face prints as a 0.7 overhang and sags a little; under the foam's push the bar can float up by this much |
| `brPostWall` | 1.6 | Post walls: inner, outer (the lip) and sides |
| `brMouth` | 1.5 | Depth of the slot's mouth, which locates the foot in X; below it the slot opens 0.7 more with a 45° step so the post prints base down |
| `brLipChamfer` | 0.5 | On the lip's top inner edge, meeting the barb's 45° lead-in |
| `brMinFoot` | 5 | Shortest foot that flexes 0.7 in PETG; `bridgePosts` and `bridgeBar` stop with an error below it |

Derived: a post is 5.5 along the span × 11.6 across (`brPostX()`, `brPostY()`); the bar is
span + 5.5 long; the barb's catch face is 2.5 above the carrier and the lip's underside 2.7.

The barb protrudes `brBarb + clearance` from the foot, so it reaches `brBarb` under the lip
whatever the clearance, and the foot has to flex that far to go in. Both feet face outward:
the slot's mouth limits the bar's slide along the span to the clearance, so neither barb can
walk off its lip.

## Fit piece

`make bridge` → `out/bridge_fit.3mf`. Prints base down, no supports, in the enclosure's
material. Span 20, h 8 (a 602530 under 3 foam), barb 0.5 throughout: four pairs of posts on
one strip, each with its bar printed beside it on its back, feet up. Each bar is joined to the
strip by a **0.4 × 0.8 breakaway sprue**, so the piece is one part until you twist the bars
off; the mesh check counts it as one. The floor between each pair of posts is open.

| Dots | Foot clearance |
|---|---|
| 1 | 0.1 |
| 2 | 0.2 |
| 3 | 0.3 |
| 4 | 0.4 |

For each: twist the bar off its sprue. Push it down into its posts: does it click at both
ends without forcing? Does it sit on the post tops without rocking or sliding along the
span? Lift it by the middle: do both barbs hold? Press one barb in with a thumbnail: does
that end lift? Squeeze both and lift: does the bar come off whole? Five times in and out:
has a foot whitened or cracked? Write the winner into `brFootClear` and the results table
below. If every bar is loose or every bar is tight, the barb is wrong, not the clearance:
change `brBarb` and print again.

## Results

| Date | Material | Best | Notes |
|---|---|---|---|
| — | | | |
