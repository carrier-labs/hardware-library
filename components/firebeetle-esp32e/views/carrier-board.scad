// The board as a solid, seated on its carrier, for the catalogue (board.scad's solid moved
// into the carrier frame). The moving part of the "On a carrier" view, and the body for the
// collision check against carrier.scad.
use <../firebeetle-esp32e.scad>
use <board.scad>

variant = "ESP32-E";
wall    = 2.4;
postH   = 4.7;

translate(fbCarrierAt(variant, wall)) fbSolid(variant, wall, postH, 0);
