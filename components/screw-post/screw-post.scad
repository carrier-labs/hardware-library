//-----------------------------------------------------------------------
// Screw post: a round post off the floor that a board screws down onto
//
// Two ways to fix:
//   "nut"  clearance hole through the post and floor; the nut sits in a hex
//          trap in the floor's underside, so the screw goes in from the top
//   "tap"  a pilot hole the screw cuts its own thread in (one or two fittings
//          in PLA/PETG); blind, the floor stays whole underneath
// and "head" for a screw up from below (head in a counterbore, nut on top).
//
// Modules, all in the same frame:
//   screwPostGhost()     the screw (and nut), for previews
//   screwPost()          the post: add to the floor
//   screwPostFloorCut()  subtract from the floor: nut trap / counterbore and hole
//
// Frame: origin on the floor top, on the post's axis. Z up; the floor is
// Z = -floorThick .. 0. Units: mm.
//
// Sizes: "M2", "M2.5", "M3". screwPostScrew(size, ...) says which screw length
// reaches, so a project can assert it has that screw in the kit.
//-----------------------------------------------------------------------

//-- [name, screw Ø, nut across flats, nut thick, head Ø, head height, tap hole, post Ø]
//-- Nuts ISO 4032; heads ISO 7380 button. Tap holes: the usual ~0.8 x Ø for plastic
screwSizes = [
  ["M2",   2.0, 4.0, 1.6, 3.5, 1.1, 1.6, 5.0],
  ["M2.5", 2.5, 5.0, 2.0, 4.4, 1.4, 2.1, 6.0],    // head 4.4: measured on the kit's M2.5 (controller base)
  ["M3",   3.0, 5.5, 2.4, 5.7, 1.65, 2.5, 7.0],
];

screwHoleClear = 0.4;     // added to the screw Ø for a clearance hole
screwNutClear  = 0.3;     // CAL: across flats, nut trap over the nut. Set by the fit piece
screwTapClear  = 0.0;     // CAL: added to the tap hole. Set by the fit piece
screwHeadClear = 0.6;     // counterbore over the head Ø

function screwSize(size) = let (i = search([size], screwSizes)[0])
  assert(i != [] && i != undef, str("unknown screw size ", size)) screwSizes[i];
function screwDia(size)    = screwSize(size)[1];
function screwNutAF(size)  = screwSize(size)[2];
function screwNutH(size)   = screwSize(size)[3];
function screwHeadDia(size)= screwSize(size)[4];
function screwHeadH(size)  = screwSize(size)[5];
function screwPostDia(size)= screwSize(size)[7];

//-- Shortest screw that fills the nut, from the top of the clamped part (h + clamp
//-- above the floor) down to the nut trap's underside. Round up to a length you have.
function screwPostScrew(size, h, floorThick, clamp = 1.6) = h + clamp + floorThick;

module screwPostGhost(size, h, floorThick, clamp = 1.6, length, how = "nut")
{
  d = screwDia(size);
  L = is_undef(length) ? screwPostScrew(size, h, floorThick, clamp) : length;
  top = h + clamp;
  if (how == "head")
  {
    %color("Silver") translate([0, 0, -floorThick]) cylinder(d = screwHeadDia(size), h = screwHeadH(size), $fn = 24);
    %color("Silver") translate([0, 0, -floorThick + screwHeadH(size)]) cylinder(d = d, h = L, $fn = 16);
  }
  else
  {
    %color("Silver") translate([0, 0, top]) cylinder(d = screwHeadDia(size), h = screwHeadH(size), $fn = 24);
    %color("Silver") translate([0, 0, top - L]) cylinder(d = d, h = L, $fn = 16);
    if (how == "nut")
      %color("DimGray") translate([0, 0, -floorThick]) rotate([0, 0, 30]) cylinder(d = screwNutAF(size)/cos(30), h = screwNutH(size), $fn = 6);
  }
}

//-- how: "nut" | "head" (through hole) or "tap" (blind pilot hole). postDia defaults by size
module screwPost(size, h, how = "nut", postDia, tapClear = screwTapClear)
{
  pd = is_undef(postDia) ? screwPostDia(size) : postDia;
  hole = how == "tap" ? screwSize(size)[6] + tapClear : screwDia(size) + screwHoleClear;
  difference()
  {
    translate([0, 0, -0.01]) cylinder(d = pd, h = h + 0.01, $fn = 40);
    translate([0, 0, how == "tap" ? 0.6 : -1]) cylinder(d = hole, h = h + 2, $fn = 24);
    //-- lead-in so the screw starts square
    translate([0, 0, h - 0.4]) cylinder(d1 = hole, d2 = hole + 0.8, h = 0.41, $fn = 24);
  }
}

//-- "nut": hex trap from the underside, opening a little over the nut so it sits flush.
//-- "head": counterbore for the head. "tap": nothing.
module screwPostFloorCut(size, floorThick, how = "nut", nutClear = screwNutClear)
{
  d = screwDia(size) + screwHoleClear;
  if (how == "nut")
  {
    af = screwNutAF(size) + nutClear;
    translate([0, 0, -floorThick - 1]) rotate([0, 0, 30]) cylinder(d = af/cos(30), h = screwNutH(size) + 0.1 + 1, $fn = 6);
    translate([0, 0, -floorThick - 1]) cylinder(d = d + 0.4, h = floorThick + 2, $fn = 24);
  }
  if (how == "head")
  {
    translate([0, 0, -floorThick - 1]) cylinder(d = screwHeadDia(size) + screwHeadClear, h = screwHeadH(size) + 0.2 + 1, $fn = 32);
    translate([0, 0, -floorThick - 1]) cylinder(d = d + 0.4, h = floorThick + 2, $fn = 24);
  }
  assert(how == "tap" || floorThick >= (how == "nut" ? screwNutH(size) : screwHeadH(size)) + 0.1 + 0.3,
         str("floor too thin for the ", size, " ", how));
}
