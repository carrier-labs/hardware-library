//-----------------------------------------------------------------------
// RJ45 breakout board through a wall, jack face flush with the outside
//
// The board sits on two M2.5 screw posts (nuts trapped in the floor's
// underside, screws in from the top) with its jack end at the wall. The
// jack's body sits in a close pocket through the wall, walled in all round,
// its face level with the outside. The plug's latch then comes out of the
// jack's own face, so it's clear to press whichever side it is on.
//
// Most horizontal breakouts' jacks overhang the board edge by about as much
// as a wall is thick. If the wall is thicker than the overhang, the board's
// end tucks into a shallow relief in the wall's inner face, as for the USB-C
// port. If the wall is thinner, the board edge just stops short of it.
// A recessed face (recess > 0) also opens the outside on the latch side, so
// a thumb can still reach the latch.
//
// Modules, all in the same frame:
//   rj45Ghost()      the board and its jack, for previews
//   rj45Holder()     the plastic inside the box: the two screw posts
//   rj45FloorCut()   subtract from the floor: the nut traps and holes
//   rj45WallCut()    subtract from the wall: jack pocket, and board relief if needed
//
// Frame: origin on the floor top at the wall's inner face, on the jack's
// centre line (Y). +X into the box, Z up. The wall is X = -wall .. 0, the
// floor Z = -floorThick .. 0. The board is component side up, jack end
// toward -X. Units: mm.
//
// Boards come from rj45Boards by name (the jack they carry from rj45Jacks),
// or pass a row of your own in the same layout for a board not in the table.
// rj45BoardEdgeX() says where the board's jack edge lands, rj45AxisZ() the
// jack's centre height, rj45Screw() which M2.5 length reaches the nut.
//-----------------------------------------------------------------------

use <../screw-post/screw-post.scad>

//-- Jack bodies: [name, width, bottom, top, overhang, depth, source]
//-- bottom/top: Z of the body's underside/top above the PCB underside (a mid-mount
//-- jack drops through a cutout in the board, so its bottom is negative).
//-- overhang: face past the board's edge. depth: face to back of the body.
rj45Jacks = [
  //-- Pi Hut 106592: measured from The Pi Hut's STEP (the controller project's parts sheet, 2026-10-20). Depth CAL
  ["pihut-106592", 16.0, -1.15, 10.35, 2.28, 21.0, "S"],
  //-- shielded through-hole right-angle 8P8C sitting on the board (e.g. HanRun HR911105A MagJack,
  //-- 16 x 13.5 x 21.3 body as usually quoted). CAL: all, including overhang
  ["shielded",     16.0,  1.6, 15.1, 2.0, 21.3, "CAL"],
  //-- unshielded through-hole right-angle 8P8C on the board, plastic body. CAL: all
  ["unshielded",   15.9,  1.6, 14.6, 1.0, 18.3, "CAL"],
];

//-- Boards: [name, length, width, pcb, holes, hole Ø, jack, jack offset, screw]
//-- length: header edge to jack edge; holes [x, y] from the header-edge corner,
//-- x toward the jack, y across. jack offset: jack centre from the board's
//-- centre line, +y. Pi Hut 106592 from The Pi Hut's STEP (the controller project's parts sheet).
rj45Boards = [
  ["pihut-106592", 23.98, 29.90, 1.6, [[7.39, 2.52], [7.39, 27.44]], 2.75, "pihut-106592", 0, "M2.5"],
];

//-- Mounting (from the controller project's receiver and rack-end: M2.5 x 8 into a nut trap)
rj45PostH       = 4.2;     // floor top to PCB underside: M2.5 x 8 ends 0.2 inside the nut trap
rj45FloorThick  = 2.4;     // takes an M2.5 nut trap (2.0 nut + 0.4)

//-- The pocket
rj45Clearance   = 0.3;     // CAL: per side, jack body to pocket. 0.3 in the controller project's boxes; set by the fit piece
rj45PocketR     = 0.5;     // pocket corner radius (capped so it clears the body's square corners)
rj45Chamfer     = 0.3;     // lead-in on the outside edge
rj45MinWall     = 1.0;     // thinnest wall left beside the jack where the board relief cuts in
rj45ReliefGap   = 0.3;     // board relief over the board, each side and above/below
rj45AboveBoard  = 0.5;     // CAL: what stands on the board within the relief, beside the jack
rj45LatchRoom   = 3.0;     // recessed face only: extra opening on the latch side for a thumb
rj45Latch       = "down";  // CAL: latch side, "down" (toward the board) or "up"

function rj45Row(table, name) = let (i = search([name], table)[0])
  assert(i != [] && i != undef, str("unknown RJ45 name ", name)) table[i];
//-- a name from the table, or a row of your own in the same layout
function rj45Board(board) = is_string(board) ? rj45Row(rj45Boards, board) : board;
function rj45Jack(jack)   = is_string(jack)  ? rj45Row(rj45Jacks, jack)   : jack;
function rj45JackOf(board) = rj45Jack(rj45Board(board)[6]);

//-- How far the jack face sits back from the outside: 0 (flush) unless a relief would leave
//-- less than rj45MinWall beside the jack
function rj45Recess(wall, overhang, minWall = rj45MinWall) =
  wall > overhang ? max(0, minWall + rj45ReliefGap - overhang) : 0;
//-- X of the board's jack edge in this frame (negative: inside the wall)
function rj45BoardEdgeX(wall, board = "pihut-106592", recess) =
  let (o = rj45JackOf(board)[4]) -wall + (is_undef(recess) ? rj45Recess(wall, o) : recess) + o;
//-- Z of the jack's centre above the floor top
function rj45AxisZ(postH = rj45PostH, board = "pihut-106592") =
  let (j = rj45JackOf(board)) postH + (j[2] + j[3])/2;
//-- [x, y] of the board's holes in this frame
function rj45HolesXY(wall, board = "pihut-106592", recess) =
  let (b = rj45Board(board), ex = rj45BoardEdgeX(wall, board, recess))
  [ for (h = b[4]) [ex + b[1] - h[0], h[1] - b[2]/2 - b[7]] ];
//-- Shortest screw from the top: down through the PCB and post to the nut trap's underside
function rj45Screw(postH = rj45PostH, floorThick = rj45FloorThick, board = "pihut-106592") =
  screwPostScrew(rj45Board(board)[8], postH, floorThick, rj45Board(board)[3]);

//-- Jack body outline in the wall plane (Y across, Z up), about the jack's centre
module rj45Jack2D(grow = 0, board = "pihut-106592")
{
  j = rj45JackOf(board);
  r = min(rj45PocketR, 3*grow);
  if (r > 0) offset(r = r, $fn = 24) square([j[1] + 2*(grow - r), j[3] - j[2] + 2*(grow - r)], center = true);
  else       square([j[1] + 2*grow, j[3] - j[2] + 2*grow], center = true);
}

module rj45Ghost(wall, postH = rj45PostH, board = "pihut-106592", recess)
{
  b  = rj45Board(board);
  j  = rj45JackOf(board);
  ex = rj45BoardEdgeX(wall, board, recess);
  %color("DarkBlue") difference()
  {
    translate([ex, -b[2]/2 - b[7], postH]) cube([b[1], b[2], b[3]]);
    for (h = rj45HolesXY(wall, board, recess)) translate([h[0], h[1], postH - 1]) cylinder(d = b[5], h = b[3] + 2, $fn = 20);
  }
  %color("Silver") translate([ex - j[4], -j[1]/2, postH + j[2]]) cube([j[5], j[1], j[3] - j[2]]);
}

//-- how: "nut" (screw from the top into a trapped nut) or "tap"
module rj45Holder(wall, postH = rj45PostH, board = "pihut-106592", recess, how = "nut")
{
  for (h = rj45HolesXY(wall, board, recess))
    translate([h[0], h[1], 0]) screwPost(rj45Board(board)[8], postH, how);
}

module rj45FloorCut(wall, floorThick = rj45FloorThick, board = "pihut-106592", recess, how = "nut",
                    nutClear = 0.3)
{
  for (h = rj45HolesXY(wall, board, recess))
    translate([h[0], h[1], 0]) screwPostFloorCut(rj45Board(board)[8], floorThick, how, nutClear);
}

module rj45WallCut(wall, postH = rj45PostH, board = "pihut-106592", recess,
                   clearance = rj45Clearance, latch = rj45Latch, aboveBoard = rj45AboveBoard)
{
  b  = rj45Board(board);
  j  = rj45JackOf(board);
  rc = is_undef(recess) ? rj45Recess(wall, j[4]) : recess;
  ex = rj45BoardEdgeX(wall, board, rc);
  az = rj45AxisZ(postH, board);
  jh = j[3] - j[2];
  assert(ex - j[4] + wall >= -0.01, "jack face would stand proud of the wall");
  assert(ex >= 0 || rc + j[4] - rj45ReliefGap >= rj45MinWall - 0.01, "wall beside the jack under rj45MinWall");
  assert(postH + j[2] - clearance >= 0.6, "jack pocket runs into the floor: raise postH");
  //-- jack pocket, through the wall
  translate([-wall - 1, 0, az]) rotate([90, 0, 90]) linear_extrude(wall + 2) rj45Jack2D(clearance, board);
  //-- lead-in chamfer on the outside
  translate([-wall - 0.01, 0, az]) rotate([90, 0, 90])
    hull()
    {
      linear_extrude(0.01) rj45Jack2D(clearance + rj45Chamfer, board);
      translate([0, 0, rj45Chamfer]) linear_extrude(0.01) rj45Jack2D(clearance, board);
    }
  //-- recessed face: open the outside on the latch side so a thumb reaches the latch
  if (rc > 0)
    translate([-wall - 1, -j[1]/2 - clearance, latch == "up" ? az : az - jh/2 - clearance - rj45LatchRoom])
      cube([rc + 1, j[1] + 2*clearance, jh/2 + clearance + rj45LatchRoom]);
  //-- board relief in the inner face, when the board's edge lands inside the wall
  if (ex < 0)
    translate([ex - rj45ReliefGap, -b[2]/2 - b[7] - rj45ReliefGap, postH - rj45ReliefGap])
      cube([-ex + rj45ReliefGap + 1, b[2] + 2*rj45ReliefGap, b[3] + aboveBoard + 2*rj45ReliefGap]);
}
