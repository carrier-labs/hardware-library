include <../usb-c-port.scad>

wall = 2.4; overhang = 1.47; boardW = 25.4; pcb = 1.6; axisZ = 5;
ex = usbcBoardEdgeX(wall, overhang);
translate([ex, -boardW/2, usbcBoardZ(axisZ, pcb)]) cube([12, boardW, pcb]);
