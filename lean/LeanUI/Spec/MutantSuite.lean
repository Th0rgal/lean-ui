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
  sorry

theorem distribute_same_input_conserves : (distribute 10 3 0 [1, 1, 1]).sum = 10 := by
  sorry

/-- Mutant: round position and size independently (opens seams at fractional scales). -/
def roundRectBySize (scale120 : Nat) (r : Rect) : Rect :=
  { x := roundDev scale120 r.x, y := roundDev scale120 r.y,
    w := roundDev scale120 r.w, h := roundDev scale120 r.h }

/-- At 1.5x two abutting 1px-wide rects at x = 1px and 2px tear apart. -/
theorem roundRectBySize_seam :
    let a : Rect := { x := 64, y := 0, w := 64, h := 64 }
    let b : Rect := { x := 128, y := 0, w := 64, h := 64 }
    a.right = b.x ∧ (roundRectBySize 180 a).right ≠ (roundRectBySize 180 b).x := by
  sorry

/-- Mutant: focus request that ignores modal traps. -/
def requestNoTrap (s : FocusState) (id : EntityId) : FocusState := { s with owner := some id }

theorem requestNoTrap_escapes :
    let s : FocusState := { owner := some 1, traps := [[1, 2]] }
    FocusState.Confined s ∧ ¬ FocusState.Confined (requestNoTrap s 7) := by
  sorry

/-- Mutant: damage that drops the previous rect instead of taking the union. -/
def damageReplace (_d : Damage) (r : Rect) : Damage := if r.isEmpty then none else some r

theorem damageReplace_uncovers :
    let d : Damage := some { x := 0, y := 0, w := 10, h := 10 }
    d.covers 1 1 = true ∧
      (damageReplace d { x := 50, y := 50, w := 10, h := 10 }).covers 1 1 = false := by
  sorry

/-- Mutant: shelf allocator that forgets to advance `used`. -/
def allocNoAdvance (a : Atlas) (w h : Nat) : Option (Rect × Atlas) :=
  (a.alloc w h).map fun (r, a') =>
    (r, { a' with shelves := a'.shelves.map fun s => { s with used := 0 } })

theorem allocNoAdvance_overlaps :
    ∃ r₁ a₁ r₂ a₂, allocNoAdvance { width := 64, height := 64 } 8 8 = some (r₁, a₁) ∧
      allocNoAdvance a₁ 8 8 = some (r₂, a₂) ∧ r₁.contains 0 0 = true ∧ r₂.contains 0 0 = true := by
  sorry

/-- Without `CollisionFreeOn`, the cache contract is false: a constant hash serves the wrong value. -/
theorem cache_unsound_on_collision :
    let hash : Nat → UInt64 := fun _ => 0
    let c : HashCache Nat := ({} : HashCache Nat).insert hash 1 100
    ¬ CollisionFreeOn hash [1, 2] ∧ c.lookup hash 2 = some 100 := by
  sorry

end LeanUI.Spec.Mutant
