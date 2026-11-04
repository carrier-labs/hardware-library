//-----------------------------------------------------------------------
// Fit piece: the USB end of four S3 holders on one strip of wall, marked 1
// to 4 dots behind each. A full holder is 60 long, so each station is only
// the first 18 of it: the wall with both ports, the start of the pocket and
// of the pedestal. Hold the board's far end level while you test.
//
//   1  open port's face 0.62 back from the outside (closed port's skin 0.47), tape 1.0
//   2  face 0.8 back  (skin 0.65), tape 1.0
//   3  face 1.0 back  (skin 0.85), tape 1.0
//   4  face 0.62 back (skin 0.47), tape 0.7
//
// Set up for the YD-ESP32-S3 clone, right-hand port open (seen from outside).
// Tip the board nose-down, put the socket into the wall, lay it level onto
// the tape (liner on). Does the open socket sit centred, its face where you
// expect? Plug a cable in: does it seat fully and click (1-3: how far back
// can the face sit)? Is the skin over the other port whole, and stiff
// enough? Does the closed port clear its blind pocket?
// Prints base down, as exported, no supports. Units: mm.
//-----------------------------------------------------------------------

use <esp32-s3-devkitc.scad>
use <../../util/marks.scad>

wall      = 2.4;      // the project's wall: test at the thickness you'll use
baseThick = 1.2;
pitch     = 36;
depth     = 18;       // how much of the holder each station has
stations  = [ [0.62, 1.0], [0.8, 1.0], [1.0, 1.0], [0.62, 0.7] ];   // [recess, tape]

n     = len(stations);
ly    = s3DevkitLeftY();
cy    = ly - s3Devkit()[2]/2;          // board's centre line
wallH = s3DevkitAxisZ(tape = 1.0) + 4;

difference()
{
  union()
  {
    translate([-wall, cy - pitch/2, -baseThick]) cube([wall + depth + 6, n*pitch, baseThick + 0.01]);
    translate([-wall, cy - pitch/2, 0]) cube([wall, n*pitch, wallH]);
    for (i = [0 : n - 1])
      translate([0, i*pitch, 0])
        intersection()
        {
          s3DevkitHolder(wall, recess = stations[i][0], tape = stations[i][1]);
          translate([-1, -50, -1]) cube([depth + 1, 100, 20]);
        }
  }
  for (i = [0 : n - 1])
  {
    translate([0, i*pitch, 0]) s3DevkitWallCut(wall, recess = stations[i][0], tape = stations[i][1]);
    translate([depth + 3, cy + i*pitch, 0]) rotate([0, 0, 90]) markDots(i + 1);
  }
}

if ($preview)
  for (i = [0 : n - 1])
    translate([0, i*pitch, 0]) s3DevkitGhost(wall, recess = stations[i][0], tape = stations[i][1]);
