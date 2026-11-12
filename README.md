# `lean-ui`

GPUI-inspired, **100% Lean 4 (`v4.35.0`)** GPU-accelerated desktop UI framework built on [`Th0rgal/lean-sys`](https://github.com/Th0rgal/lean-sys), verified and compiled with [`Th0rgal/turbo-lean`](https://github.com/Th0rgal/turbo-lean) (`LeanNative`), and powering the native Vulkan/Wayland client of [`Th0rgal/orb`](https://github.com/Th0rgal/orb).

## Highlights

- **Pure Lean 4 + Minimal C11 Leaf Shims**: Zero Rust, zero C++, zero WebView/DOM. Talks directly to `libwayland-client`, `Vulkan 1.3` (instanced 2D SDF uber-pipeline + deterministic offscreen PNG readback), and `HarfBuzz` + `FreeType 2` via `<= 220` LOC C11 leaf shims.
- **Kernel-Checked UI Contracts (`LeanUI/Spec/`)**: Plain idiomatic Lean 4 specifications (`0 sorryAx`, `0 native_decide`) audited by `turbo-lean --json audit-spec` covering Flexbox layout determinism, device-pixel rounding, scroll anchoring without layout jumps, dirty-rect damage soundness, and modal focus confinement.
- **`turbo-lean` Native Pipeline**: Sub-second per-declaration verification via warm Zygote workers and unboxed `@[inline, export]` C-ABI hot kernels.

See **[`AGENTS.md`](./AGENTS.md)** for the complete architectural charter, directory layout, formal specification rules, Linux VM pixel-diff verification protocol, and Maxwell multi-worker execution blueprint.
