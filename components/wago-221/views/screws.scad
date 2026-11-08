// The carrier's M2.5 x 6 screws as solids, for the catalogue (the Ghost is % so it never
// renders): heads on the plate's top at its four corners, beside the clip's stops.
use <../wago-221.scad>
use <../../carrier/carrier.scad>

name = "221-415";
s = wagoCarrierSize(name);

carrierScrews(s[0], s[1]);
