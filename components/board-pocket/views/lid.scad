// A strip of lid with its pad, pressing foam onto the board's end, for the catalogue.
include <../board-pocket.scad>

l = 22.52; w = 18; pcb = 1.0;
lidZ = 10;      // lid's inner face above the floor
lidT = 2.0;
top  = boardPocketZ() + pcb;
translate([-l/2 - 1, -w/2 - 4, lidZ]) cube([9, w + 8, lidT]);   // a strip of lid over the pad
boardLidPad([5, w - 6], [-l/2 + 3.5, 0], top, lidZ);
