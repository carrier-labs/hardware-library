//-----------------------------------------------------------------------
// Snap hook: a cantilever arm that hooks over the edge of a PCB
//
// For a board with no mounting holes. The board sits on a pedestal; two
// hooks on opposite edges stand just outside it. Push the board down: its
// edges ride the 45° lead-ins, the arms flex outward, and the hooks snap
// back over the board's top. The arm's foot stands on a tongue of floor cut
// free by a U-slot (the flex relief), so a short arm has enough spring in
// PETG. To release, pull the board or lever an arm back with a fingernail;
// tab = true gives it a lip to lever against.
//
// Modules and functions, all in the same frame:
//   snapHook()            the arm with its hook: add to the floor
//   snapHookFloorCut()    the flex relief slot: subtract from the floor
//   snapHookPair()        two hooks facing each other, span apart along X
//   snapHookPairFloorCut()
//   snapHookClear()       how far the hook stands past the board's edge
//   snapHookHeight()      the top of the arm above the floor
//   snapHookStrain()      estimated strain at the arm's root when the board goes in
//
// Frame: origin on the floor top, at the board's edge, under the hook's
// centre. The board is at -X; the arm stands at +X, outside it; Z up. The
// hook is `width` wide along Y. `top` is the board's top face above the
// floor (pedestal + PCB). Units: mm.
//
// The hook's underside is a 45° slope, so the whole profile prints base
// down without supports. It passes `gap` above the board's top edge and
// meets the arm `clearance - gap` below the board's top, beside it, so the
// hooks also centre the board sideways: it can shift `gap` toward a hook
// before the slope starts to lift it.
//
// Use with `use <.../components/snap-hook/snap-hook.scad>`. The snapHookPair
// frame is the board's: origin on the floor top under its centre.
//-----------------------------------------------------------------------

//-- The hook
shReach     = 0.7;     // CAL: how far the hook reaches back over the board's top. Set by the fit piece
shClearance = 0.3;     // CAL: arm's inner face to the board's edge (PETG). Set by the fit piece
shThick     = 1.6;     // arm thickness: the controller project's clips, PETG
shWidth     = 6;       // along the board's edge
shGap       = 0.15;    // hook's underside above the board's top edge
shLeadIn    = 1.4;     // height of the 45° lead-in above the hook's tip (the controller project's clips)

//-- The flex relief: a U-slot through the floor round the arm's foot, leaving it on a
//-- tongue rooted `relief` behind the arm. 0 = no slot (the arm is then rooted in the floor)
shRelief    = 4;       // tongue length behind the arm's outer face
shSlot      = 1.0;     // slot width, each side of the foot and in front of it
shMaxStrain = 0.04;    // PETG: a snap at this strain survives, higher cracks or takes a set (estimate)
shModulus   = 2000;    // MPa, printed PETG: for snapHookForce()

//-- The release tab (tab = true)
shTab       = 4;       // lever above the lead-in
shTabLip    = 1.0;     // lip outward at its top, for a fingernail; 45° underside
shTabLipH   = 0.8;

//-- the top of the arm above the floor (clear this under a lid)
function snapHookHeight(top, reach = shReach, clearance = shClearance, tab = false) =
  top + shGap + reach + max(shLeadIn, reach + clearance) + (tab ? shTab + shTabLipH : 0);

//-- how far the plastic stands past the board's edge: arm, and the tongue and slot behind it
function snapHookClear(top, reach = shReach, clearance = shClearance, thick = shThick, relief = shRelief) =
  clearance + thick + (relief > 0 ? relief + shSlot : 0);

//-- Estimated strain at the arm's root when the board goes in, as a fraction. Worst case:
//-- the board pushed against the other hook, so this one opens by reach + clearance.
//-- Cantilever: strain = 3 t d / (2 L²), L the arm from the floor to the hook. The tongue
//-- behind the arm bends under the same moment and adds 3 Lt / L to the compliance.
function snapHookStrain(top, reach = shReach, clearance = shClearance, thick = shThick, relief = shRelief) =
  let (L = top + shGap, d = reach + clearance, Lt = relief > 0 ? relief + thick/2 : 0)
  3*thick*d / (2*L*L) / (1 + 3*Lt/L);

//-- Estimated force (N) to hold the arm fully open, for the same case. Insertion is about
//-- this per hook (45° lead-in) plus friction
function snapHookForce(top, reach = shReach, clearance = shClearance, thick = shThick, width = shWidth, relief = shRelief) =
  let (L = top + shGap, d = reach + clearance, Lt = relief > 0 ? relief + thick/2 : 0,
       I = width*pow(thick, 3)/12)
  3*shModulus*I*d / pow(L, 3) / (1 + 3*Lt/L);

//-- the arm's profile in the X-Z plane: foot at Z = -0.01, hook toward -X
module snapHookProfile(top, reach, clearance, thick, tab)
{
  c = clearance; t = thick; r = reach; g = shGap;
  H0   = top + g - c;                       // hook's underside meets the arm's inner face
  tip  = [-r, top + g + r];                 // underside rises at 45° to the tip
  li   = max(shLeadIn, r + c);              // lead-in at 45° at least back to the arm's inner face
  xe   = -r + li;                           // where it ends, inside the arm
  zTop = tip[1] + li;
  zTab = zTop + shTab;
  assert(H0 > 0.4, str("hook too low: top ", top, " leaves the hook's inner corner at ", H0));
  assert(xe <= c + t, str("lead-in ", shLeadIn, " runs past the arm's outer face: a thicker arm, or reach ", r));
  polygon(tab
    ? [[c + t, -0.01], [c, -0.01], [c, H0], tip, [xe, zTop], [xe, zTab + shTabLipH],
       [c + t + shTabLip, zTab + shTabLipH], [c + t + shTabLip, zTab], [c + t, zTab - shTabLip]]
    : [[c + t, -0.01], [c, -0.01], [c, H0], tip, [xe, zTop], [c + t, zTop]]);
}

//-- top: the board's top face above the floor. relief: the tongue length behind the arm
//-- (0 = none), only drawn by snapHookFloorCut; here it sets the strain check
module snapHook(top, reach = shReach, clearance = shClearance, thick = shThick, width = shWidth,
                tab = false, relief = shRelief)
{
  s = snapHookStrain(top, reach, clearance, thick, relief);
  assert(s <= shMaxStrain,
         str("snap hook arm too short to flex: strain ", round(s*1000)/10, " % on a ", top + shGap,
             " arm. ", relief > 0 ? "Lengthen the relief, raise the board, or thin the arm"
                                  : "Add the flex relief (snapHookFloorCut), raise the board, or thin the arm"));
  translate([0, width/2, 0]) rotate([90, 0, 0]) linear_extrude(width)
    snapHookProfile(top, reach, clearance, thick, tab);
}

//-- The U-slot through the floor round the arm's foot: `shSlot` wide along both sides and in
//-- front of it (under the board's edge), `relief` long behind. floorThick: the floor it
//-- goes through (Z = -floorThick .. 0)
module snapHookFloorCut(top, reach = shReach, clearance = shClearance, thick = shThick, width = shWidth,
                        floorThick = 1.6, relief = shRelief)
{
  if (relief > 0)
  {
    c = clearance; s = shSlot;
    x0 = c - s; x1 = c + thick + relief;
    translate([0, 0, -floorThick - 1]) linear_extrude(floorThick + 1.01) difference()
    {
      translate([x0, -width/2 - s]) square([x1 - x0, width + 2*s]);
      translate([c, -width/2]) square([x1 - c + 1, width]);      // the tongue stays
    }
  }
}

//-- Two hooks facing each other across a board `span` wide, at X = ±span/2, in the
//-- board's frame (origin on the floor top under its centre). tab: one flag for both,
//-- or [for the -X hook, for the +X hook]
module snapHookPair(span, top, reach = shReach, clearance = shClearance, thick = shThick,
                    width = shWidth, tab = false, relief = shRelief)
{
  tabs = is_list(tab) ? tab : [tab, tab];
  for (m = [0, 1]) mirror([m, 0, 0]) translate([span/2, 0, 0])
    snapHook(top, reach, clearance, thick, width, tabs[1 - m], relief);
}

module snapHookPairFloorCut(span, top, reach = shReach, clearance = shClearance, thick = shThick,
                            width = shWidth, floorThick = 1.6, relief = shRelief)
{
  for (m = [0, 1]) mirror([m, 0, 0]) translate([span/2, 0, 0])
    snapHookFloorCut(top, reach, clearance, thick, width, floorThick, relief);
}
