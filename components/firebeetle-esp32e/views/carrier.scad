// The board's carrier, for the catalogue: a 7 x 3 plate with the four tap posts and the wall
// lip across the USB end (-X), opened except under the posts. Also the plastic for the
// collision check. Set variant for another board in the table; wall for the box wall it meets.
use <../firebeetle-esp32e.scad>

variant  = "ESP32-E";
wall     = 2.4;
usbPosts = "rest";

fbCarrier(variant, wall, usbPosts = usbPosts);
