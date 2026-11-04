//-----------------------------------------------------------------------
// DFRobot FireBeetle 2 ESP32-E (DFR0654) on four screw posts, its USB-C
// socket through the box wall, flush
//
// The board lies flat, component side up, USB end against the wall. The
// socket sits in a close-fitting pocket walled in on all sides, face level
// with the outside (usb-c-port), and the board's end tucks into a shallow
// relief in the wall's inner face. The posts are placed from where that puts
// the board's edge, so the board butts right into the wall. Slide the board
// in over the post tops, socket first, then screw down: M2 from the top into
// nuts trapped in the floor ("nut", default), or self-tapping ("tap").
//
// The USB-end holes are so close to the wall that a screw head (or nut, for
// "head") can't come straight down past it: a shallow channel in the wall's
// inner face lets it through. The red charge LED next to the socket is now
// behind the wall, so a small light hole beside the port shows it (ledHole).
//
// Modules, all in the same frame:
//   fbGhost()     the board, socket, LEDs, screws and nuts, for previews
//   fbHolder()    the plastic inside the box: the posts. Add AFTER cutting
//                 the wall, so the relief doesn't take the posts' tops off
//   fbWallCut()   subtract from the wall: USB pocket, board relief, light
//                 hole, screw-head channels
//   fbFloorCut()  subtract from the floor (and wall): nut traps, screw holes
//
// Frame (as usb-c-port): origin on the floor top at the wall's inner face,
// under the socket's axis. +X into the box, Z up. The wall is X = -wall .. 0,
// the floor Z = -floorThick .. 0. The board's battery-socket edge (board
// x = width) faces +Y. Units: mm.
//
// Board frame (the numbers in fbVariants, as the controller project's parts sheet): component
// side up, USB end at +Y, origin at the corner at the far (antenna) end.
//
// Sizes: fbVariants, by name: "ESP32-E" (default), "ESP32-S3", "ESP32-C6"
// (same 60 x 25.4 outline and holes), "ESP32" (DFR0478, micro-USB: posts
// only, fbWallCut asserts). Pass postH, how, postDia for anything else.
//
// Use with `use <.../components/firebeetle-esp32e/firebeetle-esp32e.scad>`.
//-----------------------------------------------------------------------

use <../usb-c-port/usb-c-port.scad>
use <../screw-post/screw-post.scad>

//-- [0 name, 1 sku, 2 length, 3 width, 4 pcb, 5 screw, 6 hole inset x, 7 hole inset y,
//--  8 usb ("C" | "microB"), 9 socket centre x, 10 overhang past the edge, 11 shell height,
//--  12 charge LED [x, y], 13 RGB LED [x, y] (or []), 14 side buttons y (0: none),
//--  15 battery socket y on the +x edge (0: unknown)]
//-- Sources and CAL flags: README. ESP32-E from the official STEP/drawing; S3 and C6
//-- outline and holes from DFRobot's drawings, socket and LED positions estimated (CAL).
fbVariants = [
  ["ESP32-E",  "DFR0654", 60.0, 25.4, 1.6, "M2", 1.7, 1.7, "C",      12.68, 1.47, 3.2, [20.00, 58.29], [12.68, 39.09], 53.23, 45.6],
  ["ESP32-S3", "DFR0975", 60.0, 25.4, 1.6, "M2", 1.7, 1.7, "C",      12.70, 1.47, 3.2, [20.0, 58.0],   [],             52.2,  44.6],
  ["ESP32-C6", "DFR1075", 60.0, 25.4, 1.6, "M2", 1.7, 1.7, "C",      12.70, 1.47, 3.2, [19.2, 57.7],   [],             52.5,  45.4],
  ["ESP32",    "DFR0478", 58.0, 29.0, 1.6, "M3", 2.5, 2.5, "microB",  9.9,  0.0,  2.6, [4.8, 47.3],    [],             0,     0],
];

//-- The holder
fbPostH       = 4.7;      // floor top to board underside: M2 x 8 from the top ends 0.3 inside the nut
                          // on a 2.0 floor (the controller project's base). Clears header pin tails
fbHow         = "nut";    // "nut" | "tap" | "head", as screw-post
fbPostShift   = 0;        // posts further from the wall (+X): the socket face sits back by this
fbClearance   = 0.15;     // CAL: USB pocket per side, from the usb-c-port fit piece
fbChannelGap  = 0.3;      // screw-head channel over the head (or nut), per side
fbHoleClear   = 0.4;      // = screw-post screwHoleClear (variables don't cross `use`)
fbTapClear    = 0.0;      // = screw-post screwTapClear

//-- The light hole for the charge LED
fbLedHole     = true;     // only cut when the LED is within fbLedReach of the USB edge
fbLedHoleDia  = 1.5;
fbLedHoleLift = 0.2;      // hole's bottom above the board's top
fbLedReach    = 3.0;

fbUsbDepth    = 7.35;     // socket shell, face to back (usb-c-port); ghost only
fbCornerR     = 1.5;      // board corners; ghost only

//-- variant lookup
function fbVariant(v) = is_list(v) ? v : let (i = search([v], fbVariants)[0])
  assert(i != [] && i != undef, str("unknown FireBeetle ", v)) fbVariants[i];
function fbLength(v)   = fbVariant(v)[2];
function fbWidth(v)    = fbVariant(v)[3];
function fbPcb(v)      = fbVariant(v)[4];
function fbScrew(v)    = fbVariant(v)[5];
function fbOverhang(v) = fbVariant(v)[10];
function fbShellH(v)   = fbVariant(v)[11];
//-- socket centre across the board from its centre line, as usbcWallCut's shift
function fbShift(v)    = fbVariant(v)[9] - fbWidth(v)/2;

//-- socket axis above the floor
function fbAxisZ(v = "ESP32-E", postH = fbPostH) = postH + fbPcb(v) + fbShellH(v)/2;
//-- X of the board's USB edge (negative: inside the wall)
function fbEdgeX(v = "ESP32-E", wall, postShift = fbPostShift) = usbcBoardEdgeX(wall, fbOverhang(v)) + postShift;
//-- board frame -> this frame
function fbToFrame(v, wall, bx, by, postShift = fbPostShift) =
  [fbEdgeX(v, wall, postShift) + fbLength(v) - by, bx - fbVariant(v)[9]];
//-- the posts: posts = "all" | "usb" (the two at the USB end) | "far"
function fbHoles(v = "ESP32-E", wall, postShift = fbPostShift, posts = "all") =
  let (f = fbVariant(v), L = fbLength(v), W = fbWidth(v),
       ys = posts == "usb" ? [L - f[7]] : posts == "far" ? [f[7]] : [f[7], L - f[7]])
  [ for (bx = [f[6], W - f[6]], by = ys) fbToFrame(v, wall, bx, by, postShift) ];
//-- the screw to buy: shortest that fills the nut ("nut"), round up to a length you have
function fbScrewLength(v = "ESP32-E", floorThick = 2.0, postH = fbPostH) =
  screwPostScrew(fbScrew(v), postH, floorThick, fbPcb(v));

module fbGhost(v = "ESP32-E", wall = 2.4, floorThick = 2.0, postH = fbPostH, how = fbHow,
               postShift = fbPostShift, posts = "all", screwLength = 8)
{
  f = fbVariant(v);
  L = fbLength(v); W = fbWidth(v); pcb = fbPcb(v);
  ex = fbEdgeX(v, wall, postShift);
  top = postH + pcb;
  %color("DarkSlateGray") translate([ex, -f[9], postH]) linear_extrude(pcb)
    offset(r = fbCornerR, $fn = 16) offset(delta = -fbCornerR) square([L, W]);
  if (f[8] == "C")
    %color("Silver") translate([ex - fbOverhang(v), 0, fbAxisZ(v, postH)]) rotate([0, 90, 0]) rotate([0, 0, 90])
      linear_extrude(fbUsbDepth) usbcShell2D(h = fbShellH(v));
  else
    %color("Silver") translate([ex - fbOverhang(v), -3.75, top]) cube([5.0, 7.5, f[11]]);
  led = fbToFrame(v, wall, f[12][0], f[12][1], postShift);
  %color("Red") translate([led[0] - 0.25, led[1] - 0.5, top]) cube([0.5, 1.0, 0.4]);
  if (len(f[13]) == 2)
  {
    rgb = fbToFrame(v, wall, f[13][0], f[13][1], postShift);
    %color("White") translate([rgb[0] - 1, rgb[1] - 1, top]) cube([2, 2, 0.8]);
  }
  if (f[14] > 0)
    for (bx = [0, W])
    {
      b = fbToFrame(v, wall, bx, f[14], postShift);
      %color("Gainsboro") translate([b[0] - 1.5, b[1] - 1.5, top]) cube([3, 3, 1.9]);
    }
  if (f[15] > 0)
  {
    b = fbToFrame(v, wall, W, f[15], postShift);
    %color("White") translate([b[0] - 3, b[1] - 4.5, top]) cube([6, 4.5, 5.0]);
  }
  for (h = fbHoles(v, wall, postShift, posts))
    translate([h[0], h[1], 0]) screwPostGhost(fbScrew(v), postH, floorThick, pcb, screwLength, how);
}

//-- the posts. postDia defaults by screw size (M2: 5.0)
module fbHolder(v = "ESP32-E", wall = 2.4, postH = fbPostH, how = fbHow, postDia,
                postShift = fbPostShift, posts = "all")
{
  for (h = fbHoles(v, wall, postShift, posts))
    translate([h[0], h[1], 0]) screwPost(fbScrew(v), postH, how, postDia);
}

//-- nut traps (or head counterbores) from below, and the screw holes through the floor
//-- and up through any wall the posts run into. nutClear defaults to screw-post's screwNutClear
module fbFloorCut(v = "ESP32-E", wall = 2.4, floorThick = 2.0, postH = fbPostH, how = fbHow,
                  nutClear, postShift = fbPostShift, posts = "all")
{
  s = fbScrew(v);
  for (h = fbHoles(v, wall, postShift, posts))
    translate([h[0], h[1], 0])
    {
      if (is_undef(nutClear)) screwPostFloorCut(s, floorThick, how);
      else screwPostFloorCut(s, floorThick, how, nutClear);
      if (how != "tap")
        translate([0, 0, -0.5]) cylinder(d = screwDia(s) + fbHoleClear, h = postH + 1, $fn = 24);
      else
        translate([0, 0, 0.6]) cylinder(d = screwSize(s)[6] + fbTapClear, h = postH, $fn = 24);
    }
}

//-- channelTop: how high the screw-head channels run (the wall's top, above the floor)
module fbWallCut(v = "ESP32-E", wall = 2.4, postH = fbPostH, how = fbHow, clearance = fbClearance,
                 postShift = fbPostShift, ledHole = fbLedHole, ledDia = fbLedHoleDia, channelTop = 50)
{
  f = fbVariant(v);
  assert(f[8] == "C", str("FireBeetle ", f[0], ": fbWallCut is USB-C only (", f[8], ")"));
  pcb = fbPcb(v);
  top = postH + pcb;
  //-- pocket and relief at the nominal position: postShift is a fit-test nudge, within the relief gap
  usbcWallCut(fbAxisZ(v, postH), wall, fbOverhang(v), fbWidth(v), pcb, shift = fbShift(v),
              clearance = clearance, shellH = fbShellH(v));
  //-- light hole beside the port, level with the LED, just above the board
  if (ledHole && fbLength(v) - f[12][1] <= fbLedReach)
  {
    led = fbToFrame(v, wall, f[12][0], f[12][1], postShift);
    translate([-wall - 1, led[1], top + fbLedHoleLift + ledDia/2]) rotate([0, 90, 0])
      cylinder(d = ledDia, h = wall + 1.01, $fn = 20);
  }
  //-- channel for the screw head (or the nut, for "head") to come down past the wall
  s = fbScrew(v);
  passD = (how == "head" ? screwNutAF(s)/cos(30) : screwHeadDia(s)) + 2*fbChannelGap;
  for (h = fbHoles(v, wall, postShift, "usb"))
    if (h[0] - passD/2 < 0)
    {
      assert(h[0] - passD/2 > -wall + 0.8, "screw-head channel would leave under 0.8 of wall");
      translate([h[0], h[1], top]) cylinder(d = passD, h = channelTop - top, $fn = 32);
    }
}
