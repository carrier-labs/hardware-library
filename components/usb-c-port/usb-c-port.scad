//-----------------------------------------------------------------------
// USB-C port through a wall, flush: the socket's metal shell sits in a
// close-fitting pocket in the wall, walled in on all four sides, its face
// level with the outside. The cable seats the way it does on a laptop.
//
// A board's socket only overhangs the board edge by a mm or so, less than
// the wall. So the board's end tucks into a shallow relief in the wall's
// inner face, the width of the board, leaving the wall round the socket
// thin enough for the face to reach the outside. When that would leave less
// than usbcMinWall (a socket that barely overhangs), the face sits back from
// the outside instead: usbcRecess() says how far.
//
// Modules, all in the same frame:
//   usbcGhost()     the socket and the board's end, for previews
//   usbcWallCut()   subtract from the wall: socket pocket and board relief
//
// Frame: origin on the floor top at the wall's inner face, under the socket's
// axis. +X into the box, Z up. The wall is X = -wall .. 0. The board is
// component side up, socket on top (top-mount, as on the FireBeetle, C3 Super
// Mini and S3 DevKitC). Units: mm.
//
// usbcBoardEdgeX() gives where the board's edge lands (negative: inside the
// wall), so a holder can put its posts or pocket to match.
//-----------------------------------------------------------------------

//-- The socket: USB-C receptacle shell (USB-IF 8.34 x 2.56 plug, receptacle shell ~8.94 x 3.26)
usbcShellW     = 8.94;
usbcShellH     = 3.26;    // CAL per board: measured 3.2 on the FireBeetle
usbcShellR     = 1.2;     // CAL: end radius. Full round would be 1.63; most shells are squarer
usbcShellDepth = 7.35;    // face to back

//-- The pocket
usbcClearance  = 0.15;    // CAL: per side, shell to pocket. Set by the fit piece
usbcMinWall    = 1.0;     // thinnest wall left round the socket
usbcReliefGap  = 0.3;     // board relief over the board, each side and above/below
usbcChamfer    = 0.3;     // lead-in on the outside edge

//-- How far the socket face sits back from the outside: 0 (flush) unless the socket
//-- overhangs the board edge by less than usbcMinWall
function usbcRecess(overhang, minWall = usbcMinWall) = max(0, minWall - overhang);
//-- X of the board's socket edge in this frame
function usbcBoardEdgeX(wall, overhang, recess) =
  -wall + (is_undef(recess) ? usbcRecess(overhang) : recess) + overhang;
//-- Z of the board's underside above the floor top
function usbcBoardZ(axisZ, pcb, shellH = usbcShellH) = axisZ - shellH/2 - pcb;

module usbcShell2D(grow = 0, w = usbcShellW, h = usbcShellH, r = usbcShellR)
{
  offset(r = r + grow, $fn = 24) square([w - 2*r, h - 2*r], center = true);
}

//-- axisZ: socket axis above the floor. boardW/pcb: the board, for the ghost and relief.
//-- shift: socket centre across the board's width from the board's centre line (+Y)
module usbcGhost(axisZ, wall, overhang, boardW, pcb = 1.6, recess, shift = 0, shellH = usbcShellH, shellW = usbcShellW)
{
  ex = usbcBoardEdgeX(wall, overhang, recess);
  %color("Silver") translate([ex - overhang, 0, axisZ]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(usbcShellDepth) usbcShell2D(w = shellW, h = shellH);
  %color("DarkSlateGray") translate([ex, -boardW/2 - shift, usbcBoardZ(axisZ, pcb, shellH)]) cube([12, boardW, pcb]);
}

module usbcWallCut(axisZ, wall, overhang, boardW, pcb = 1.6, recess, shift = 0,
                   clearance = usbcClearance, shellH = usbcShellH, shellW = usbcShellW, aboveBoard)
{
  rc = is_undef(recess) ? usbcRecess(overhang) : recess;
  ex = usbcBoardEdgeX(wall, overhang, rc);
  bz = usbcBoardZ(axisZ, pcb, shellH);
  //-- what stands on the board near its edge: the socket, unless told taller
  up = is_undef(aboveBoard) ? shellH : aboveBoard;
  assert(ex - overhang + wall >= -0.01, "socket face would stand proud of the wall");
  assert(rc > 0 || overhang >= usbcMinWall - 0.01, "wall round the socket under usbcMinWall");
  //-- socket pocket, through the wall
  translate([-wall - 1, 0, axisZ]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(wall + 2) usbcShell2D(clearance, w = shellW, h = shellH);
  //-- lead-in chamfer on the outside
  translate([-wall, 0, axisZ]) rotate([0, 90, 0]) rotate([0, 0, 90])
    hull()
    {
      translate([0, 0, -0.01]) linear_extrude(0.01) usbcShell2D(clearance + usbcChamfer, w = shellW, h = shellH);
      translate([0, 0, usbcChamfer]) linear_extrude(0.01) usbcShell2D(clearance, w = shellW, h = shellH);
    }
  //-- board relief in the inner face, when the board's edge lands inside the wall
  if (ex < 0)
    translate([ex - usbcReliefGap, -boardW/2 - shift - usbcReliefGap, bz - usbcReliefGap])
      cube([-ex + usbcReliefGap + 1, boardW + 2*usbcReliefGap, pcb + up + 2*usbcReliefGap]);
}
