import LeanUI.Kernel
/-!
# FocusSpec — single focus owner, modal trap confinement, hit-test routing

"At most one owner" holds by construction (`owner : Option EntityId`) and is not restated.
-/
namespace LeanUI.Spec
open FocusState

/-- Granted branch: the owner changes, the trap stack is framed. -/
theorem request_granted (s : FocusState) (id : EntityId) (h : s.admits id = true) :
    (s.request id).owner = some id ∧ (s.request id).traps = s.traps := by
  sorry

/-- Refused branch: explicit rollback. -/
theorem request_refused (s : FocusState) (id : EntityId) (h : s.admits id = false) :
    s.request id = s := by
  sorry

theorem request_confined (s : FocusState) (id : EntityId) (h : Confined s) :
    Confined (s.request id) := by
  sorry

/-- Opening a modal always establishes confinement, whatever held focus before. -/
theorem pushTrap_confined (s : FocusState) (ids : List EntityId) : Confined (s.pushTrap ids) := by
  sorry

theorem popTrap_confined (s : FocusState) : Confined s.popTrap := by
  sorry

theorem blur_confined (s : FocusState) : Confined s.blur := by
  sorry

/-- A hit is always a region that contains the point. -/
theorem hitTest_sound (regions : List (EntityId × Rect)) (px py : Int) (id : EntityId)
    (h : hitTest regions px py = some id) :
    ∃ r, (id, r) ∈ regions ∧ r.contains px py = true := by
  sorry

/-- A miss means no region contains the point. -/
theorem hitTest_none_iff (regions : List (EntityId × Rect)) (px py : Int) :
    hitTest regions px py = none ↔ ∀ e, e ∈ regions → e.2.contains px py = false := by
  sorry

/-- Paint order decides: the last-painted containing region wins. -/
theorem hitTest_topmost (regions : List (EntityId × Rect)) (id : EntityId) (r : Rect)
    (px py : Int) (h : r.contains px py = true) :
    hitTest (regions ++ [(id, r)]) px py = some id := by
  sorry

end LeanUI.Spec
