# `lean-ui` — Architectural Charter & Maxwell Campaign Blueprint

**Repository**: `https://github.com/Th0rgal/lean-ui`
**Ecosystem**: `Th0rgal/lean-ui` ⟷ `Th0rgal/lean-sys` ⟷ `Th0rgal/turbo-lean` (`LeanNative`) ⟷ `Th0rgal/orb`

---

## 1. Mission & Positioning

`lean-ui` is a **100% Lean 4 (`v4.35.0`), GPU-accelerated, hybrid declarative/immediate UI framework** inspired by Zed's GPUI, built on [`Th0rgal/lean-sys`](https://github.com/Th0rgal/lean-sys) and compiled/verified end-to-end with [`Th0rgal/turbo-lean`](https://github.com/Th0rgal/turbo-lean) (`LeanNative` C-ABI / SIMD / GPU lowering).

Its flagship production consumer is **`orb-desktop`** ([`Th0rgal/orb`](https://github.com/Th0rgal/orb)), replacing the Linux `GTK4 + WebKitGTK 6.0` wrapper (`linux_shell/main.c`) + bundled `SolidJS` WebView runtime with a native Wayland + Vulkan desktop binary that achieves:

1. **Pixel-perfect visual & interactive parity** with Orb Desktop across dark & light themes, HiDPI scale factors (`1.0x`, `1.5x`, `2.0x`), keyboard navigation, streaming transcripts, virtualized turns, code blocks, unified/split diffs, math (`KaTeX` parity), `Mermaid` diagrams, `SearchDialog`, `Settings`, `SideQuestionPanel`, modals, and composer workflows.
2. **Order-of-magnitude systems improvements** verified on real workloads (`(work_units, error_count)` emitted on every benchmark run): cold start to first interactive frame, full process-tree peak/steady RSS, 1,000-turn transcript open latency, 120 Hz scroll & SSE token-streaming p50/p99 frame times, and `0.0%` unfocused idle CPU.
3. **Kernel-checked formal UI contracts** (`0 sorryAx`, `0 native_decide`, plain idiomatic Lean 4 under `formal-specs` Summit criteria + Human Spec Cards) composing directly with `Orb/Kernel.lean`, `Orb/Scroll.lean`, `Orb/Stream.lean`, `Orb/Transcript.lean`, and `OrbClient/Reducers.lean` — eliminating the JS $\leftrightarrow$ WASM serialization bridge.

---

## 2. Non-Negotiable Engineering Rules

1. **Pure Lean 4 + Minimal C11 Leaf Shims (`0` `.rs`, `0` `.cpp`, `<= 220` LOC per `.c` file)**:
   - Zero Rust, C++, Objective-C++, Qt, GTK, Electron, or WebKit dependencies inside `lean-ui`.
   - Interface directly with stable C-ABI system libraries via thin `dlopen` / `@[extern]` C11 leaf shims (`<= 220` LOC each, `-std=gnu11 -O2 -Wall -Wextra -Werror`, matching `orb`'s CI invariant):
     - `c/lean_ui_wayland.c`: `libwayland-client`, `xdg-shell`, `wp-fractional-scale-v1`, `wp-viewporter`, `zwp-text-input-v3` (fcitx5 dead-key/IME), `libxkbcommon`, Wayland clipboard/data-device, cursor shapes, and XDG Desktop Portal D-Bus file chooser (`flea`).
     - `c/lean_ui_vulkan.c`: Vulkan 1.3 (`libvulkan.so.1`) swapchain, dynamic rendering, push descriptors, instanced 2D SDF uber-pipeline, plus deterministic offscreen headless RGBA/PNG readback (`--headless-golden`) for automated pixel-diff verification. Keep `LeanUI.Scene` backend-agnostic so Apple Metal (`LeanNative/Backend/MetalLower.lean`) plugs into the exact same `SceneBatch` IR.
     - `c/lean_ui_text.c`: HarfBuzz (`libharfbuzz`) + FreeType 2 (`libfreetype`) + Fontconfig (`libfontconfig`) glyph shaping & rasterization into a shelf-packed R8/RGBA8 GPU glyph & color-emoji atlas with subpixel positioning.
   - Reuse `Th0rgal/lean-sys` (`LeanSys.{Par,Db,Os,Web,Scan,Gate}`) for event loops, epoll/timers, POSIX sockets, concurrency, and shared Layer-0 contracts.

2. **`turbo-lean` First & Memory-Bounded Inner Loops (`lean-builds`)**:
   - Check `turbo-lean --version` and `turbo-lean --help` before invoking flags. Never run unguarded `lake build`, `elan`, or `cp -r .lake`.
   - Ship `flake.nix` with the same `lake`/`leanc`/`elan` guard shims and `TURBO_LEAN_EMIT_C=1` + `clang`/`lld` setup as `orb/flake.nix`.
   - Bound concurrency by RAM (`--jobs 1 --max-memory-mb 6144` on 8 GiB scopes, `--jobs 2` on 16 GiB). Use `turbo-lean check <file.lean> --decl <Full.DeclName> --max-memory-mb 6144 --no-auto-worktree-link` for sub-second shard iteration, and run full kernel + `turbo-lean --json audit-spec` + `#print axioms` gates at wave integration.
   - Decouple lightweight `Defs.lean` / `Types.lean` headers from proof shards and widget aggregators so leaf edits never trigger full-cone rebuilds.

3. **Plain Idiomatic Lean Specifications & Summit Criteria (`formal-specs`)**:
   - Write plain `def`, `structure`, `inductive`, and `theorem` declarations directly over domain types in `lean/LeanUI/Spec/` (`0 import Lean`, `0 sorryAx`, `0 native_decide`). Do **not** depend on retired `Th0rgal/lean-specs` or ceremonial wrapper structs.
   - Satisfy all four Summit criteria:
     1. **Simplicity**: Specify observable layout/scene/scroll projections and explicit error rollback (`s' = s`), never `evalSpec := evalImpl` tautologies. Preserve natural diagonal `rfl` proofs without artificial arithmetic detours.
     2. **No Overlap**: Keep core contract conjuncts logically independent (move derived facts to `theorem` corollaries), partition outcome branches disjointly, use frame lemmas on orthogonal slices, and use conservation/relational laws on legitimately shared state (e.g. glyph atlas shelf occupancy, focus owner).
     3. **Scoped Completeness**: Use per-trace `CollisionFreeOn hash traceKeys` whenever caching layouts/glyphs over finite hashes (`|Dom| > |Cod|`), and separate raw recognizers from post-extractor TCB inputs (`extractInTcb`).
     4. **Human Spec Cards & Two-Sided Mutant Regressions**: Accompany every top-level contract with a concise Human Spec Card (`Intent`, `Requirement mapping`, `Reachable positive trace`, `Proved`, `Counterexample/mutant-refuted`, `Unchecked/TCB`, `Outside scope`) and two-sided mutant refutation witnesses (`negWitness`) verified by `turbo-lean --json audit-spec --require-nonempty`.

4. **End-to-End Amdahl & Ablation Ratchet (`ΔE2E >= 1%` or Delete)**:
   - Every cache tier (`LayoutCache`, shaped-run cache, damage rect culling) or `@[simd]` / `LeanNative` kernel must report non-zero hit counts on real Orb transcripts and measurably improve end-to-end frame time, RSS, or startup ($\ge 1\%$). Delete non-movers immediately to keep $\Delta\text{LOC}$ minimal.

---

## 3. Architecture Layout (`LeanUI`)

```text
lean-ui/
├── AGENTS.md                  # This charter & Maxwell wave protocol
├── CLAUDE.md -> AGENTS.md     # Symlink for Claude / OpenCode harnesses
├── README.md                  # Architecture overview, quickstart & Spec Cards index
├── flake.nix                  # Nix devShell & package with turbo-lean shims + Vulkan/Wayland/HarfBuzz
├── turbo-lean.toml            # Fail-closed audit-spec anti-reward-hacking policy
├── c/                         # C11 leaf shims (<= 220 LOC each, 0 C++/Rust)
│   ├── lean_ui_wayland.c      # Wayland + xdg-shell + fractional-scale + text-input-v3 + xkbcommon
│   ├── lean_ui_vulkan.c       # Vulkan 1.3 swapchain + 2D SDF instanced pipeline + offscreen PNG dump
│   └── lean_ui_text.c         # HarfBuzz + FreeType + Fontconfig shaping & atlas upload
├── shaders/
│   └── scene_sdf.glsl         # Compiled to SPIR-V: rounded rects, 1px borders, shadows, clips, glyphs
├── lean/
│   ├── lean-toolchain         # leanprover/lean4:v4.35.0 (aligned with orb & lean-sys)
│   ├── lakefile.lean          # Single-line moreLinkArgs, warningAsError := true
│   └── LeanUI/
│       ├── Defs.lean          # Frozen core geometry, style, scene, event & entity types (0 import Lean)
│       ├── Kernel.lean        # Unboxed @[inline, export] layout, hit-test, scroll & damage kernels
│       ├── Spec/              # Disjoint formal proof shards (1 owner per shard during Maxwell waves)
│       │   ├── LayoutSpec.lean    # Flexbox conservation, min/max clamping, device-pixel rounding
│       │   ├── DamageSpec.lean    # Dirty-rect union soundness & unfocused 0-redraw quiescence
│       │   ├── FocusSpec.lean     # Single focus owner, modal trap confinement, quiet 1px border step
│       │   ├── AtlasSpec.lean     # Shelf-allocator non-overlap & per-trace CollisionFreeOn cache soundness
│       │   └── MutantSuite.lean   # Two-sided negative witnesses & executable regression suite
│       ├── Style.lean         # Tailwind/Cursor-style declarative builders & light/dark theme tokens
│       ├── Layout.lean        # Flexbox + inline text run breaker + content-hashed LayoutCache
│       ├── Scene.lean         # Z-ordered primitive batching & scissor stack
│       ├── Runtime.lean       # Single-owner state store, Wayland frame scheduler, portal/clipboard I/O
│       └── Widgets/           # Disjoint reusable widget modules
│           ├── VirtualList.lean   # Variable-height virtualized list anchored via Orb/Scroll
│           ├── RichText.lean      # Markdown, syntax-highlighted CodeBlock, inline copy, KaTeX math boxes
│           ├── DiffViewer.lean    # Unified & split diff viewer
│           ├── MermaidSvg.lean    # Native SVG / diagram layout & vector tile renderer
│           ├── Overlays.lean      # Dialog, Field, Select, Tooltip, Toast, SearchDialog
│           └── Composer.lean      # Multi-line editor, undo/redo, IME preedit, attachments, drag-drop
└── scripts/
    ├── capture_orb_goldens.sh # Captures reference PNGs + baseline metrics from WebKitGTK orb-desktop in VM
    ├── diff_goldens.py        # Computes pixel-diff heatmaps, layout box deltas & SSIM (>= 0.985 gate)
    └── bench_desktop.sh       # N >= 20 runs emitting (work_units, error_count, cold_ms, rss_mib, p50_ms, p99_ms)
```

---

## 4. Maxwell Wave Execution & Parallelization Protocol

When executing this build as an autonomous campaign (`maxwell` + `orchestration` + `lean-builds` + `managed-compute`):

1. **Freeze Interfaces First ("Build the Lever Before Fan-Out")**:
   - The coordinator freezes `LeanUI/Defs.lean`, `LeanUI/Kernel.lean` signatures, C-ABI headers, and the Golden/Benchmark Judge (`scripts/diff_goldens.py`, `scripts/bench_desktop.sh`) **before** fanning out parallel workers.
   - Run an **early self-contained adversarial consultation** (~10–15 min mark once `Defs.lean` + `Spec/` headers are drafted) across $\ge 2$ distinct frontier model families (`consult_model` / distinct-track `writer: false` reviewers; log requested vs. effective model, degrade honestly if a provider is down, and never steer a consultant mid-synthesis) to attack vacuous premises, C-ABI lifetimes, and Wayland/HiDPI edge cases.

2. **Preload the Cone Once & Isolate Worktrees**:
   - Check fixed fleet (`ashur`, `babylon`, `nippur`, `uruk`, `lagash` — never `nimrud` or blind `"auto"`) or provision a warm `boost` (`boost-32vcpu-96gb` with `orb-cow-worktree`) / `boat:xlarge` golden snapshot (`lean-ui-<sha7>-warm`, waiting until `list_managed_snapshots` reports `ready`).
   - **One file, one owner**: Maintain an explicit open-file ownership ledger `(file, owner_mission_id, branch, last_pushed_sha)` on every sweep. Candidate writers **never** edit `Spec/` judges or `diff_goldens.py`.
   - Parallelize cleanly across disjoint waves:
     - **Wave A (Foundation & Proofs — parallel disjoint shards)**:
       - Shard A1: `LayoutSpec.lean` + `DamageSpec.lean`
       - Shard A2: `FocusSpec.lean` + `AtlasSpec.lean` + `MutantSuite.lean`
       - Shard A3: `c/lean_ui_wayland.c` + `Runtime.lean`
       - Shard A4: `c/lean_ui_vulkan.c` + `shaders/scene_sdf.glsl` + `Scene.lean`
       - Shard A5: `c/lean_ui_text.c` + HarfBuzz/FreeType atlas + `Layout.lean`
     - **Wave B (1-Unit Canary -> Widget Shards)**:
       - Complete **1 end-to-end canary view** (Window + Theme + Sidebar + Headless/VM PNG diff) and verify through the independent oracle before fanning out widget workers across `VirtualList.lean`, `RichText.lean`, `DiffViewer.lean`, `MermaidSvg.lean`, `Overlays.lean`, and `Composer.lean`.
     - **Wave C (`Th0rgal/orb` Native Desktop Integration)**:
       - Wire `lean-ui` into `orb` (`OrbDesktop/` consuming `OrbClient/Reducers.lean`, `Orb/Kernel.lean`, `Orb/Scroll.lean`, `Orb/Stream.lean`, `Orb/Transcript.lean`, and `OrbLocald` directly in Lean 4).
     - **Wave D (Linux VM Pixel-Perfect Loop, Interactive QA & Certified Benchmarks)**:
       - Run inside an isolated Linux Wayland VM (QEMU NixOS VM or managed Linux VM running Hyprland/headless Wayland + Vulkan + `grim`).
       - Iterate until **every canonical screen** (Inbox, Streaming Transcript, Code/Diff/Math/Mermaid, SearchDialog, Settings tabs, Approvals/Modals, SideQuestionPanel, Dark & Light, `1x` & `2x` HiDPI) hits **SSIM $\ge 0.985$** with zero layout jumps, and every keyboard/pointer/IME/clipboard/single-instance interaction passes end-to-end.

3. **Kernel & Measurement Oracles (Never Timebox `PASS`)**:
   - Every worker pushes verified commits before VM TTL expiry (`git push` immediately on coordinator integration).
   - Final acceptance requires green outputs on **all** mechanical gates:
     1. `turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean` (`"ok": true`, `0` sorryAx, `0` native_decide)
     2. `wc -l c/*.c` confirming every C file is `<= 220` LOC with `0` `.rs`/`.cpp` files
     3. Linux VM golden suite (`scripts/diff_goldens.py`) passing `SSIM >= 0.985` across Dark/Light & `1x`/`2x`
     4. Linux VM benchmark receipt (`scripts/bench_desktop.sh`, $N \ge 20$) showing verified `(work_units, error_count == 0)` improvements over `GTK4 + WebKitGTK`
     5. All `Th0rgal/orb` CI checks green (`orb-core-test`, `orb-locald-test`, `orb-spec-runner`, `turbo-lean --json audit-spec lean/Orb/Spec.lean`, C shim LOC gate) and PR opened on `github.com/Th0rgal/orb` with Human Spec Cards, benchmark table, and Before/After Linux VM screenshots.
