//-----------------------------------------------------------------------
// Bridge: a snap-in bar over a part that can't be hooked
//
// For a LiPo pouch, or anything soft or without an edge to catch. Two
// uprights (posts) stand on the carrier either side of the part, and a
// SEPARATE printed bar snaps down into them with a pad of foam stuck
// under it. The bar's ends sit on the post tops, so its height is set by
// the posts, not by the snap; the squashed foam holds the part down.
//
// The snap: a flat foot hangs from each end of the bar into a slot in its
// post. The slot's mouth locates the foot; below the mouth the slot is
// wider, so the foot can flex inward. A barb on the foot's outer face
// rides over the post's outer wall on the way down and catches under its
// lip. The outer wall is open below the lip, so the barb shows there.
// Release: press a barb in with a thumbnail and lift that end, or squeeze
// both barbs between finger and thumb and lift the bar off.
//
// Modules, all in the same frame:
//   bridgePosts()  the two uprights: add to the carrier
//   bridgeBar()    the separate bar with its snap feet, drawn in place
//   bridgeGhost()  the bar and the squashed foam under it, for previews
//
// Frame: origin on the carrier's top at the centre of the span. The bar
// runs along X; the posts are centred at X = +-span/2. Y is across the
// bar's width, Z up. Units: mm.
//
// h is the bar's underside above the carrier top: brBarZ(partTop) gives it
// for a part whose top is at partTop (part top + foam - squeeze). The feet
// are h - brFootStop long and need brMinFoot to flex, so h >= 6.
//
// Print the bar on its back: top face down, feet up, no supports.
//
// Use with `use <.../components/bridge/bridge.scad>`.
//-----------------------------------------------------------------------

//-- The bar
brWidth      = 8;       // bar width (Y). The foot is the full width
brBarThick   = 2.0;     // bar thickness (Z)
brFoot       = 1.2;     // foot thickness (X): three 0.4 perimeters, thin enough to flex
brFootStop   = 1.0;     // foot tip above the carrier top, so it never bottoms out
brBarbLand   = 0.8;     // the barb's flat outer face, between the 45 deg lead-in and the catch face

//-- The foam under the bar (board-pocket's lid pads: bpFoam / bpSqueeze)
brFoam       = 3.0;     // CAL: self-adhesive foam stuck under the bar
brSqueeze    = 1.0;     // how far the bar squashes it: ~1/3 for soft foam

//-- The snap. CAL: set by the fit piece
brBarb       = 0.5;     // how far the barb reaches under the lip, measured from the lip's inner face
brFootClear  = 0.2;     // per side, foot to the slot's mouth and side walls
brCatchGap   = 0.2;     // catch face to the lip's underside when the bar sits on the post tops: the catch
                        // face prints as a 0.7 overhang (bar on its back) and sags a little

//-- The posts
brPostWall   = 1.6;     // walls round the slot: inner, outer (the lip) and the two sides
brMouth      = 1.5;     // depth of the slot's mouth: the part that locates the foot in X
brLipChamfer = 0.5;     // on the lip's top inner edge, to meet the barb's lead-in
brMinFoot    = 5;       // shortest foot that flexes far enough in PETG without cracking

//-- bar underside above the carrier top, over a part whose top is at partTop
function brBarZ(partTop, foam = brFoam, squeeze = brSqueeze) =
  assert(squeeze > 0 && squeeze < foam, "foam would not touch the part")
  partTop + foam - squeeze;

//-- the barb's protrusion from the foot's face: it reaches `barb` past the lip's inner
//-- face, which the foot sits `clearance` back from
function brBarbOut(clearance = brFootClear, barb = brBarb) = barb + clearance;
//-- a post's size along X: inner wall, the slot (foot, flex room, clearances), outer wall
function brPostX(clearance = brFootClear, barb = brBarb, foot = brFoot) =
  2*brPostWall + foot + 2*clearance + brBarbOut(clearance, barb);
//-- a post's size along Y
function brPostY(width = brWidth, clearance = brFootClear) = width + 2*(clearance + brPostWall);
//-- the bar's length: it covers the post tops, ends flush with their outer faces
function brBarLength(span, clearance = brFootClear, barb = brBarb, foot = brFoot) =
  span + brPostX(clearance, barb, foot);
//-- between the posts' inner faces: the part (and what holds it) must fit in this
function brInside(span, clearance = brFootClear, barb = brBarb, foot = brFoot) =
  span - brPostX(clearance, barb, foot);
//-- the span that leaves `margin` each side of a part `partW` wide
function brSpanFor(partW, margin = 1, clearance = brFootClear, barb = brBarb, foot = brFoot) =
  partW + 2*margin + brPostX(clearance, barb, foot);
//-- top of the bar above the carrier: the headroom a lid must clear
function brHeight(h) = h + brBarThick;
//-- the catch face of the barb, and the lip's underside, above the carrier top
function brCatchZ(clearance = brFootClear, barb = brBarb) = brFootStop + brBarbOut(clearance, barb) + brBarbLand;
function brLipZ(clearance = brFootClear, barb = brBarb) = brCatchZ(clearance, barb) + brCatchGap;

module bridgePosts(span, h, width = brWidth, clearance = brFootClear, barb = brBarb, foot = brFoot)
{
  px     = brPostX(clearance, barb, foot);
  py     = brPostY(width, clearance);
  sy     = width + 2*clearance;                    // slot width (Y)
  mouthX = foot + 2*clearance;                     // the mouth locates the foot
  roomX  = mouthX + brBarbOut(clearance, barb);    // below it: room for the foot to flex inward
  lipIn  = px/2 - brPostWall;                      // lip's inner face, from the post's centre
  lipZ   = brLipZ(clearance, barb);
  assert(h - brFootStop >= brMinFoot, str("bar too low: the feet would be ", h - brFootStop, " long, under ", brMinFoot));
  assert(h - lipZ >= 2, "bar too low for the lip");
  assert(width >= 4, "bar too narrow for the slot");

  for (m = [0, 1])
    mirror([m, 0, 0])
      translate([span/2, 0, 0])                    // the +X post; its outer wall at +X
        difference()
        {
          translate([-px/2, -py/2, -0.01]) cube([px, py, h + 0.01]);
          //-- the slot, open at the top and down to the carrier: mouth above, wider room
          //-- below, a 45 deg step between so the post prints base down
          translate([0, sy/2, 0]) rotate([90, 0, 0]) linear_extrude(sy)
            polygon([[lipIn, -1], [lipIn, h + 1], [lipIn - mouthX, h + 1], [lipIn - mouthX, h - brMouth],
                     [lipIn - roomX, h - brMouth - (roomX - mouthX)], [lipIn - roomX, -1]]);
          //-- the outer wall is open below the lip: the barb catches under it and shows there
          translate([lipIn - 0.01, -sy/2, -1]) cube([brPostWall + 1.02, sy, lipZ + 1]);
          //-- lead-in on the lip's top inner edge
          translate([0, sy/2 + 0.01, 0]) rotate([90, 0, 0]) linear_extrude(sy + 0.02)
            polygon([[lipIn - 0.01, h + 0.01], [lipIn + brLipChamfer, h + 0.01], [lipIn - 0.01, h - brLipChamfer - 0.01]]);
        }
}

//-- The bar, drawn where it sits when snapped in. Print it on its back: top face down
module bridgeBar(span, h, width = brWidth, clearance = brFootClear, barb = brBarb, foot = brFoot)
{
  px      = brPostX(clearance, barb, foot);
  L       = brBarLength(span, clearance, barb, foot);
  lipIn   = span/2 + px/2 - brPostWall;            // the lip's inner face
  footOut = lipIn - clearance;                     // foot's outer face, at rest
  p       = brBarbOut(clearance, barb);
  z0      = brFootStop;
  assert(h - brFootStop >= brMinFoot, str("bar too low: the feet would be ", h - brFootStop, " long, under ", brMinFoot));

  translate([-L/2, -width/2, h]) cube([L, width, brBarThick]);
  for (m = [0, 1])
    mirror([m, 0, 0])
      translate([0, width/2, 0]) rotate([90, 0, 0]) linear_extrude(width)
        //-- the foot, with its barb on the outer face: 45 deg lead-in from the tip, a flat
        //-- land, then the square catch face
        polygon([[footOut - foot, h + 0.01], [footOut - foot, z0], [footOut, z0],
                 [footOut + p, z0 + p], [footOut + p, z0 + p + brBarbLand], [footOut, z0 + p + brBarbLand],
                 [footOut, h + 0.01]]);
}

//-- pad: the foam's length along X, default the inside of the span less 2 each end
module bridgeGhost(span, h, width = brWidth, pad, foam = brFoam, squeeze = brSqueeze,
                   clearance = brFootClear, barb = brBarb, foot = brFoot)
{
  p = is_undef(pad) ? brInside(span, clearance, barb, foot) - 4 : pad;
  %color("LightSteelBlue") bridgeBar(span, h, width, clearance, barb, foot);
  %color("Gray") translate([-p/2, -width/2, h - (foam - squeeze)]) cube([p, width, foam - squeeze]);
}
