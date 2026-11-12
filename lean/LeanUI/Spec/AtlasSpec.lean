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

private theorem stacked_append (l : List Shelf) : ∀ (pre : List Shelf) (y0 y1 : Nat),
    Stacked y0 (pre ++ l) y1 ↔ ∃ ym, Stacked y0 pre ym ∧ Stacked ym l y1 := by
  intro pre
  induction pre with
  | nil => intro y0 y1; simp [Stacked]
  | cons s pre ih =>
    intro y0 y1
    simp only [List.cons_append, Stacked, ih]
    constructor
    · rintro ⟨h0, ym, h1, h2⟩; exact ⟨ym, ⟨h0, h1⟩, h2⟩
    · rintro ⟨ym, ⟨h0, h1⟩, h2⟩; exact ⟨h0, ym, h1, h2⟩

private theorem stacked_bounds : ∀ (l : List Shelf) (y0 y1 : Nat), Stacked y0 l y1 →
    y0 ≤ y1 ∧ ∀ t, t ∈ l → y0 ≤ t.y ∧ t.y + t.h ≤ y1 := by
  intro l
  induction l with
  | nil => intro y0 y1 h; simp [Stacked] at h; simp [h]
  | cons s l ih =>
    intro y0 y1 h
    obtain ⟨h0, h1⟩ := h
    obtain ⟨h2, h3⟩ := ih _ _ h1
    refine ⟨by omega, ?_⟩
    intro t ht
    rcases List.mem_cons.mp ht with rfl | ht
    · omega
    · have := h3 t ht; omega

private theorem fitShelf_some (width w h : Nat) : ∀ (l l' : List Shelf) (r : Rect),
    Atlas.fitShelf width w h l = some (r, l') →
    ∃ pre s post, l = pre ++ s :: post ∧ l' = pre ++ { s with used := s.used + w } :: post ∧
      r = Atlas.slot s w h ∧ h ≤ s.h ∧ s.used + w ≤ width := by
  intro l
  induction l with
  | nil => intro l' r hf; simp [Atlas.fitShelf] at hf
  | cons s rest ih =>
    intro l' r hf
    unfold Atlas.fitShelf at hf
    by_cases hc : h ≤ s.h ∧ s.used + w ≤ width
    · simp only [hc, and_self, ite_true] at hf
      injection hf with hf
      injection hf with hr hl
      exact ⟨[], s, rest, rfl, hl.symm, hr.symm, hc.1, hc.2⟩
    · simp only [hc, ite_false] at hf
      cases hfit : Atlas.fitShelf width w h rest with
      | none => simp [hfit] at hf
      | some p =>
        obtain ⟨r0, rest'⟩ := p
        simp [hfit] at hf
        obtain ⟨hr, hl⟩ := hf
        obtain ⟨pre, s0, post, e1, e2, e3, e4, e5⟩ := ih rest' r0 hfit
        exact ⟨s :: pre, s0, post, by simp [e1], by simp [← hl, e2], by rw [← hr]; exact e3, e4, e5⟩

private theorem alloc_cases (a a' : Atlas) (w h : Nat) (r : Rect)
    (h₁ : a.alloc w h = some (r, a')) :
    w ≤ a.width ∧
    ((∃ pre s post, a.shelves = pre ++ s :: post ∧
        a' = { a with shelves := pre ++ { s with used := s.used + w } :: post } ∧
        r = Atlas.slot s w h ∧ h ≤ s.h ∧ s.used + w ≤ a.width) ∨
     (a.nextY + h ≤ a.height ∧ r = { x := 0, y := a.nextY, w := w, h := h } ∧
        a' = { a with shelves := a.shelves ++ [{ y := a.nextY, h := h, used := w }],
                      nextY := a.nextY + h })) := by
  unfold Atlas.alloc at h₁
  by_cases hg : w = 0 ∨ h = 0 ∨ w > a.width
  · simp [hg] at h₁
  · simp only [hg, ite_false] at h₁
    refine ⟨by omega, ?_⟩
    cases hfit : Atlas.fitShelf a.width w h a.shelves with
    | some p =>
      obtain ⟨r0, l'⟩ := p
      simp [hfit] at h₁
      obtain ⟨hr, ha⟩ := h₁
      obtain ⟨pre, s, post, e1, e2, e3, e4, e5⟩ := fitShelf_some _ _ _ _ _ _ hfit
      exact Or.inl ⟨pre, s, post, e1, by rw [← ha, e2], by rw [← hr]; exact e3, e4, e5⟩
    | none =>
      simp [hfit] at h₁
      obtain ⟨hy, hr, ha⟩ := h₁
      exact Or.inr ⟨hy, hr.symm, ha.symm⟩

private theorem contains_nat (x y w h px py : Nat)
    (hin : Rect.contains { x := x, y := y, w := w, h := h } px py = true) :
    x ≤ px ∧ px < x + w ∧ y ≤ py ∧ py < y + h := by
  simp only [Rect.contains, Rect.right, Rect.bottom, Bool.and_eq_true] at hin
  obtain ⟨⟨⟨a, b⟩, c⟩, d⟩ := hin
  have := of_decide_eq_true a
  have := of_decide_eq_true b
  have := of_decide_eq_true c
  have := of_decide_eq_true d
  omega

theorem wf_empty (w h : Nat) : WF { width := w, height := h } := by
  exact ⟨rfl, Nat.zero_le _, by intro s hs; cases hs⟩

theorem alloc_wf (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) : WF a' := by
  obtain ⟨hst, hny, hu⟩ := hwf
  obtain ⟨hw, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · subst e2
    rw [e1] at hst hu
    refine ⟨?_, hny, ?_⟩
    · obtain ⟨ym, hp, hs⟩ := (stacked_append _ _ _ _).mp hst
      exact (stacked_append _ _ _ _).mpr ⟨ym, hp, hs⟩
    · intro t ht
      rcases List.mem_append.mp ht with ht | ht
      · exact hu t (List.mem_append_left _ ht)
      · rcases List.mem_cons.mp ht with rfl | ht
        · exact e5
        · exact hu t (List.mem_append_right _ (List.mem_cons_of_mem _ ht))
  · subst ha
    refine ⟨?_, hy, ?_⟩
    · exact (stacked_append _ _ _ _).mpr ⟨a.nextY, hst, rfl, rfl⟩
    · intro t ht
      rcases List.mem_append.mp ht with ht | ht
      · exact hu t ht
      · simp at ht
        subst ht
        exact hw

/-- The slot has exactly the requested size. -/
theorem alloc_size (a a' : Atlas) (w h : Nat) (r : Rect)
    (h₁ : a.alloc w h = some (r, a')) : r.w = w ∧ r.h = h := by
  obtain ⟨_, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · subst e3
    exact ⟨rfl, rfl⟩
  · subst hr
    exact ⟨rfl, rfl⟩

/-- The slot lies inside the texture. -/
theorem alloc_in_bounds (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) :
    r.right ≤ a.width ∧ r.bottom ≤ a.height := by
  obtain ⟨hst, hny, hu⟩ := hwf
  obtain ⟨hw, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · have hb := (stacked_bounds _ _ _ hst).2 s (by rw [e1]; simp)
    subst e3
    simp only [Atlas.slot, Rect.right, Rect.bottom]
    omega
  · subst hr
    simp only [Rect.right, Rect.bottom]
    omega

/-- Freshness: no texel of the new slot was owned before. -/
theorem alloc_fresh (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat)
    (hin : r.contains px py = true) : ¬ Owns a px py := by
  obtain ⟨hst, hny, hu⟩ := hwf
  rintro ⟨t, ht, ht1, ht2, ht3⟩
  obtain ⟨hw, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · subst e3
    have hin := contains_nat s.used s.y w h px py hin
    rw [e1] at hst ht
    obtain ⟨ym, hpre, hsy, hpost⟩ := (stacked_append _ _ _ _).mp hst
    rcases List.mem_append.mp ht with ht | ht
    · have := (stacked_bounds _ _ _ hpre).2 t ht
      omega
    · rcases List.mem_cons.mp ht with rfl | ht
      · omega
      · have := (stacked_bounds _ _ _ hpost).2 t ht
        omega
  · subst hr
    have hin := contains_nat 0 a.nextY w h px py hin
    have := (stacked_bounds _ _ _ hst).2 t ht
    omega

/-- The new slot is owned afterwards. -/
theorem alloc_owns (a a' : Atlas) (w h : Nat) (r : Rect) (hwf : WF a)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat)
    (hin : r.contains px py = true) : Owns a' px py := by
  have _ := hwf
  obtain ⟨hw, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · subst e3 e2
    have hin := contains_nat s.used s.y w h px py hin
    refine ⟨{ s with used := s.used + w }, by simp, ?_, ?_, ?_⟩ <;> simp only <;> omega
  · subst hr ha
    have hin := contains_nat 0 a.nextY w h px py hin
    refine ⟨{ y := a.nextY, h := h, used := w }, by simp, ?_, ?_, ?_⟩ <;> simp only <;> omega

/-- Ownership only grows: earlier glyphs are never handed out again. -/
theorem owns_mono (a a' : Atlas) (w h : Nat) (r : Rect)
    (h₁ : a.alloc w h = some (r, a')) (px py : Nat) (ho : Owns a px py) : Owns a' px py := by
  obtain ⟨t, ht, ht1, ht2, ht3⟩ := ho
  obtain ⟨hw, ⟨pre, s, post, e1, e2, e3, e4, e5⟩ | ⟨hy, hr, ha⟩⟩ := alloc_cases a a' w h r h₁
  · subst e2
    rw [e1] at ht
    rcases List.mem_append.mp ht with ht | ht
    · exact ⟨t, by simp [ht], ht1, ht2, ht3⟩
    · rcases List.mem_cons.mp ht with rfl | ht
      · exact ⟨{ t with used := t.used + w }, by simp, ht1, ht2, Nat.lt_add_right _ ht3⟩
      · exact ⟨t, by simp [ht], ht1, ht2, ht3⟩
  · subst ha
    exact ⟨t, List.mem_append_left _ ht, ht1, ht2, ht3⟩

/-- Corollary: two successive allocations never share a texel. -/
theorem alloc_disjoint (a a₁ a₂ : Atlas) (w₁ h₁ w₂ h₂ : Nat) (r₁ r₂ : Rect) (hwf : WF a)
    (e₁ : a.alloc w₁ h₁ = some (r₁, a₁)) (e₂ : a₁.alloc w₂ h₂ = some (r₂, a₂)) (px py : Nat) :
    ¬ (r₁.contains px py = true ∧ r₂.contains px py = true) := by
  rintro ⟨c1, c2⟩
  exact alloc_fresh a₁ a₂ w₂ h₂ r₂ (alloc_wf a a₁ w₁ h₁ r₁ hwf e₁) e₂ px py c2
    (alloc_owns a a₁ w₁ h₁ r₁ hwf e₁ px py c1)

/-- Cache soundness on a trace: if every entry was produced by `f` on a key of the trace,
and the hash is collision-free on that trace, a hit returns `f k`. -/
theorem cache_lookup_sound {α β : Type} (hash : α → UInt64) (f : α → β) (keys : List α)
    (c : HashCache β) (hcf : CollisionFreeOn hash keys)
    (hent : ∀ e, e ∈ c.entries → ∃ k', k' ∈ keys ∧ e = (hash k', f k'))
    (k : α) (hk : k ∈ keys) (v : β) (hl : c.lookup hash k = some v) : v = f k := by
  unfold HashCache.lookup at hl
  cases hf : c.entries.find? (·.1 == hash k) with
  | none => simp [hf] at hl
  | some e =>
    simp [hf] at hl
    have hp := List.find?_some hf
    obtain ⟨k', hk', he⟩ := hent e (List.mem_of_find?_eq_some hf)
    subst he
    simp at hp
    have := hcf k' hk' k hk hp
    subst this
    exact hl.symm

/-- A freshly inserted key is found. -/
theorem cache_lookup_insert {α β : Type} (hash : α → UInt64) (c : HashCache β) (k : α) (v : β) :
    (c.insert hash k v).lookup hash k = some v := by
  simp [HashCache.insert, HashCache.lookup]

end LeanUI.Spec
