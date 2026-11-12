import LeanUI.Kernel
/-!
# DamageSpec — dirty-rect union soundness and zero-redraw quiescence
-/
namespace LeanUI.Spec

/-- Soundness: every point of an added rect is covered afterwards. -/
theorem damage_add_sound (d : Damage) (r : Rect) (px py : Int)
    (h : r.contains px py = true) : (d.add r).covers px py = true := by
  sorry

/-- Monotonicity: adding a rect never uncovers a point. -/
theorem damage_add_mono (d : Damage) (r : Rect) (px py : Int)
    (h : d.covers px py = true) : (d.add r).covers px py = true := by
  sorry

/-- Empty rects are a no-op (explicit frame). -/
theorem damage_add_empty (d : Damage) (r : Rect) (h : r.isEmpty = true) : d.add r = d := by
  sorry

/-- Quiescence, both directions: a frame is submitted iff some non-empty rect was dirtied. -/
theorem redraw_iff_dirty (rects : List Rect) :
    needsRedraw (rects.foldl Damage.add none) = true ↔ ∃ r, r ∈ rects ∧ r.isEmpty = false := by
  sorry

end LeanUI.Spec
