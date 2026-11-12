import Lake
open Lake DSL

package «lean-ui» where
  version := v!"0.1.0"

@[default_target]
lean_lib «LeanUI» where
  roots := #[`LeanUI]
  leanOptions := #[⟨`warningAsError, true⟩]
  precompileModules := false

/-- Proof shards. Built separately so an open `sorry` never blocks the runtime library. -/
lean_lib «LeanUISpec» where
  roots := #[`LeanUI.Spec.LayoutSpec, `LeanUI.Spec.DamageSpec, `LeanUI.Spec.FocusSpec, `LeanUI.Spec.AtlasSpec, `LeanUI.Spec.MutantSuite]
  precompileModules := false
