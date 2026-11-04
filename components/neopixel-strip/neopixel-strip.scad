//-----------------------------------------------------------------------
// WS2812B ("NeoPixel") strip piece, standing in a slot behind a window
//
// A cut piece of LED strip drops into a slot a few mm back from the wall,
// LEDs facing the wall. A front plate with a window holds it upright; the
// gap to the wall spreads the light. The wall gets an open window, a thin
// diffuser skin printed in the wall, or a round hole for a light pipe.
//
// Three modules, all in the same frame:
//   npxGhost()     the strip piece, for previews
//   npxHolder()    the plastic inside the box: base, slot, front plate
//   npxWallCut()   subtract from the wall: the window(s)
// npxSolid() is the piece as a plain solid (views, collision checks).
//
// Frame: origin on the floor top at the wall's inner face, level with the
// first LED's centre in Y. +X into the box, Z up. The wall is X = -wall .. 0.
// axisZ is the first LED's centre above the floor. Units: mm.
//
// The piece stands "up" (its length vertical, as in the controller project's controller
// base: LEDs in a column) or lies "along" the wall (length along +Y, width
// vertical: LEDs in a row). n is the number of LEDs on the piece.
//
// Strips: npxStrips by name (width and LEDs per metre); thickness from
// npxCoats ("bare", "ip30", "ip65") or a number. The piece length defaults
// to n pitches (cut on the pads between LEDs); pass the measured length.
//
// Use with `use <.../components/neopixel-strip/neopixel-strip.scad>`.
//-----------------------------------------------------------------------

//-- [name, strip width, LEDs per metre, LED size (square)]
npxStrips = [
  ["10mm-30",  10, 30,  5.0],
  ["10mm-60",  10, 60,  5.0],
  ["10mm-100", 10, 100, 5.0],     // in hand: BTF-LIGHTING B07JBYZRWD, white PCB, IP30
  ["12mm-74",  12, 74,  5.0],
  ["12mm-96",  12, 96,  5.0],
  ["12mm-144", 12, 144, 5.0],
  ["8mm-60",    8, 60,  5.0],     // CAL: narrow 5050 strips, no sample
  ["5mm-160",   5, 160, 2.0],     // CAL: WS2812B-2020 strips, no sample
];

//-- [name, thickness back of strip to LED top]
npxCoats = [
  ["bare", 2.13],
  ["ip30", 2.4],     // bare with its adhesive tape, 2.3, rounded up as in the controller base
  ["ip65", 3.0],     // silicone coat over the LEDs: about 3
];

function npxStrip(name) = let (i = search([name], npxStrips)[0])
  assert(i != [] && i != undef, str("unknown strip ", name)) npxStrips[i];
function npxWidth(name) = npxStrip(name)[1];
function npxPitch(name) = 1000/npxStrip(name)[2];
function npxLed(name)   = npxStrip(name)[3];
function npxThick(coat) = is_num(coat) ? coat :
  let (i = search([coat], npxCoats)[0]) assert(i != [] && i != undef, str("unknown coat ", coat)) npxCoats[i][1];
//-- a piece of n LEDs, cut on the pads either side
function npxPieceLength(name, n = 1) = n*npxPitch(name);

npxDefault     = "10mm-100";
npxCoatDefault = "ip30";
npxLedH        = 1.57;    // WS2812B 5050 body height (data sheet)

//-- The holder
npxClearance   = 0.4;     // slot over the strip, each side, width and thickness (controller base). CAL
npxGap         = 5;       // LED face to the wall's inner face: spreads the light (controller base)
npxPlate       = 1.6;     // front plate, between the slot and the wall
npxSide        = 1.6;     // slot side and back walls
npxLip         = 1.5;     // the front plate's window leaves this much plate over each strip edge
npxProud       = 1;       // the piece stands this far out of the top of the slot, to grip
//-- The window
npxWindow      = 8;       // open or skin window, square with rounded corners, per LED (controller base)
npxWindowR     = 1.5;
npxSkin        = 0.6;     // diffuser skin left at the wall's outer face: 0.4-0.8 (V, blog tests). CAL
npxPipeDia     = 5.2;     // hole for a 5 light pipe (acrylic rod or a clear printed plug). CAL

//-- LED centres, in (Y, Z) from the first one
function npxLeds(name, n, along) = [for (i = [0 : n - 1]) along ? [i*npxPitch(name), 0] : [0, i*npxPitch(name)]];

module npxSolid(axisZ, name = npxDefault, n = 1, along = false, length, coat = npxCoatDefault,
                ledOffset, clearance = npxClearance, gap = npxGap)
{
  W = npxWidth(name); P = npxPitch(name); t = npxThick(coat);
  L = is_undef(length) ? npxPieceLength(name, n) : length;
  off = is_undef(ledOffset) ? (L - (n - 1)*P)/2 : ledOffset;      // piece end to the first LED's centre
  led = npxLed(name);
  x0 = gap + clearance;                                           // LED face, against the plate side of the slot
  //-- the strip (PCB and tape), behind the LEDs
  translate([x0 + npxLedH - 0.01, 0, axisZ])
    if (along) translate([0, -off, -W/2]) cube([t - npxLedH + 0.01, L, W]);
    else translate([0, -W/2, -off]) cube([t - npxLedH + 0.01, W, L]);
  for (p = npxLeds(name, n, along))
    translate([x0, p[0] - led/2, axisZ + p[1] - led/2]) cube([npxLedH, led, led]);
}

module npxGhost(axisZ, name = npxDefault, n = 1, along = false, length, coat = npxCoatDefault,
                ledOffset, clearance = npxClearance, gap = npxGap)
{
  %color("White") npxSolid(axisZ, name, n, along, length, coat, ledOffset, clearance, gap);
}

module npxHolder(axisZ, name = npxDefault, n = 1, along = false, length, coat = npxCoatDefault,
                 ledOffset, clearance = npxClearance, gap = npxGap)
{
  W = npxWidth(name); P = npxPitch(name); led = npxLed(name);
  L = is_undef(length) ? npxPieceLength(name, n) : length;
  off = is_undef(ledOffset) ? (L - (n - 1)*P)/2 : ledOffset;
  c = clearance;
  t = npxThick(coat) + 2*c;                       // slot, front to back
  //-- the piece rests on the slot's bottom, so the LEDs sit at axisZ; clearance on the other sides
  span = W + 2*c;
  z0 = along ? axisZ - W/2 : axisZ - off;                         // slot bottom
  top = (along ? z0 + W : z0 + L) - npxProud;                     // holder top
  y0 = along ? -off - c : -span/2;  y1 = along ? L - off + c : span/2;
  xa = gap - npxPlate;                            // front plate's face
  xb = gap + t + npxSide;                         // back of the holder
  winLo = -led/2 - 1.5;  winHi = (n - 1)*P + led/2 + 1.5;   // along the run
  winHalf = span/2 - npxLip;                      // across
  assert(z0 >= 0, "the slot would go below the floor: raise axisZ");
  assert(xa >= 0.5, "gap too small for the front plate");
  assert(winHalf > led/2, "the lips would cover the LEDs: narrower npxLip");

  translate([0, 0, -0.01])
    difference()
    {
      translate([xa, y0 - npxSide, 0]) cube([xb - xa, y1 - y0 + 2*npxSide, top + 0.01]);
      //-- slot, open at the top
      translate([gap, y0, z0 + 0.01]) cube([t, y1 - y0, top + 1]);
      //-- window through the front plate
      translate([xa - 1, 0, axisZ + 0.01])
        if (along) translate([0, winLo, -winHalf]) cube([npxPlate + 2, winHi - winLo, 2*winHalf]);
        else translate([0, -winHalf, winLo]) cube([npxPlate + 2, 2*winHalf, top - axisZ - winLo + 1]);
      //-- lying along: the end walls cut down to the middle, for the wires off the end pads
      if (along)
        for (y = [y0 - npxSide - 1, y1 - 1])
          translate([gap, y, axisZ + 0.01]) cube([t, npxSide + 2, top]);
    }
}

//-- window: "open", "skin" (a diffuser left at the outer face) or "pipe" (round hole).
//-- bar: one window over all the LEDs instead of one each
module npxWallCut(axisZ, wall, name = npxDefault, n = 1, along = false, window = "open",
                  skin = npxSkin, size = npxWindow, bar = false, pipeDia = npxPipeDia)
{
  P = npxPitch(name);
  depth = window == "skin" ? wall - skin : wall + 2;
  x0 = window == "skin" ? -wall + skin : -wall - 1;
  assert(window == "open" || window == "skin" || window == "pipe", str("unknown window ", window));
  assert(window != "skin" || (skin > 0 && skin < wall), "skin must be thinner than the wall");
  span = (n - 1)*P;
  module shape()                                      // in the wall's plane: (Y, Z) as (x, y) after the rotate
    if (window == "pipe") circle(d = pipeDia, $fn = 32);
    else offset(r = npxWindowR, $fn = 24) square(size - 2*npxWindowR, center = true);
  translate([x0, 0, axisZ]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(depth + (window == "skin" ? 0.01 : 0))
      if (bar && n > 1 && window != "pipe")
        hull() for (p = npxLeds(name, n, along)) translate([p[0], p[1]]) shape();
      else
        for (p = npxLeds(name, n, along)) translate([p[0], p[1]]) shape();
}
