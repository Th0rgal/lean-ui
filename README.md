# `lean-ui`

GPUI-inspired, **100% Lean 4 (`v4.35.0`)** GPU-accelerated desktop UI framework built on [`Th0rgal/lean-sys`](https://github.com/Th0rgal/lean-sys), verified and compiled with [`Th0rgal/turbo-lean`](https://github.com/Th0rgal/turbo-lean) (`LeanNative`), and powering the native Vulkan/Wayland client of [`Th0rgal/orb`](https://github.com/Th0rgal/orb).

## Highlights

- **Pure Lean 4 + Minimal C11 Leaf Shims**: Zero Rust, zero C++, zero WebView/DOM. Talks directly to `libwayland-client`, `Vulkan 1.3` (instanced 2D SDF uber-pipeline + deterministic offscreen PNG readback), and `HarfBuzz` + `FreeType 2` via `<= 220` LOC C11 leaf shims (`c/lean_ui_wayland.c`, `c/lean_ui_vulkan.c`, `c/lean_ui_text.c`).
- **Kernel-Checked UI Contracts (`LeanUI/Spec/`)**: Plain idiomatic Lean 4 specifications (`0 sorryAx`, `0 native_decide`) audited by `turbo-lean --json audit-spec` covering Flexbox layout determinism, device-pixel rounding, scroll anchoring without layout jumps, dirty-rect damage soundness, modal focus confinement, and shelf-packed glyph atlas non-overlap.
- **`turbo-lean` Native Pipeline**: Sub-second per-declaration verification via warm Zygote workers and unboxed `@[inline, export]` C-ABI hot kernels.

## Architecture & Runtime Modules

| Layer | Files | Responsibility |
| :--- | :--- | :--- |
| **Core & Kernels** | `lean/LeanUI/Defs.lean`, `lean/LeanUI/Kernel.lean` | Logical `Sub` (`1/64` px) & `scale120` geometry, Flexbox distribution/shrink/redistribution, outward damage rounding, hit-testing, modal focus traps, and shelf-packed glyph atlas allocation |
| **Formal Specs** | `lean/LeanUI/Spec/{LayoutSpec,DamageSpec,FocusSpec,AtlasSpec,MutantSuite}.lean` | Kernel-checked theorems + two-sided mutant refutation witnesses (`0 sorryAx`, `0 native_decide`) |
| **C11 Leaf Shims** | `c/lean_ui.h`, `c/lean_ui_{wayland,vulkan,text}.c`, `lean/LeanUI/FFI.lean` | 23 `@[extern "lean_ui_*"]` primitives for Wayland wire marshaling/event pumping, XKB keymap/compose, `dlopen`/`dlsym` + 6-arg `UInt64` call bridge, and Fontconfig/FreeType/HarfBuzz shaping & rasterization |
| **Wayland Wire & Input** | `lean/LeanUI/Wayland.lean` | Binary `wl_interface` builders (`xdg-shell`, `wp-fractional-scale-v1`, `wp-viewporter`, `zwp-text-input-v3`), request marshaling, event decoding, XKB UTF-8 key translation, atomic IME batching, and headless fallback |
| **Text & Glyph Atlas** | `lean/LeanUI/Text.lean` | Font metrics, HarfBuzz shaped-run decoding, FreeType R8/BGRA8 glyph rasterization, and multi-page shelf-packed `GlyphAtlasCache` |
| **Vulkan & SDF Scene** | `lean/LeanUI/Vulkan.lean`, `shaders/scene_sdf.glsl` | Dynamic `libvulkan.so.1` loader, 80-byte `GpuPrimInstance` staging, analytical SDF rounded-rect / border / drop-shadow / glyph / clip / layer pipeline, and deterministic RFC 1950/1951 PNG encoder |
| **Runtime & Canary** | `lean/LeanUI/Runtime.lean` | Single-owner `RuntimeState`, `needsRedraw`-gated frame scheduler (`0` redraws when quiescent), and `--headless-golden <output.png>` CLI runner |

## Verification Quickstart

```bash
# 1. Build pure LeanUI + LeanUISpec libraries with turbo-lean
turbo-lean --no-daemon --no-telemetry --max-memory-mb 6144 build LeanUI LeanUISpec --project-dir lean

# 2. Audit formal specification shards (0 sorryAx, 0 native_decide)
turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean

# 3. Compile C11 leaf shims (each <= 220 LOC, -Wall -Wextra -Werror)
for f in c/lean_ui_wayland.c c/lean_ui_vulkan.c c/lean_ui_text.c; do
  clang -std=gnu11 -O2 -Wall -Wextra -Werror -fPIC \
    -I"$(lean --print-prefix)/include" $(pkg-config --cflags freetype2 harfbuzz fontconfig wayland-client xkbcommon) \
    -c "$f" -o "${f%.c}.o"
done
```

See **[`AGENTS.md`](./AGENTS.md)** for the complete architectural charter, directory layout, formal specification rules, Linux VM pixel-diff verification protocol, and Maxwell multi-worker execution blueprint.
