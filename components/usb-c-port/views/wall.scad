// One pocket in a piece of wall and floor, for the catalogue.
use <../usb-c-port.scad>

wall = 2.4; overhang = 1.47; boardW = 25.4; pcb = 1.6; axisZ = 5;
difference()
{
  union()
  {
    translate([-wall, -17, -2]) cube([wall + 12, 34, 2.01]);
    translate([-wall, -17, 0]) cube([wall, 34, axisZ + 6]);
  }
  usbcWallCut(axisZ, wall, overhang, boardW, pcb);
}
