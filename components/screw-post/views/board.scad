// A strip of 1.6 board clamped on the posts, for the catalogue.
h = 5; clamp = 1.6;
difference()
{
  translate([-4, -5, h]) cube([20, 10, clamp]);
  for (x = [0, 12]) translate([x, 0, h - 1]) cylinder(d = 2.9, h = clamp + 2, $fn = 24);
}
