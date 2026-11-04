//-----------------------------------------------------------------------
// Board pocket: holds a board that has no mounting holes
//
// The board sits on a central pedestal with a pad of double-sided foam tape
// on top, inside a low wall that follows its outline. The pedestal keeps
// the board's edges off the floor, so lead stubs soldered through the edge
// holes have room underneath; gaps in the wall let the leads out. The wall
// only locates the board: the tape holds it down, and in a closed box a lid
// pad presses a pad of foam onto it (boardLidPad below).
//
// Modules, all in the same frame:
//   boardPocketGhost()   the board and its tape, for previews
//   boardPocketHolder()  the plastic: pedestal and outline wall, add to the floor
//   boardLidPad()        a block hanging from the lid that presses foam onto the board
//   boardLidPadGhost()   the foam under it, squashed, for previews
//
// Frame: origin on the floor top, under the centre of the board's outline.
// X along the board's length l, Y across its width w, Z up. Units: mm.
//
// Sides are listed [-X, +X, -Y, +Y], each one of
//   "gap"    wall with a gap in the middle for leads (gapW wide)
//   "solid"  whole wall: use it where the board takes a push (a plug)
//   "open"   no wall: the board's edge goes into a box wall (a USB port)
//
// Used by esp32-c3-supermini, esp32-s3-devkitc and rs485-max485.
//-----------------------------------------------------------------------

//-- From the controller project's receiver.scad / rack-end.scad (boardPocket), 2026-10-30
bpPedestal  = 2.5;     // floor to the tape: room for lead stubs under the board edges
bpTape      = 1.0;     // double-sided foam tape on the pedestal. CAL: how far it squashes
bpWall      = 1.2;     // outline wall thickness
bpRise      = 1.0;     // wall top above the PCB underside (the controller project's rack-end: 0.8 under the S3's module)
bpClearance = 0.4;     // per side, board outline to wall: PETG. 0.3 for PLA. Set by the fit piece
bpGapW      = 6;       // lead gap in a "gap" side
bpPadInset  = 4;       // default pedestal: the board less this all round

//-- Lid hold-down (the controller project's receiver / rack-end lid pads)
bpFoam      = 3.0;     // CAL: self-adhesive foam stuck under each lid pad
bpSqueeze   = 1.0;     // how far the lid squashes it: ~1/3 for soft foam, 0.3 for felt

//-- PCB underside above the floor top
function boardPocketZ(pedestal = bpPedestal, tape = bpTape) = pedestal + tape;
//-- default pedestal [l, w] for a board
function boardPocketPad(l, w, inset = bpPadInset) = [max(l - 2*inset, 4), max(w - 2*inset, 4)];
//-- Z of a lid pad's underside, pressing on a surface at surfaceZ (board top, or a part on it)
function boardLidPadZ(surfaceZ, foam = bpFoam, squeeze = bpSqueeze) =
  assert(squeeze > 0 && squeeze < foam, "foam would not touch the board")
  surfaceZ + foam - squeeze;

function bpSides4(s) = is_list(s) ? s : [s, s, s, s];

module boardPocketGhost(l, w, pcb = 1.6, pad, pedestal = bpPedestal, tape = bpTape)
{
  p = is_undef(pad) ? boardPocketPad(l, w) : pad;
  %color("White") translate([-p[0]/2, -p[1]/2, pedestal]) cube([p[0], p[1], tape]);
  %color("DarkGreen") translate([-l/2, -w/2, pedestal + tape]) cube([l, w, pcb]);
}

//-- pad: pedestal [l, w]; gapW a number or one per side
module boardPocketHolder(l, w, pad, sides = "gap", gapW = bpGapW, clearance = bpClearance,
                         pedestal = bpPedestal, tape = bpTape, wall = bpWall, rise = bpRise)
{
  p   = is_undef(pad) ? boardPocketPad(l, w) : pad;
  s   = bpSides4(sides);
  g   = bpSides4(gapW);
  ix  = l/2 + clearance;                 // inner half sizes
  iy  = w/2 + clearance;
  top = pedestal + tape + rise;
  assert(p[0] <= l && p[1] <= w, "pedestal bigger than the board");
  for (k = s) assert(k == "gap" || k == "solid" || k == "open", str("unknown side ", k));

  //-- pedestal, centred under the board
  translate([-p[0]/2, -p[1]/2, -0.01]) cube([p[0], p[1], pedestal + 0.01]);
  //-- outline wall
  difference()
  {
    translate([-ix - wall, -iy - wall, -0.01]) cube([2*(ix + wall), 2*(iy + wall), top + 0.01]);
    translate([-ix, -iy, -1]) cube([2*ix, 2*iy, top + 2]);
    for (i = [0 : 3])
    {
      //-- each side's cut, drawn for -X then turned into place
      ax = (i < 2) ? ix : iy;         // inner half size across the side
      al = (i < 2) ? iy : ix;         // half length along it
      rotate([0, 0, [0, 180, 90, 270][i]])   // -X, +X, -Y, +Y
      {
        if (s[i] == "gap")
          translate([-ax - wall - 1, -g[i]/2, -1]) cube([wall + 2, g[i], top + 2]);
        if (s[i] == "open")
          translate([-ax - wall - 1, -al - wall - 1, -1]) cube([wall + 1.01, 2*(al + wall + 1), top + 2]);
      }
    }
  }
}

//-- A lid pad over the rectangle size [x, y] centred at `at`, from the squashed foam up to
//-- lidZ (the lid's inner face in this frame), running `into` up into the lid plate
module boardLidPad(size, at = [0, 0], surfaceZ, lidZ, foam = bpFoam, squeeze = bpSqueeze, into = 0.5)
{
  z0 = boardLidPadZ(surfaceZ, foam, squeeze);
  assert(lidZ > z0, "lid is below the pad: the box is too low for the foam");
  translate([at[0] - size[0]/2, at[1] - size[1]/2, z0]) cube([size[0], size[1], lidZ - z0 + into]);
}

module boardLidPadGhost(size, at = [0, 0], surfaceZ, foam = bpFoam, squeeze = bpSqueeze)
{
  %color("Gray") translate([at[0] - size[0]/2, at[1] - size[1]/2, surfaceZ]) cube([size[0], size[1], foam - squeeze]);
}
