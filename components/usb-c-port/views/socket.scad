// The socket and the board's end as solids, for the catalogue.
include <../usb-c-port.scad>

wall = 2.4; overhang = 1.47; boardW = 25.4; pcb = 1.6; axisZ = 5;
ex = usbcBoardEdgeX(wall, overhang);
translate([ex - overhang, 0, axisZ]) rotate([0, 90, 0]) rotate([0, 0, 90]) linear_extrude(usbcShellDepth) usbcShell2D();
