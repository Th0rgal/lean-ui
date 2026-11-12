import LeanUI.Kernel
/-!
# MutantSuite — two-sided negative witnesses

Each mutant is a plausible wrong implementation; each theorem exhibits a concrete input on
which the mutant breaks a contract that the kernel satisfies (proved in the sibling shards).
-/
namespace LeanUI.Spec.Mutant

/-- Mutant: independent floor per child (loses remainders). -/
def distributeNaive (free total : Nat) (gs : List Nat) : List Nat :=
  gs.map fun g => if total = 0 then 0 else free * g / total

theorem distributeNaive_leaks : (distributeNaive 10 3 [1, 1, 1]).sum ≠ 10 := by
  decide

theorem distribute_same_input_conserves : (distribute 10 3 0 [1, 1, 1]).sum = 10 := by
  decide

/-- Mutant: round position and size independently (opens seams at fractional scales). -/
def roundRectBySize (scale120 : Nat) (r : Rect) : Rect :=
  { x := roundDev scale120 r.x, y := roundDev scale120 r.y,
    w := roundDev scale120 r.w, h := roundDev scale120 r.h }

/-- At 1.5x two abutting 1px-wide rects at x = 1px and 2px overlap by one device pixel. -/
theorem roundRectBySize_seam :
    let a : Rect := { x := 64, y := 0, w := 64, h := 64 }
    let b : Rect := { x := 128, y := 0, w := 64, h := 64 }
    a.right = b.x ∧ (roundRectBySize 180 a).right ≠ (roundRectBySize 180 b).x := by
  decide

/-- Mutant: focus request that ignores modal traps. -/
def requestNoTrap (s : FocusState) (id : EntityId) : FocusState := { s with owner := some id }

theorem requestNoTrap_escapes :
    let s : FocusState := { owner := some 1, traps := [[1, 2]] }
    FocusState.Confined s ∧ ¬ FocusState.Confined (requestNoTrap s 7) := by
  refine ⟨?_, fun hc => absurd (hc 7 rfl) (by decide)⟩
  intro id h
  simp at h
  subst h
  decide

/-- Mutant: damage that keeps only the first dirty rect instead of taking the union. -/
def damageKeepFirst (d : Damage) (r : Rect) : Damage :=
  if r.isEmpty then d else
    match d with
    | none => some r
    | some a => some a

/-- A second dirty rect is silently dropped by the mutant and covered by the kernel. -/
theorem damageKeepFirst_drops :
    let d : Damage := some { x := 0, y := 0, w := 10, h := 10 }
    let r : Rect := { x := 50, y := 50, w := 10, h := 10 }
    r.contains 55 55 = true ∧ (damageKeepFirst d r).covers 55 55 = false ∧
      (d.add r).covers 55 55 = true := by
  decide

/-- Mutant: shelf allocator that forgets to advance `used`. -/
def allocNoAdvance (a : Atlas) (w h : Nat) : Option (Rect × Atlas) :=
  (a.alloc w h).map fun (r, a') =>
    (r, { a' with shelves := a'.shelves.map fun s => { s with used := 0 } })

theorem allocNoAdvance_overlaps :
    ∃ r₁ a₁ r₂ a₂, allocNoAdvance { width := 64, height := 64 } 8 8 = some (r₁, a₁) ∧
      allocNoAdvance a₁ 8 8 = some (r₂, a₂) ∧ r₁.contains 0 0 = true ∧ r₂.contains 0 0 = true := by
  exact ⟨{ x := 0, y := 0, w := 8, h := 8 },
    { width := 64, height := 64, shelves := [{ y := 0, h := 8, used := 0 }], nextY := 8 },
    { x := 0, y := 0, w := 8, h := 8 },
    { width := 64, height := 64, shelves := [{ y := 0, h := 8, used := 0 }], nextY := 8 },
    by decide, by decide, by decide, by decide⟩

/-- Without `CollisionFreeOn`, the cache contract is false: a constant hash serves the wrong value. -/
theorem cache_unsound_on_collision :
    let hash : Nat → UInt64 := fun _ => 0
    let c : HashCache Nat := ({} : HashCache Nat).insert hash 1 100
    ¬ CollisionFreeOn hash [1, 2] ∧ c.lookup hash 2 = some 100 := by
  refine ⟨fun h => absurd (h 1 (by simp) 2 (by simp) rfl) (by decide), ?_⟩
  decide

/-- Mutant: cache lookup that returns the newest entry without comparing hashes. -/
def lookupHead {β : Type} (c : HashCache β) : Option β := c.entries.head?.map (·.2)

/-- With an injective hash the kernel finds the older key; the mutant serves the newer value. -/
theorem lookupHead_wrong_entry :
    let hash : Nat → UInt64 := fun n => n.toUInt64
    let c : HashCache Nat := (({} : HashCache Nat).insert hash 1 10).insert hash 2 20
    c.lookup hash 1 = some 10 ∧ lookupHead c = some 20 := by
  decide

def scrollUnsigned (content viewport offset : Nat) (delta : Int) : Nat :=
  min (content - viewport) (offset + delta.toNat)

theorem scrollUnsigned_negWitness :
    scrollStep 100 20 40 (-10) = 30 ∧ scrollUnsigned 100 20 40 (-10) ≠ 30 := by
  decide

def scrollUnbounded (offset : Nat) (delta : Int) : Nat := ((offset : Int) + delta).toNat

theorem scrollUnbounded_negWitness :
    scrollStep 100 20 70 30 = 80 ∧ scrollUnbounded 70 30 > 80 := by
  decide

def bufferFloor (scale120 pixels : Nat) : Nat := pixels * scale120 / scaleDen

theorem bufferFloor_negWitness :
    bufferSize 180 1 = 2 ∧ bufferFloor 180 1 * 120 < 1 * 180 := by
  decide

def borderScaled (scale120 : Nat) (rect : Rect) (color : Color) : Prim :=
  .quad rect 0 0 (bufferSize scale120 1) color

theorem borderScaled_negWitness :
    focusBorder true { x := 0, y := 0, w := 100, h := 80 } 0 =
      .quad { x := 0, y := 0, w := 100, h := 80 } 0 0 1 0 ∧
    borderScaled 240 { x := 0, y := 0, w := 100, h := 80 } 0 ≠
      focusBorder true { x := 0, y := 0, w := 100, h := 80 } 0 := by
  decide

def focusAlwaysDamaged (rect : Rect) : Damage := some rect

theorem focusAlwaysDamaged_negWitness :
    ∀ focused : Bool,
      focusBorderDamage focused focused { x := 0, y := 0, w := 100, h := 80 } = none ∧
      focusAlwaysDamaged { x := 0, y := 0, w := 100, h := 80 } ≠ none := by
  intro focused
  cases focused <;> decide

theorem focusAlwaysDamaged_changedWitness :
    ∀ focused : Bool,
      focusBorderDamage focused (!focused) { x := 0, y := 0, w := 100, h := 80 } =
        focusAlwaysDamaged { x := 0, y := 0, w := 100, h := 80 } := by
  intro focused
  cases focused <;> decide

end LeanUI.Spec.Mutant
