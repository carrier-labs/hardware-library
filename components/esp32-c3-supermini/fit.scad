//-----------------------------------------------------------------------
// Fit piece: four C3 Super Mini holders on one strip of wall, marked 1 to 4
// dots behind each. The stations vary how thick the foam tape ends up once
// the board is pressed onto it, which sets the socket's height in its wall
// pocket, and the outline clearance.
//
//   1  tape 0.7,  clearance 0.4
//   2  tape 0.85, clearance 0.4
//   3  tape 1.0,  clearance 0.4   (the design value)
//   4  tape 1.0,  clearance 0.3   (PLA)
//
// Stick a pad of the tape on each pedestal (leave the liner on to try them
// all with one board). Tip the board nose-down, put the socket into the
// wall, lay its end down and press. Is the socket centred top to bottom in
// its pocket, face flush outside? Does the board sit flat? Plug a cable in
// and pull it out: does the board stay put?
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <esp32-c3-supermini.scad>
use <../board-pocket/board-pocket.scad>
use <../../util/marks.scad>

wall      = 2.4;      // the project's wall: test at the thickness you'll use
baseThick = 1.2;
pitch     = 26;
pcb       = 1.0;      // CAL: set to the board you'll test with
stations  = [ [0.7, 0.4], [0.85, 0.4], [1.0, 0.4], [1.0, 0.3] ];   // [tape, clearance]

n      = len(stations);
depth  = 30;          // floor behind the wall's inner face
wallH  = c3MiniAxisZ(pcb, tape = 1.2) + 4;

difference()
{
  union()
  {
    translate([-wall, -pitch/2, -baseThick]) cube([wall + depth, n*pitch, baseThick + 0.01]);
    translate([-wall, -pitch/2, 0]) cube([wall, n*pitch, wallH]);
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0]) c3MiniHolder(wall, pcb = pcb, tape = stations[i][0], clearance = stations[i][1]);
  }
  for (i = [0 : n - 1])
  {
    translate([0, i*pitch, 0]) c3MiniWallCut(wall, pcb = pcb, tape = stations[i][0]);
    translate([depth - 2.5, i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1]) translate([0, i*pitch, 0]) c3MiniGhost(wall, pcb = pcb, tape = stations[i][0]);
