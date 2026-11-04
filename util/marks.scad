//-----------------------------------------------------------------------
// Marks for fit pieces: n dots in a row, engraved into a face, so each
// variant can be told apart after printing. Origin: centre of the row, on
// the face; the dots cut down into -Z. Units: mm.
//-----------------------------------------------------------------------

markDotDia   = 1.6;
markDotPitch = 2.6;
markDotDepth = 0.6;

module markDots(n)
{
  for (i = [0 : n - 1])
    translate([(i - (n - 1)/2)*markDotPitch, 0, -markDotDepth])
      cylinder(d = markDotDia, h = markDotDepth + 1, $fn = 16);
}
