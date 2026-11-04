// The board's mount on a piece of wall and floor, for the catalogue: all four posts,
// the USB pocket, relief, light hole and screw-head channels.
use <../firebeetle-esp32e.scad>

variant    = "ESP32-E";
wall       = 2.4;
floorThick = 2.0;
postH      = 4.7;
wallH      = fbAxisZ(variant, postH) + 6;
halfW      = 19;

union()
{
  difference()
  {
    union()
    {
      translate([-wall, -halfW, -floorThick]) cube([wall + 64, 2*halfW, floorThick + 0.01]);
      translate([-wall, -halfW, 0]) cube([wall, 2*halfW, wallH]);
    }
    fbWallCut(variant, wall, postH, channelTop = wallH + 1);
    fbFloorCut(variant, wall, floorThick, postH);
  }
  fbHolder(variant, wall, postH);
}
