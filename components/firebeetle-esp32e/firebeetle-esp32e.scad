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
// On a carrier (carrier.scad) the same four posts stand on a 7 x 3 plate,
// self-tapping, with a lip across the USB end that bears on the box wall's
// inner face so the socket lands flush whatever the grid play:
//   fbCarrier()       the plate with the posts and the lip on it, as plastic
//   fbCarrierGhost()  the board seated on it, and the screws, for previews
//   fbCarrierSize()   [nx, ny] grid units; fbCarrierWallX() the X of the
//                     wall's inner face in the carrier frame; fbCarrierAt()
//                     where this frame sits in the carrier's
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
include <../carrier/carrier.scad>     // included, not used, so crPlate, crGrid, crHow are in scope; draws nothing

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

//-----------------------------------------------------------------------
// On a carrier. Carrier frame (carrier.scad): origin at the plate's centre,
// Z = 0 on the plate's top (the plate is Z = -1.6 .. 0), X along the plate.
// The USB end is at -X: the plate's -X edge IS the box wall's inner face,
// and a lip across that end bears on it, so the carrier registers on the
// wall and not on its screws (the Ø2.9 holes give it 0.2 of play). The
// frame above sits at fbCarrierAt(): same axes, +X into the box, so
// fbWallCut() goes in the box wall at that point.
//
// The four posts are the holder's, self-tapping (no floor to trap a nut
// in), M2 x 6: the pilot holes run on through the post into the plate,
// leaving fbCarrierSkin under them. The two USB-end posts are 0.77 inside
// the wall face (the board tucks 0.93 into the wall; the holes are 1.7 in),
// so by default (usbPosts = "rest") they are plain pedestals: the socket's
// pocket in the wall holds the USB end, as the S3's carrier does, and the
// far pair carries the screws. usbPosts = "tap" taps all four: the USB-end
// posts are then cut off flush at the plate's edge, merged with the lip,
// and their Ø1.6 pilot holes break that face by 0.03 (the wall closes them).
//-----------------------------------------------------------------------

//-- The carrier
fbCarrierWall      = 2.4;    // the box wall the lip bears on. The board's edge lands overhang - wall from the
                             // wall's inner face (-0.93: into the wall, so the socket is flush), and the posts
                             // follow it: cut the carrier for the wall you'll use
fbCarrierScrewLen  = 6;      // M2 x 6 into the posts: 4.4 of thread. An M2 x 8 would come out under the plate
fbCarrierLip       = 2.0;    // wall lip: a bar across the USB end of the plate, bearing on the wall's inner face
fbCarrierLipH      = 3.5;    // its height above the plate: under the board (1.2 clear), below the wall's relief
fbCarrierPad       = 2.0;    // plate kept solid this far round each post when the plate is opened
fbCarrierHeadGap   = 0.3;    // notch in a post for a carrier screw head beside it, per side (Ø5.0 x 1.7)
fbCarrierHoleClear = 0.0;    // a post may stand up to this close to a carrier hole's edge (the head notch keeps
                             // it 1.05 off where the head sits), else the carrier grows a unit
fbCarrierSkin      = 0.6;    // plate left under a pilot hole that runs on into it
fbCarrierRunout    = 0.5;    // pilot hole past the screw's tip, so it never bottoms
fbCarrierBatteryH  = 5.0;    // the PH2.0 battery socket above the board: the tallest thing on it

//-- the posts in the carrier frame of an nx x ny plate, from fbHoles (X from the wall face, Y from
//-- the socket axis): the wall face is the plate's -X edge, the board centred across it
function fbCarrierPosts(v = "ESP32-E", wall = fbCarrierWall, postShift = fbPostShift, nx, posts = "all") =
  [for (h = fbHoles(v, wall, postShift, posts)) [h[0] - nx*crGrid/2, h[1] + fbShift(v)]];

//-- does every post keep fbCarrierHoleClear off every carrier hole of an nx x ny plate?
function fbCarrierFits(v, wall, postShift, nx, ny) =
  let (pd = screwPostDia(fbScrew(v)))
  [for (p = fbCarrierPosts(v, wall, postShift, nx), q = crHoles(nx, ny))
     if (norm(p - q) < pd/2 + crHole/2 + fbCarrierHoleClear) 1] == [];

//-- [nx, ny] grid units: the smallest plate that takes the posts (across: the holes 22.0 apart plus
//-- a Ø5 post; along: the far posts from the wall face), grown while a post would run into a
//-- carrier hole. 6 x 3 would put the FireBeetle 2's far posts on the corner holes: 7 x 3 (70 x 30)
function fbCarrierSize(v = "ESP32-E", wall = fbCarrierWall, postShift = fbPostShift) =
  let (f = fbVariant(v), pd = screwPostDia(fbScrew(v)),
       ny0 = ceil((fbWidth(v) - 2*f[6] + pd)/crGrid - 1e-6),
       nx0 = ceil((max([for (h = fbHoles(v, wall, postShift)) h[0]]) + pd/2)/crGrid - 1e-6),
       ok = [for (dx = [0 : 3], dy = [0 : 3]) if (fbCarrierFits(v, wall, postShift, nx0 + dx, ny0 + dy)) [nx0 + dx, ny0 + dy]],
       area = min([for (t = ok) t[0]*t[1]]),
       best = [for (t = ok) if (t[0]*t[1] == area) t])                 // the fewest units; the longer if tied
  assert(ok != [], str("FireBeetle ", f[0], ": no carrier near ", nx0, " x ", ny0, " clears the holes"))
  best[len(best) - 1];
//-- X of the wall's inner face in the carrier frame: the plate's -X edge (-35)
function fbCarrierWallX(v = "ESP32-E", wall = fbCarrierWall, postShift = fbPostShift) =
  -crSize(fbCarrierSize(v, wall, postShift)[0], 1)[0]/2;
//-- Y of the socket's axis: the board is centred on the plate, the socket 0.02 off its centre line
function fbCarrierUsbY(v = "ESP32-E") = fbShift(v);
//-- where this part's frame (wall face, socket axis, floor top) sits in the carrier frame
function fbCarrierAt(v = "ESP32-E", wall = fbCarrierWall, postShift = fbPostShift) =
  [fbCarrierWallX(v, wall, postShift), fbCarrierUsbY(v), 0];
//-- the board's top above the plate (6.3), and the tallest thing on it (the battery socket, 11.3)
function fbCarrierTop(v = "ESP32-E", postH = fbPostH) = postH + fbPcb(v);
function fbCarrierHeight(v = "ESP32-E", postH = fbPostH) =
  fbCarrierTop(v, postH) + (fbVariant(v)[15] > 0 ? fbCarrierBatteryH : fbShellH(v));
//-- how deep the pilot hole goes from a post's top: the screw past the board, plus run-out
function fbCarrierPilot(v = "ESP32-E", screwLen = fbCarrierScrewLen) = screwLen - fbPcb(v) + fbCarrierRunout;
//-- plastic between a USB-end pilot hole and the wall face. Negative: the hole is open to it
function fbCarrierUsbSkin(v = "ESP32-E", wall = fbCarrierWall, postShift = fbPostShift) =
  fbHoles(v, wall, postShift, "usb")[0][0] - (screwSize(fbScrew(v))[6] + fbTapClear)/2;

//-- The carrier with its holder, as plastic. usbPosts: "tap" (all four posts take a screw) or
//-- "rest" (the USB pair are plain pedestals). open: the plate is pocketed except under the
//-- posts; lip: the wall lip
module fbCarrier(v = "ESP32-E", wall = fbCarrierWall, postH = fbPostH, screwLen = fbCarrierScrewLen,
                 usbPosts = "rest", postShift = fbPostShift, lip = true, open = true)
{
  s   = fbCarrierSize(v, wall, postShift); nx = s[0]; ny = s[1];
  sz  = crSize(nx, ny); L = sz[0]; W = sz[1];
  pd  = screwPostDia(fbScrew(v));
  tap = screwSize(fbScrew(v))[6] + fbTapClear;
  pilot = fbCarrierPilot(v, screwLen);
  usb = fbCarrierPosts(v, wall, postShift, nx, "usb");
  far = fbCarrierPosts(v, wall, postShift, nx, "far");
  tapped = usbPosts == "tap" ? concat(usb, far) : far;
  hd  = screwHeadDia(crScrew) + 2*fbCarrierHeadGap;
  assert(usbPosts == "tap" || usbPosts == "rest", str("fbCarrier: usbPosts is tap or rest, not ", usbPosts));
  assert(postH + crPlate - fbCarrierSkin >= pilot,
         str("an M", fbScrew(v), " x ", screwLen, " needs ", pilot, " of pilot hole: ", postH, " posts on a ",
             crPlate, " plate give ", postH + crPlate - fbCarrierSkin, ". Shorter screw, or posts of ",
             pilot - crPlate + fbCarrierSkin));
  assert(!lip || fbCarrierLipH < postH, "the wall lip would stand into the board");
  difference()
  {
    union()
    {
      //-- the plate, opened to carrier.scad's frame except a pad round each post
      difference()
      {
        carrierPlate(nx, ny, open = false);
        if (open) difference()
        {
          carrierOpening(nx, ny);
          for (p = concat(usb, far))
            translate([p[0], p[1], -crPlate - 2]) cylinder(d = pd + 2*fbCarrierPad, h = crPlate + 4, $fn = 40);
        }
      }
      //-- the posts and the lip, cut off flush at the plate's edges, notched where a carrier
      //-- screw head (Ø4.4 on the plate) would touch a post: the USB pair are 4.35 from the
      //-- corner holes
      difference()
      {
        intersection()
        {
          union()
          {
            for (p = tapped) translate([p[0], p[1], 0]) screwPost(fbScrew(v), postH, "tap");
            if (usbPosts == "rest")
              for (p = usb) translate([p[0], p[1], -0.01]) cylinder(d = pd, h = postH + 0.01, $fn = 40);
            if (lip) translate([-L/2, -W/2, -0.01]) cube([fbCarrierLip, W, fbCarrierLipH + 0.01]);
          }
          translate([-L/2, -W/2, -1]) cube([L, W, postH + 2]);
        }
        for (q = crHoles(nx, ny))
          translate([q[0], q[1], -1]) cylinder(d = hd, h = 1 + screwHeadH(crScrew) + fbCarrierHeadGap, $fn = 32);
      }
    }
    //-- the pilot holes run on below the posts' own blind holes (which start 0.6 up), into the plate
    for (p = tapped) if (postH - pilot < 0.6)
      translate([p[0], p[1], postH - pilot]) cylinder(d = tap, h = 1.0 - (postH - pilot), $fn = 24);
  }
}

//-- the board seated on the carrier, its screws, and the carrier's own screws, for previews.
//-- how: the carrier's fixing (carrier.scad's "tap" | "nut" | "bench"), for the screw ghosts
module fbCarrierGhost(v = "ESP32-E", wall = fbCarrierWall, postH = fbPostH, screwLen = fbCarrierScrewLen,
                      usbPosts = "tap", postShift = fbPostShift, how = crHow)
{
  s = fbCarrierSize(v, wall, postShift);
  translate(fbCarrierAt(v, wall, postShift))
    fbGhost(v, wall, 2.0, postH, "tap", postShift, usbPosts == "tap" ? "all" : "far", screwLen);
  carrierScrewGhost(s[0], s[1], how);
}
