// One mount on a piece of floor, at the controller project's base's height: spindle tip 11 above
// the floor top, 6 x 1 magnet, 1.5 gap → posts 5.15. For the catalogue.
use <../as5600-mount.scad>

board = "as5600-23"; tipZ = 11; magnet = "6x1"; floorThick = 2.0;
postH = as56PostH(as56MagnetFaceZ(tipZ, magnet), board = board);
difference()
{
  union()
  {
    translate([-17, -17, -floorThick]) cube([34, 34, floorThick]);
    as56Holder(postH, board);
  }
  as56FloorCut(floorThick, board, headers = true);
}
