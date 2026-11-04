// The board (and its tape) as solids, for the catalogue. part = "board" | "tape" | "foam"
include <../board-pocket.scad>

l = 22.52; w = 18; pcb = 1.0; pad = [14, 10];
part = "board";
z = boardPocketZ();
if (part == "board") translate([-l/2, -w/2, z]) cube([l, w, pcb]);
if (part == "tape")  translate([-pad[0]/2, -pad[1]/2, bpPedestal + 0.01]) cube([pad[0], pad[1], bpTape - 0.02]);   // 0.01 clear of the pedestal and board
//-- the foam under the lid pad, squashed
if (part == "foam")  translate([-l/2 + 1, -w/2 + 3, z + pcb]) cube([5, w - 6, bpFoam - bpSqueeze - 0.01]);
