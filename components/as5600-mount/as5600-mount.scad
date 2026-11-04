//-----------------------------------------------------------------------
// AS5600 magnetic encoder board, held under a magnet on a spindle tip
//
// The board lies component side up, the AS5600 facing the magnet above it.
// Four screw posts take its weight: stainless M2.5 screws come UP from below,
// heads in counterbores in the floor's underside, with a stainless washer
// and nut on top of the board (stainless: carbon steel near the magnet
// bends its field). Four corner lips round the board's outline locate it:
// the holes are oversize and not placed well enough to hold the magnet
// axis within 0.25 of the IC, so they only clamp. Round boards get three
// arc lips instead of corners.
//
// The post height comes from the magnet: as56PostH(magnetFaceZ) puts the
// IC's top `gap` below the magnet's face.
//
// Modules, all in the same frame:
//   as56Ghost()      the board, IC and magnet, for previews
//   as56Holder()     the plastic: four posts and the locating lips
//   as56FloorCut()   subtract from the floor: counterbores and holes (and
//                    a slot for header pins pointing down, if asked)
//
// Frame: origin on the floor top, on the magnet axis (the IC's centre).
// Z up; the floor is Z = -floorThick .. 0. Board edges along X and Y.
// Units: mm.
//
// Boards come from as56Boards by name, or pass a row of your own in the
// same layout. Magnets come from as56Magnets by name, or pass a thickness.
//-----------------------------------------------------------------------

use <../screw-post/screw-post.scad>

//-- Boards: [name, shape, size, pcb, holes, hole Ø, screw, source]
//-- shape "rect": size [x, y]; "round": size [Ø]. Holes [x, y] from the IC's centre,
//-- which is the magnet axis; hole Ø one per hole (ghost only: the lips locate).
as56Boards = [
  //-- DollaTek B0BGPF3WT3 / JYUDAUFU B0DJ77DS4J, measured 2026-10-21 (the controller project's parts sheet).
  //-- 3 x Ø3.5 + 1 x Ø4.0 (by DIR); hole edges 1.75 in, so centres 3.5 in, 16.0 pitch; IC centred
  ["as5600-23",  "rect", [23, 23],   1.6, [[-8, -8], [8, -8], [-8, 8], [8, 8]], [3.5, 3.5, 3.5, 4.0], "M2.5", "measured"],
  //-- small breakout, 20 x 13.5, 2 x M3 holes on 15 pitch (vendor listing). CAL: PCB, hole Ø, IC centred
  ["as5600-20",  "rect", [20, 13.5], 1.6, [[-7.5, 0], [7.5, 0]],                [3.2, 3.2],           "M2.5", "V, CAL"],
  //-- round board: placeholder only, no source found. CAL: everything
  ["round-cal",  "round", [20],      1.6, [[-7, 0], [7, 0]],                    [3.2, 3.2],           "M2.5", "CAL"],
];

//-- Magnets: [name, Ø, thickness], diametrically magnetised discs
as56Magnets = [
  ["6x2.5", 6, 2.5],    // the size usually bundled with AS5600 boards. CAL what's in the packs
  ["6x1",   6, 1.0],    // the BOM's separate discs; the controller project's base default. CAL
];

//-- The sensor (AS5600 datasheet)
as56IcL        = 4.9;     // SOIC-8 body
as56IcW        = 3.9;
as56IcH        = 1.75;    // max, PCB to package top
as56Gap        = 1.5;     // magnet face to package top: datasheet 0.5..3; 1.5 mid-range
as56AxisTol    = 0.25;    // magnet axis to IC centre, max (datasheet)

//-- The mount
as56Clearance  = 0.15;    // CAL: per side, board outline to lips. Set by the fit piece
as56LipWall    = 1.6;
as56LipLeg     = 5;       // rect boards: lip length along each edge from a corner
as56LipArc     = 40;      // round boards: degrees per lip, three lips
as56LipH       = 1.0;     // lip top above the PCB underside (under the PCB top: nothing to snag)
as56FloorThick = 2.0;     // takes the M2.5 head counterbore (1.4 head + 0.2, 0.3 left)
as56WasherT    = 0.5;     // M2.5 washer, ISO 7089: Ø6 x 0.5
as56WasherD    = 6.0;
as56HeaderSlot = [17, 9]; // floor opening for header pins out the back: clears the rows at x -6.8 / +6.41

function as56Row(table, name) = let (i = search([name], table)[0])
  assert(i != [] && i != undef, str("unknown AS5600 name ", name)) table[i];
function as56Board(board) = is_string(board) ? as56Row(as56Boards, board) : board;
function as56MagnetT(magnet) = is_string(magnet) ? as56Row(as56Magnets, magnet)[2] : magnet;
function as56MagnetD(magnet) = is_string(magnet) ? as56Row(as56Magnets, magnet)[1] : 6;

//-- Magnet face Z for a magnet stuck on a spindle tip at tipZ (both above the floor top)
function as56MagnetFaceZ(tipZ, magnet = "6x1") = tipZ - as56MagnetT(magnet);
//-- Post height (floor top to PCB underside) that puts the IC's top `gap` under the magnet face
function as56PostH(magnetFaceZ, gap = as56Gap, board = "as5600-23") =
  magnetFaceZ - gap - as56IcH - as56Board(board)[3];
//-- Shortest screw (length under the head) from the head, flush in the floor's underside,
//-- up through the post, PCB, washer and nut. Round up to a length you have
function as56Screw(postH, floorThick = as56FloorThick, board = "as5600-23") =
  let (b = as56Board(board), s = b[6])
  floorThick - screwHeadH(s) + postH + b[3] + as56WasherT + screwNutH(s);
//-- Z of a screw's tip above the floor top: keep it clear of the magnet and spindle
function as56ScrewTipZ(length, floorThick = as56FloorThick, board = "as5600-23") =
  -floorThick + screwHeadH(as56Board(board)[6]) + length;

module as56Outline(board, grow = 0)
{
  b = as56Board(board);
  if (b[1] == "round") offset(r = grow, $fn = 64) circle(d = b[2][0], $fn = 64);
  else offset(delta = grow) square(b[2], center = true);
}

//-- where the lips go: corners of a rect board, three arcs round a round one
module as56LipZones(board, clearance)
{
  b = as56Board(board);
  R = 50;
  if (b[1] == "round")
    for (a = [90, 210, 330]) rotate(a - as56LipArc/2)
      polygon([[0, 0], [R, 0], for (t = [0 : 5 : as56LipArc]) R*[cos(t), sin(t)], R*[cos(as56LipArc), sin(as56LipArc)]]);
  else
    for (sx = [-1, 1], sy = [-1, 1])
    {
      leg = min(as56LipLeg, min(b[2])/2 - 1);
      translate([sx*b[2][0]/2, sy*b[2][1]/2])
        mirror([sx < 0 ? 1 : 0, 0]) mirror([0, sy < 0 ? 1 : 0])
          translate([-leg, -leg]) square([leg + clearance + as56LipWall + 1, leg + clearance + as56LipWall + 1]);
    }
}

//-- postH: floor top to PCB underside (as56PostH). magnetFaceZ: for the ghost's magnet
module as56Ghost(postH, board = "as5600-23", magnet = "6x1", gap = as56Gap)
{
  b = as56Board(board);
  %color("Purple") difference()
  {
    translate([0, 0, postH]) linear_extrude(b[3]) as56Outline(board);
    for (i = [0 : len(b[4]) - 1]) translate([b[4][i][0], b[4][i][1], postH - 1]) cylinder(d = b[5][i], h = b[3] + 2, $fn = 20);
  }
  %color("Black") translate([-as56IcL/2, -as56IcW/2, postH + b[3]]) cube([as56IcL, as56IcW, as56IcH]);
  %color("Silver") translate([0, 0, postH + b[3] + as56IcH + gap]) cylinder(d = as56MagnetD(magnet), h = as56MagnetT(magnet), $fn = 32);
}

module as56Holder(postH, board = "as5600-23", clearance = as56Clearance, lipH = as56LipH)
{
  b = as56Board(board);
  for (h = b[4]) translate([h[0], h[1], 0]) screwPost(b[6], postH, "head");
  //-- lips, sunk 0.01 into the floor so they don't come out as loose bodies
  translate([0, 0, -0.01]) linear_extrude(postH + lipH + 0.01)
    intersection()
    {
      difference() { as56Outline(board, clearance + as56LipWall); as56Outline(board, clearance); }
      as56LipZones(board, clearance);
    }
}

//-- headers: also cut a slot for header pins pointing down out of the board's back
module as56FloorCut(floorThick = as56FloorThick, board = "as5600-23", headers = false)
{
  b = as56Board(board);
  for (h = b[4]) translate([h[0], h[1], 0]) screwPostFloorCut(b[6], floorThick, "head");
  for (h = b[4]) assert(!headers || abs(h[0]) - screwPostDia(b[6])/2 >= as56HeaderSlot[0]/2
                         || abs(h[1]) - screwPostDia(b[6])/2 >= as56HeaderSlot[1]/2, "header slot runs into a post");
  if (headers) translate([-as56HeaderSlot[0]/2, -as56HeaderSlot[1]/2, -floorThick - 1])
    cube([as56HeaderSlot[0], as56HeaderSlot[1], floorThick + 2]);
}
