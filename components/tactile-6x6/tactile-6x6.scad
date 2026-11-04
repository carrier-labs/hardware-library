//-----------------------------------------------------------------------
// 6 x 6 tactile switch, mounted on its side with the stem through a wall
//
// Push in and click: sit the switch on the seat a few mm back from the wall,
// legs to the sides, and push it forward. The stem goes into a plain round
// hole; the body pushes two flexing cheeks apart and their teeth snap in
// behind it. The teeth then take the press.
//
// Three modules, all in the same frame:
//   tact6x6Ghost()    the switch, for previews
//   tact6x6Holder()   the plastic inside the box: seat, cheeks and teeth
//   tact6x6WallCut()  subtract from the wall: the stem hole
//
// Frame: origin on the floor top at the wall's inner face, under the stem
// axis. +X into the box, Z up. The wall is X = -wall .. 0. Units: mm.
//
// standoff moves the switch back from the wall: use it when a stem is longer
// than you want standing proud (tact6x6Proud() says how far it stands).
// Sizes: the kit's switches by name in tact6Sizes ("lp", "4.3" .. "13");
// tact6x6Standoff(name, wall, proud) gives the standoff for a wanted proud.
//
// Use with `use <.../components/tactile-6x6/tactile-6x6.scad>`; call the
// modules inside translate/rotate to place them.
//-----------------------------------------------------------------------

//-- The switch. Defaults: BOJACK 6 x 6 low-profile, measured 2026-10-30
tact6Body      = 6.0;     // body, square
tact6BodyH     = 2.8;     // body thickness, mounting face to back (measured)
tact6Stem      = 3.6;     // stem length past the body's face (6.4 overall, measured)
tact6StemDia   = 3.5;     // measured
tact6LegPitch  = 6.5;     // legs leave two opposite sides at the back edge, this far apart
tact6LegSpan   = 4.5;     // the two legs on one side, apart
tact6LegLength = 3.5;     // past the body's back
tact6LegW      = 0.7;

//-- The holder
tact6Clearance = 0.3;     // between the body and each cheek
tact6Tooth     = 0.6;     // how far each tooth reaches in behind the body: CAL by the fit piece
tact6ToothRamp = 1.5;     // lead-in length behind the catch
tact6CatchGap  = 0.1;     // body's back to the catch faces: snug, so a press clicks instead of shoving it back
tact6HoleClear = 0.4;     // stem hole over the stem diameter
tact6Cheek     = 1.6;     // cheek thickness
tact6CheekGap  = 0.5;     // between the seat and each cheek, so the cheeks flex from the floor
tact6LegGroove = 1.4;     // grooves in the cheeks for the legs (0.7 legs, with their kinks)
tact6Start     = 1.0;     // stem tip to the wall when the switch is set down, before the push

//-- Sizes: the BOJACK 6 x 6 kit (B07ZN11155), by name. [name, overall, body]
//-- overall: back of the body to the stem tip, the kit listing's height. Only "lp" is
//-- measured; the others assume a 3.5 body: CAL each before relying on it
tact6Sizes = [
  ["lp",   6.4, 2.8],     // the low-profile one, measured 2026-10-30 (the defaults above)
  ["4.3",  4.3, 3.5],
  ["5",    5.0, 3.5],
  ["6",    6.0, 3.5],
  ["7",    7.0, 3.5],
  ["8",    8.0, 3.5],
  ["9",    9.0, 3.5],
  ["10",  10.0, 3.5],
  ["11",  11.0, 3.5],
  ["12",  12.0, 3.5],
  ["13",  13.0, 3.5],
];

function tact6Size(name) = let (i = search([name], tact6Sizes)[0])
  assert(i != [] && i != undef, str("unknown 6x6 size ", name)) tact6Sizes[i];
function tact6BodyHOf(name) = tact6Size(name)[2];
function tact6StemOf(name)  = tact6Size(name)[1] - tact6Size(name)[2];

//-- how far the stem stands proud of the wall's outer face
function tact6x6Proud(wall, standoff = 0, stem = tact6Stem) = stem - wall - standoff;

//-- the standoff that leaves a named switch's stem `proud` past a `wall`. Pass it to the
//-- modules with bodyH = tact6BodyHOf(name), stem = tact6StemOf(name)
function tact6x6Standoff(name, wall, proud) =
  let (s = tact6StemOf(name) - wall - proud)
  assert(s > -0.01, str("the ", name, " switch's stem is too short to stand ", proud, " past a ", wall, " wall"))
  max(s, 0);

//-- axisZ: stem axis above the floor; at least tact6Body/2 + 1
module tact6x6Ghost(axisZ, standoff = 0, bodyH = tact6BodyH, stem = tact6Stem)
{
  translate([standoff, 0, 0])
  {
    %color("DimGray") translate([0, -tact6Body/2, axisZ - tact6Body/2]) cube([bodyH, tact6Body, tact6Body]);
    %color("Black") translate([0, 0, axisZ]) rotate([0, -90, 0]) cylinder(d = tact6StemDia, h = stem, $fn = 24);
    for (s = [-1, 1], z = [-1, 1])
      %color("Silver") translate([bodyH, s*tact6LegPitch/2 - tact6LegW/2, axisZ + z*tact6LegSpan/2 - tact6LegW/2])
        cube([tact6LegLength, tact6LegW, tact6LegW]);
  }
}

module tact6x6Holder(axisZ, standoff = 0, clearance = tact6Clearance, tooth = tact6Tooth,
                     bodyH = tact6BodyH, stem = tact6Stem)
{
  half    = tact6Body/2;
  inner   = half + clearance;                       // cheek inner faces
  seatW   = inner - tact6CheekGap;                  // seat half-width: the cheeks clear it
  seatTop = axisZ - half;                           // the body rests on it, stem on the axis
  catchX  = standoff + bodyH + tact6CatchGap;       // teeth's catch faces, behind the body
  startX  = max(standoff + stem + tact6Start, catchX + tact6ToothRamp);   // body front when set down
  cheekX0 = max(standoff, 0.5);                     // clear of the wall, so the cheeks flex
  cheekX1 = catchX + tact6ToothRamp;
  legOut  = tact6LegPitch/2 + tact6LegW/2 + 0.3;    // groove depth: outside the legs and their kinks
  toothH  = tact6LegSpan - tact6LegGroove - 0.3;    // fits between the leg grooves
  assert(axisZ >= half + 1, "axisZ too low for the seat");

  //-- seat, from the wall back past where the switch is set down
  translate([0, -seatW, 0]) cube([startX + bodyH + 0.5, 2*seatW, seatTop]);
  //-- front stop when the body sits back from the wall
  if (standoff > 0)
    translate([standoff - 1.2, -seatW, 0]) cube([1.2, 2*seatW, seatTop + 1.5]);
  for (m = [0, 1])
    mirror([0, m, 0])
    {
      difference()
      {
        //-- cheek, from the floor to the body's top
        translate([cheekX0, inner, 0]) cube([cheekX1 - cheekX0, tact6Cheek, axisZ + half]);
        //-- grooves the legs slide along, open at the back
        for (z = [-1, 1])
          translate([standoff + bodyH - 0.6, inner - 1, axisZ + z*tact6LegSpan/2 - tact6LegGroove/2])
            cube([cheekX1, 1 + legOut - inner, tact6LegGroove]);
      }
      //-- tooth between the leg grooves: square catch face forward, ramp behind
      translate([0, 0, axisZ - toothH/2])
        linear_extrude(toothH)
          polygon([[catchX, inner + 0.01], [catchX, inner - tooth], [catchX + tact6ToothRamp, inner + 0.01]]);
    }
}

module tact6x6WallCut(axisZ, wall)
{
  translate([-wall - 1, 0, axisZ]) rotate([0, 90, 0])
    cylinder(d = tact6StemDia + tact6HoleClear, h = wall + 2, $fn = 32);
}
