/-!
# LeanUI.Defs — frozen core types (0 `import Lean`)

Units. Logical coordinates are integers in 1/64 logical pixel (`Sub`).
Output scale is an integer in 1/120 (`wp-fractional-scale-v1` wire unit), so
one device pixel = `subPerPx * scaleDen = 7680` scaled sub-units.
-/
namespace LeanUI

/-- Sub-units per logical pixel. -/
def subPerPx : Nat := 64
/-- Denominator of the Wayland fractional scale (`scale120 = 120` is 1x). -/
def scaleDen : Nat := 120

/-- Axis-aligned rectangle; `w`/`h` are extents, a rect with `w ≤ 0 ∨ h ≤ 0` is empty. -/
structure Rect where
  x : Int
  y : Int
  w : Int
  h : Int
  deriving DecidableEq, Repr, Inhabited

namespace Rect
@[inline] def right (r : Rect) : Int := r.x + r.w
@[inline] def bottom (r : Rect) : Int := r.y + r.h
@[inline] def isEmpty (r : Rect) : Bool := r.w ≤ 0 || r.h ≤ 0
/-- Half-open point membership. -/
@[inline] def contains (r : Rect) (px py : Int) : Bool :=
  r.x ≤ px && px < r.right && r.y ≤ py && py < r.bottom
end Rect

/-- Straight-alpha RGBA8, packed `0xRRGGBBAA`. -/
abbrev Color := UInt32

inductive Axis where
  | row | column
  deriving DecidableEq, Repr, Inhabited

inductive Align where
  | start | center | «end» | stretch
  deriving DecidableEq, Repr, Inhabited

/-- One flex child along the main axis (all sizes in `Sub`). -/
structure FlexItem where
  basis : Nat
  grow : Nat := 0
  minMain : Nat := 0
  maxMain : Nat
  deriving DecidableEq, Repr

/-- Stable identity of a UI entity (focus target, hit region, cache owner). -/
abbrev EntityId := Nat

/-- Backend-agnostic scene primitive, already in device pixels. Paint order is array order. -/
inductive Prim where
  /-- SDF rounded rect with optional inner border. -/
  | quad (rect : Rect) (fill : Color) (radius : Nat) (borderWidth : Nat) (border : Color)
  /-- SDF drop shadow under `rect`. -/
  | shadow (rect : Rect) (color : Color) (radius : Nat) (blur : Nat)
  /-- Atlas-textured glyph: `src` in atlas texels, `dst` in device pixels. -/
  | glyph (src : Rect) (dst : Rect) (color : Color) (isColor : Bool)
  /-- Push a scissor rect (intersected with the current one). -/
  | clipPush (rect : Rect)
  | clipPop
  deriving DecidableEq, Repr

abbrev Scene := Array Prim

/-- Accumulated damage: `none` means nothing to redraw. -/
abbrev Damage := Option Rect

inductive KeyState where
  | pressed | released | repeated
  deriving DecidableEq, Repr

/-- Input events delivered by the platform shim, in logical `Sub` coordinates. -/
inductive Event where
  | pointerMove (x y : Int)
  | pointerButton (x y : Int) (button : Nat) (down : Bool)
  | scroll (x y : Int) (dx dy : Int)
  | key (keysym : UInt32) (mods : UInt32) (state : KeyState)
  /-- Committed text (plain key text or IME commit). -/
  | text (utf8 : String)
  /-- IME preedit string with cursor byte range; empty string clears it. -/
  | preedit (utf8 : String) (cursorBegin cursorEnd : Int)
  | resize (w h : Nat)
  | scale (scale120 : Nat)
  | windowFocus (focused : Bool)
  | closeRequested
  deriving Repr

/-- Keyboard focus: at most one owner (by type), confined to the top modal trap if any. -/
structure FocusState where
  owner : Option EntityId := none
  /-- Stack of modal traps, innermost first; each lists the focusable ids of that modal. -/
  traps : List (List EntityId) := []
  deriving DecidableEq, Repr

/-- One open shelf of the glyph atlas: a horizontal strip filled left to right. -/
structure Shelf where
  y : Nat
  h : Nat
  used : Nat
  deriving DecidableEq, Repr

/-- Shelf-packed atlas occupancy. `nextY` is the first row not owned by any shelf. -/
structure Atlas where
  width : Nat
  height : Nat
  shelves : List Shelf := []
  nextY : Nat := 0
  deriving DecidableEq, Repr

/-- Identity of a rasterised glyph. `subpx` is the horizontal subpixel bin. -/
structure GlyphKey where
  font : Nat
  glyph : Nat
  sizeSub : Nat
  subpx : Nat
  deriving DecidableEq, Repr

/-- A hash is collision-free on the finite set of keys a trace actually uses.
Global injectivity is false by pigeonhole whenever the key space exceeds the hash space. -/
def CollisionFreeOn {α β : Type} (hash : α → β) (keys : List α) : Prop :=
  ∀ a, a ∈ keys → ∀ b, b ∈ keys → hash a = hash b → a = b

end LeanUI
