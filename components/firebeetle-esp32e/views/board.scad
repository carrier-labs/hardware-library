// The board as a solid, for the catalogue (the Ghost is % so it never renders):
// PCB, USB-C socket, charge LED, RGB LED, side buttons, battery socket.
// One board per entry in shifts, at the fit piece's pitch.
include <../firebeetle-esp32e.scad>

variant = "ESP32-E";
wall    = 2.4;
postH   = 4.7;
shifts  = [0];      // postShift per board
pitch   = 32;

module fbSolid(v, wall, postH, postShift)
{
  f = fbVariant(v);
  L = fbLength(v); W = fbWidth(v); pcb = fbPcb(v);
  ex = fbEdgeX(v, wall, postShift);
  top = postH + pcb;
  difference()
  {
    translate([ex, -f[9], postH]) linear_extrude(pcb)
      offset(r = fbCornerR, $fn = 16) offset(delta = -fbCornerR) square([L, W]);
    for (h = fbHoles(v, wall, postShift))
      translate([h[0], h[1], postH - 1]) cylinder(d = 2.0, h = pcb + 2, $fn = 20);
  }
  translate([ex - fbOverhang(v), 0, fbAxisZ(v, postH)]) rotate([0, 90, 0]) rotate([0, 0, 90])
    linear_extrude(fbUsbDepth) usbcShell2D(h = fbShellH(v));
  led = fbToFrame(v, wall, f[12][0], f[12][1], postShift);
  translate([led[0] - 0.25, led[1] - 0.5, top - 0.01]) cube([0.5, 1.0, 0.41]);
  if (len(f[13]) == 2)
  {
    rgb = fbToFrame(v, wall, f[13][0], f[13][1], postShift);
    translate([rgb[0] - 1, rgb[1] - 1, top - 0.01]) cube([2, 2, 0.81]);
  }
  if (f[14] > 0)
    for (bx = [0, W])
    {
      b = fbToFrame(v, wall, bx, f[14], postShift);
      translate([b[0] - 1.5, b[1] - 1.5, top - 0.01]) cube([3, 3, 1.91]);
    }
  if (f[15] > 0)
  {
    b = fbToFrame(v, wall, W, f[15], postShift);
    translate([b[0] - 3, b[1] - 4.5, top - 0.01]) cube([6, 4.5, 5.01]);
  }
}

for (i = [0 : len(shifts) - 1]) translate([0, i*pitch, 0]) fbSolid(variant, wall, postH, shifts[i]);
