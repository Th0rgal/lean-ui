import LeanUI.Kernel
/-!
# LayoutSpec — flex conservation, clamping, device-pixel rounding

Statements are frozen by the coordinator; the shard owner (A1) supplies proofs only.
-/
namespace LeanUI.Spec

private theorem cumShare_mono (free total a b : Nat) (h : a ≤ b) :
    cumShare free total a ≤ cumShare free total b := by
  unfold cumShare; split
  · exact Nat.le_refl _
  · exact Nat.div_le_div_right (Nat.mul_le_mul_left _ h)

/-- Shares telescope: the sum of a suffix is the difference of cumulative shares. -/
theorem distribute_sum (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc gs).sum
      = cumShare free total (acc + gs.sum) - cumShare free total acc := by
  induction gs generalizing acc with
  | nil => simp [distribute]
  | cons g gs ih =>
    simp only [distribute, List.sum_cons, ih]
    have h1 := cumShare_mono free total acc (acc + g) (by omega)
    have h2 := cumShare_mono free total (acc + g) (acc + g + gs.sum) (by omega)
    rw [← Nat.add_assoc]; omega

/-- Conservation: with any positive total weight, every free sub-unit is handed out exactly once. -/
theorem distribute_conserves (free : Nat) (gs : List Nat) (h : 0 < gs.sum) :
    (distribute free gs.sum 0 gs).sum = free := by
  have hne : gs.sum ≠ 0 := by omega
  rw [distribute_sum]
  simp [cumShare, hne, Nat.mul_div_cancel _ h]

theorem distribute_length (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc gs).length = gs.length := by
  induction gs generalizing acc <;> simp [distribute, *]

/-- A zero-weight child never receives free space. -/
theorem distribute_zero_weight (free total acc : Nat) (gs : List Nat) :
    (distribute free total acc (0 :: gs)).head? = some 0 := by
  simp [distribute]

theorem clampNat_bounds (lo hi v : Nat) (h : lo ≤ hi) :
    lo ≤ clampNat lo hi v ∧ clampNat lo hi v ≤ hi := by
  unfold clampNat; omega

theorem clampNat_id (lo hi v : Nat) (h₁ : lo ≤ v) (h₂ : v ≤ hi) : clampNat lo hi v = v := by
  unfold clampNat; omega

theorem flexMain_length (avail : Nat) (items : List FlexItem) :
    (flexMain avail items).length = items.length := by
  simp [flexMain, distribute_length]

private theorem zip_clamp_bounds (items : List FlexItem) (es : List Nat)
    (h : ∀ it, it ∈ items → it.minMain ≤ it.maxMain) :
    ∀ p, p ∈ items.zip ((items.zip es).map fun (it, e) =>
        clampNat it.minMain it.maxMain (it.basis + e)) →
      p.1.minMain ≤ p.2 ∧ p.2 ≤ p.1.maxMain := by
  induction items generalizing es with
  | nil => intro p hp; simp at hp
  | cons it its ih =>
    cases es with
    | nil => intro p hp; simp at hp
    | cons e es =>
      intro p hp
      simp only [List.zip_cons_cons, List.map_cons, List.mem_cons] at hp
      rcases hp with rfl | hp
      · exact clampNat_bounds _ _ _ (h it (List.mem_cons_self ..))
      · exact ih es (fun x hx => h x (List.mem_cons_of_mem _ hx)) p hp

private theorem zip_clamp_sum (avail : Nat) (items : List FlexItem) (es : List Nat)
    (hlen : es.length = items.length)
    (hb : (items.map (·.basis)).sum + es.sum ≤ avail)
    (hfree : ∀ it, it ∈ items → it.minMain = 0 ∧ avail ≤ it.maxMain) :
    ((items.zip es).map fun (it, e) => clampNat it.minMain it.maxMain (it.basis + e)).sum
      = (items.map (·.basis)).sum + es.sum := by
  induction items generalizing es with
  | nil => cases es <;> simp_all
  | cons it its ih =>
    cases es with
    | nil => simp at hlen
    | cons e es =>
      have hlen' : es.length = its.length := by simpa using hlen
      simp only [List.zip_cons_cons, List.map_cons, List.sum_cons] at hb ⊢
      have ht := ih es hlen' (by omega) (fun x hx => hfree x (List.mem_cons_of_mem _ hx))
      obtain ⟨h0, h1⟩ := hfree it (List.mem_cons_self ..)
      rw [ht, clampNat_id _ _ _ (by omega) (by omega)]; omega

/-- Every child lands inside its own min/max range (`flexMain_length` makes the zip total). -/
theorem flexMain_bounds (avail : Nat) (items : List FlexItem)
    (h : ∀ it, it ∈ items → it.minMain ≤ it.maxMain) :
    ∀ p, p ∈ items.zip (flexMain avail items) → p.1.minMain ≤ p.2 ∧ p.2 ≤ p.1.maxMain := by
  exact zip_clamp_bounds items _ h

/-- When no clamp binds and some child can grow, the line is filled exactly. -/
theorem flexMain_fills (avail : Nat) (items : List FlexItem)
    (hfit : (items.map (·.basis)).sum ≤ avail)
    (hgrow : 0 < (items.map (·.grow)).sum)
    (hfree : ∀ it, it ∈ items → it.minMain = 0 ∧ avail ≤ it.maxMain) :
    (flexMain avail items).sum = avail := by
  have hs := distribute_conserves (avail - (items.map (·.basis)).sum) (items.map (·.grow)) hgrow
  have hl : (distribute (avail - (items.map (·.basis)).sum) (items.map (·.grow)).sum 0
      (items.map (·.grow))).length = items.length := by rw [distribute_length]; simp
  have := zip_clamp_sum avail items _ hl (by rw [hs]; omega) hfree
  unfold flexMain; simp only []; rw [this, hs]; omega

theorem roundDev_mono (scale120 : Nat) (a b : Int) (h : a ≤ b) :
    roundDev scale120 a ≤ roundDev scale120 b := by
  unfold roundDev
  exact Int.ediv_le_ediv (by decide)
    (Int.add_le_add_right (Int.mul_le_mul_of_nonneg_right h (Int.natCast_nonneg _)) _)

/-- At 1x, whole logical pixels map to themselves. -/
theorem roundDev_exact_1x (p : Int) : roundDev 120 (64 * p) = p := by
  simp only [roundDev, show subPerPx * scaleDen = 7680 from rfl]; omega

/-- At 2x, whole logical pixels map to exactly twice themselves. -/
theorem roundDev_exact_2x (p : Int) : roundDev 240 (64 * p) = 2 * p := by
  simp only [roundDev, show subPerPx * scaleDen = 7680 from rfl]; omega

/-- Rects that share an edge before rounding share it after: no seams, no overlap. -/
theorem roundRect_abut (scale120 : Nat) (a b : Rect) (h : a.right = b.x) :
    (roundRect scale120 a).right = (roundRect scale120 b).x := by
  show roundDev scale120 a.x + (roundDev scale120 a.right - roundDev scale120 a.x)
    = roundDev scale120 b.x
  rw [h]; omega

theorem roundRect_nonneg (scale120 : Nat) (r : Rect) (hw : 0 ≤ r.w) (hh : 0 ≤ r.h) :
    0 ≤ (roundRect scale120 r).w ∧ 0 ≤ (roundRect scale120 r).h := by
  have h1 := roundDev_mono scale120 r.x r.right (by unfold Rect.right; omega)
  have h2 := roundDev_mono scale120 r.y r.bottom (by unfold Rect.bottom; omega)
  constructor
  · show 0 ≤ roundDev scale120 r.right - roundDev scale120 r.x; omega
  · show 0 ≤ roundDev scale120 r.bottom - roundDev scale120 r.y; omega

end LeanUI.Spec
