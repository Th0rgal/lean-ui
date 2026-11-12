import LeanUI.Kernel
/-!
# AtlasSpec — shelf allocator non-overlap and per-trace cache soundness

Shelf occupancy is shared state: it is specified by an ownership relation that only
grows (`owns_mono`) and that every new slot is fresh against (`alloc_fresh`).
-/
namespace LeanUI.Spec

/-- Texel `(px, py)` is already handed out (or shadowed by a shelf's used prefix). -/
def Owns (a : Atlas) (px py : Nat) : Prop :=
  ∃ s, s ∈ a.shelves ∧ s.y ≤ py ∧ py < s.y + s.h ∧ px < s.used

/-- Shelves are stacked top to bottom without gaps, starting at row `y0`. -/
def Stacked : Nat → List Shelf → Nat → Prop
  | y0, [], y1 => y0 = y1
  | y0, s :: rest, y1 => s.y = y0 ∧ Stacked (y0 + s.h) rest y1

/-- Well-formed atlas: stacked shelves ending at `nextY`, all inside the texture. -/
def WF (a : Atlas) : Prop :=
  Stacked 0 a.shelves a.nextY ∧ a.nextY ≤ a.height ∧ ∀ s, s ∈ a.shelves → s.used ≤ a.width

theorem wf_empty (w h : Nat) : WF { width := w, height := h } := by
  sorry

theorem alloc_wf (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) : WF a' := by
  sorry

/-- The slot has the requested size and lies inside the texture. -/
theorem alloc_in_bounds (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) :
    r.w = w ∧ r.h = h ∧ 0 ≤ r.x ∧ 0 ≤ r.y ∧ r.right ≤ a.width ∧ r.bottom ≤ a.height := by
  sorry

/-- Freshness: no texel of the new slot was owned before. -/
theorem alloc_fresh (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat)
    (hin : r.contains px py = true) : ¬ Owns a px py := by
  sorry

/-- The new slot is owned afterwards. -/
theorem alloc_owns (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat)
    (hin : r.contains px py = true) : Owns a' px py := by
  sorry

/-- Ownership only grows: earlier glyphs are never handed out again. -/
theorem owns_mono (a a' : Atlas) (w h : Nat) (r : Rect)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat) (ho : Owns a px py) : Owns a' px py := by
  sorry

/-- Corollary: two successive allocations never share a texel. -/
theorem alloc_disjoint (a a₁ a₂ : Atlas) (w₁ h₁ w₂ h₂ : Nat) (r₁ r₂ : Rect) (hwf : WF a)
    (e₁ : a.alloc w₁ h₁ = some (r₁, a₁)) (e₂ : a₁.alloc w₂ h₂ = some (r₂, a₂)) (px py : Nat) :
    ¬ (r₁.contains px py = true ∧ r₂.contains px py = true) := by
  sorry

/-- Cache soundness on a trace: if every entry was produced by `f` on a key of the trace,
and the hash is collision-free on that trace, a hit returns `f k`. -/
theorem cache_lookup_sound {α β : Type} (hash : α → UInt64) (f : α → β) (keys : List α)
    (c : HashCache β) (hcf : CollisionFreeOn hash keys)
    (hent : ∀ e, e ∈ c.entries → ∃ k', k' ∈ keys ∧ e = (hash k', f k'))
    (k : α) (hk : k ∈ keys) (v : β) (hl : c.lookup hash k = some v) : v = f k := by
  sorry

/-- A freshly inserted key is found. -/
theorem cache_lookup_insert {α β : Type} (hash : α → UInt64) (c : HashCache β) (k : α) (v : β) :
    (c.insert hash k v).lookup hash k = some v := by
  sorry

end LeanUI.Spec
