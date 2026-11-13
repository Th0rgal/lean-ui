import Lake
open Lake DSL

package «lean-ui» where
  version := v!"0.1.0"
  moreLinkArgs := #["-lwayland-client", "-lxkbcommon", "-lfreetype", "-lharfbuzz", "-lfontconfig", "-ldl"]

@[default_target]
lean_lib «LeanUI» where
  roots := #[`LeanUI]
  leanOptions := #[⟨`warningAsError, true⟩]
  precompileModules := false

/-- Proof shards. Built separately so an open `sorry` never blocks the runtime library. -/
lean_lib «LeanUISpec» where
  roots := #[`LeanUI.Spec.LayoutSpec, `LeanUI.Spec.DamageSpec, `LeanUI.Spec.FocusSpec, `LeanUI.Spec.AtlasSpec, `LeanUI.Spec.MutantSuite]
  precompileModules := false

/-- Native Wayland + Vulkan + HarfBuzz/FreeType runtime library (links against `c/lean_ui_*.o`). -/
lean_lib «LeanUIRuntime» where
  roots := #[`LeanUI.FFI, `LeanUI.Wayland, `LeanUI.Text, `LeanUI.Vulkan, `LeanUI.Runtime, `LeanUI.Canary]
  leanOptions := #[⟨`warningAsError, true⟩]
  precompileModules := false
