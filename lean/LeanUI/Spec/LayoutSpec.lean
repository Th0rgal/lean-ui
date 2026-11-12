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
  unfold flexMain
  simp only []
  rw [this, hs]
  omega

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

theorem roundRect_ordered (scale120 : Nat) (r : Rect) (hw : 0 ≤ r.w) (hh : 0 ≤ r.h) :
    (roundRect scale120 r).x ≤ (roundRect scale120 r).right ∧
      (roundRect scale120 r).y ≤ (roundRect scale120 r).bottom := by
  have h1 := roundDev_mono scale120 r.x r.right (by unfold Rect.right; omega)
  have h2 := roundDev_mono scale120 r.y r.bottom (by unfold Rect.bottom; omega)
  constructor
  · show roundDev scale120 r.x ≤ roundDev scale120 r.x + (roundDev scale120 r.right - roundDev scale120 r.x)
    omega
  · show roundDev scale120 r.y ≤ roundDev scale120 r.y + (roundDev scale120 r.bottom - roundDev scale120 r.y)
    omega

private theorem share_step (free total acc g : Nat) (ht : 0 < total) :
    free * g / total ≤ cumShare free total (acc + g) - cumShare free total acc ∧
      cumShare free total (acc + g) - cumShare free total acc ≤ free * g / total + 1 := by
  have hne : total ≠ 0 := by omega
  simp only [cumShare, hne, ite_false, Nat.mul_add]
  rw [Nat.add_div ht]
  generalize free * acc / total = qa
  generalize free * g / total = qg
  split <;> omega

/-- Proportionality: every child gets its exact proportional share, rounded down or up by
less than one sub-unit. Rules out handing all free space to one child. -/
theorem distribute_proportional (free total acc : Nat) (gs : List Nat) (ht : 0 < total) :
    ∀ p, p ∈ gs.zip (distribute free total acc gs) →
      free * p.1 / total ≤ p.2 ∧ p.2 ≤ free * p.1 / total + 1 := by
  induction gs generalizing acc with
  | nil => intro p hp; simp [distribute] at hp
  | cons g gs ih =>
    intro p hp
    simp only [distribute, List.zip_cons_cons, List.mem_cons] at hp
    rcases hp with rfl | hp
    · exact share_step free total acc g ht
    · exact ih _ p hp

/-- Rounding error is at most half a device pixel (7680 scaled sub-units per pixel). -/
theorem roundDev_half_pixel (scale120 : Nat) (v : Int) :
    v * scale120 - 3840 < 7680 * roundDev scale120 v ∧
      7680 * roundDev scale120 v ≤ v * scale120 + 3840 := by
  simp only [roundDev, show subPerPx * scaleDen = 7680 from rfl]; omega

private theorem contains_iff' (r : Rect) (px py : Int) :
    r.contains px py = true ↔ r.x ≤ px ∧ px < r.right ∧ r.y ≤ py ∧ py < r.bottom := by
  simp [Rect.contains, and_assoc]

private theorem floorDev_mono (s : Nat) (a b : Int) (h : a ≤ b) :
    floorDev s a ≤ floorDev s b := by
  unfold floorDev
  exact Int.ediv_le_ediv (by decide) (Int.mul_le_mul_of_nonneg_right h (Int.natCast_nonneg _))

private theorem floor_lt_ceil (s : Nat) (hs : 0 < s) (a b : Int) (h : a < b) :
    floorDev s a < ceilDev s b := by
  have h' : a * (s : Int) < b * (s : Int) := Int.mul_lt_mul_of_pos_right h (by omega)
  simp only [floorDev, ceilDev, show subPerPx * scaleDen = 7680 from rfl]
  omega

/-- Outward rounding loses nothing: the device pixel under any covered point is covered. -/
theorem roundRectOut_covers (scale120 : Nat) (hs : 0 < scale120) (r : Rect) (px py : Int)
    (h : r.contains px py = true) :
    (roundRectOut scale120 r).contains (floorDev scale120 px) (floorDev scale120 py) = true := by
  rw [contains_iff'] at h ⊢
  obtain ⟨h1, h2, h3, h4⟩ := h
  have a1 := floorDev_mono scale120 _ _ h1
  have a2 := floor_lt_ceil scale120 hs _ _ h2
  have a3 := floorDev_mono scale120 _ _ h3
  have a4 := floor_lt_ceil scale120 hs _ _ h4
  simp only [roundRectOut, Rect.right, Rect.bottom] at a2 a4 ⊢
  omega

theorem scrollStep_bounds (content viewport offset : Nat) (delta : Int) :
    scrollStep content viewport offset delta ≤ content - viewport := by
  simp only [scrollStep, scrollLimit]
  omega

theorem scrollStep_interior (content viewport offset : Nat) (delta : Int)
    (hlo : 0 ≤ (offset : Int) + delta)
    (hhi : (offset : Int) + delta ≤ (content - viewport : Nat)) :
    (scrollStep content viewport offset delta : Int) = (offset : Int) + delta := by
  simp only [scrollStep, scrollLimit]
  omega

theorem scrollStep_start (content viewport offset : Nat) (delta : Int)
    (h : (offset : Int) + delta ≤ 0) : scrollStep content viewport offset delta = 0 := by
  simp only [scrollStep, scrollLimit]
  omega

theorem scrollStep_end (content viewport offset : Nat) (delta : Int)
    (h : (content - viewport : Nat) ≤ (offset : Int) + delta) :
    scrollStep content viewport offset delta = content - viewport := by
  simp only [scrollStep, scrollLimit]
  omega

theorem scrollStep_idle (content viewport offset : Nat) (h : offset ≤ content - viewport) :
    scrollStep content viewport offset 0 = offset := by
  simp only [scrollStep, scrollLimit]
  omega

theorem scrollStep_no_overflow (content viewport offset : Nat) (delta : Int)
    (h : content ≤ viewport) : scrollStep content viewport offset delta = 0 := by
  have := scrollStep_bounds content viewport offset delta
  omega

theorem scrollStep_mono (content viewport offset : Nat) (a b : Int) (h : a ≤ b) :
    scrollStep content viewport offset a ≤ scrollStep content viewport offset b := by
  simp only [scrollStep, scrollLimit]
  omega

theorem resizeSub_units (pixels : Nat) : resizeSub pixels = 64 * pixels := by
  simp [resizeSub, subPerPx, Nat.mul_comm]

theorem bufferSize_covers (scale120 pixels : Nat) :
    pixels * scale120 ≤ bufferSize scale120 pixels * 120 := by
  simp only [bufferSize, scaleDen]
  omega

theorem bufferSize_least (scale120 pixels candidate : Nat)
    (h : pixels * scale120 ≤ candidate * 120) : bufferSize scale120 pixels ≤ candidate := by
  simp only [bufferSize, scaleDen]
  omega

theorem bufferSize_from_resize (scale120 pixels : Nat) :
    bufferSize scale120 pixels = (ceilDev scale120 (resizeSub pixels)).toNat := by
  simp only [bufferSize, ceilDev, resizeSub, subPerPx, scaleDen]
  have hm : ((pixels * 64 : Nat) : Int) * scale120 =
      (pixels * scale120 : Nat) * (64 : Int) := by
    simp [Int.natCast_mul, Int.mul_right_comm]
  rw [hm]
  omega

end LeanUI.Spec
