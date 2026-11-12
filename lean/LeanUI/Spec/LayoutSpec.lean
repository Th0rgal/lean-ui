import LeanUI.Kernel
/-!
# LayoutSpec — flex conservation, clamping, device-pixel rounding

Statements are frozen by the coordinator; the shard owner (A1) supplies proofs only.
-/
namespace LeanUI.Spec

/-- Shares telescope: the sum of a suffix is the difference of cumulative shares. -/
theorem distribute_sum (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc gs).sum
      = cumShare free total (acc + gs.sum) - cumShare free total acc := by
  sorry

/-- Conservation: with any positive total weight, every free sub-unit is handed out exactly once. -/
theorem distribute_conserves (free : Nat) (gs : List Nat) (h : 0 < gs.sum) :
    (distribute free gs.sum 0 gs).sum = free := by
  sorry

theorem distribute_length (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc gs).length = gs.length := by
  sorry

/-- A zero-weight child never receives free space. -/
theorem distribute_zero_weight (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc (0 :: gs)).head? = some 0 := by
  sorry

theorem clampNat_bounds (lo hi v : Nat) (h : lo ≤ hi) :
    lo ≤ clampNat lo hi v ∧ clampNat lo hi v ≤ hi := by
  sorry

theorem clampNat_id (lo hi v : Nat) (h₁ : lo ≤ v) (h₂ : v ≤ hi) : clampNat lo hi v = v := by
  sorry

theorem flexMain_length (avail : Nat) (items : List FlexItem) :
    (flexMain avail items).length = items.length := by
  sorry

/-- Every child lands inside its own min/max range (`flexMain_length` makes the zip total). -/
theorem flexMain_bounds (avail : Nat) (items : List FlexItem)
    (h : ∀ it, it ∈ items → it.minMain ≤ it.maxMain) :
    ∀ p, p ∈ items.zip (flexMain avail items) → p.1.minMain ≤ p.2 ∧ p.2 ≤ p.1.maxMain := by
  sorry

/-- When no clamp binds and some child can grow, the line is filled exactly. -/
theorem flexMain_fills (avail : Nat) (items : List FlexItem)
    (hfit : (items.map (·.basis)).sum ≤ avail)
    (hgrow : 0 < (items.map (·.grow)).sum)
    (hfree : ∀ it, it ∈ items → it.minMain = 0 ∧ avail ≤ it.maxMain) :
    (flexMain avail items).sum = avail := by
  sorry

theorem roundDev_mono (scale120 : Nat) (a b : Int) (h : a ≤ b) :
    roundDev scale120 a ≤ roundDev scale120 b := by
  sorry

/-- At 1x, whole logical pixels map to themselves. -/
theorem roundDev_exact_1x (p : Int) : roundDev 120 (64 * p) = p := by
  sorry

/-- At 2x, whole logical pixels map to exactly twice themselves. -/
theorem roundDev_exact_2x (p : Int) : roundDev 240 (64 * p) = 2 * p := by
  sorry

/-- Rects that share an edge before rounding share it after: no seams, no overlap. -/
theorem roundRect_abut (scale120 : Nat) (a b : Rect) (h : a.right = b.x) :
    (roundRect scale120 a).right = (roundRect scale120 b).x := by
  sorry

theorem roundRect_nonneg (scale120 : Nat) (r : Rect) (hw : 0 ≤ r.w) (hh : 0 ≤ r.h) :
    0 ≤ (roundRect scale120 r).w ∧ 0 ≤ (roundRect scale120 r).h := by
  sorry

end LeanUI.Spec
