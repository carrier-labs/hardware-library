// The module's carrier, for the catalogue: a 5 x 3 plate with the pedestal, the end walls
// and their lead gaps, and two snap hooks over each long edge on their flex-relief tongues.
// Also the plastic for the collision check. Set variant for another module in the table.
use <../rs485-max485.scad>

variant = "jzk";
tab     = false;

rs485Carrier(variant, tab);
