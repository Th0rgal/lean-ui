# Current-state successor ledger — not historical restoration

## Historical transfer: BLOCKED

The historical 296-line W0 ledger is absent from this workspace and unverified.
This document is a CURRENT-STATE SUCCESSOR, not a byte-faithful restoration.
Original receipt-only commits `6ecb56484293b71be48131de6de1d288d148b50d`
and `8b85b0880fc5e47c07dc176d00b1adec9386c6ec` were not pushed. The source VM
was destroyed before independent payload validation. Exact historical restoration
remains pending verified transfer. No historical ledger preservation is claimed.

## Identity and ownership

- Worker mission: `b821a83b-64d0-40b4-b27c-480b591c9133`.
- Controller mission: `7245f457-6a8a-44d8-95dc-9a0ae4e2d9ea`.
- Requested and effective model: `builtin/smart`; backend: `opencode`.
  Effective identity verified through the live process and Core mission record.
- Core project: `health-manager`; track: empty.
- Worker owns only `lean/LeanUI/Spec/FocusSpec.lean`,
  `lean/LeanUI/Spec/MutantSuite.lean`, and this successor ledger.
- Local branch: `reconstructed-spec-kernel`; last pushed SHA: none.
- No trusted publication relay is available. No pushed progress is claimed.

## Reproducible base and tool provenance

- Public lean-ui base: `0c7f9e1d971f6b0d096e574124dad6cc3391d73c`.
- Public turbo-lean source: `bca79f34ac249d0ea7dfb9b0fd9a9c04b54a2ece`.
  Source tree was clean; Rust build used `cargo build --release --locked --jobs 4`.
- Produced executable SHA256:
  `f9be258516fc27cdacae8638c70a1dedd00dac1f70d442ba77489fcfe7e4640e`.
  System `/opt/orb/bin/turbo-lean` was not overwritten.
- Lean toolchain: `leanprover/lean4:v4.35.0`.
- Pristine-base `LeanUI LeanUISpec` build: exit 0.
- Exact mandatory audit on the pristine base: exit 0, `ok: true`, 72/72 tight.
- `turbo-lean build` has no `--jobs` option at this tool SHA; build concurrency
  used `LEAN_NUM_THREADS=4`. No unsupported flag or wrapper was introduced.

## Rejected reconstruction and transport evidence

- Original gzip/base64 transport failed integrity verification and was abandoned
  by controller decision. Original compressed-payload checksum was not verified.
- Controller supplied three exact unified-diff blocks for content-based
  reconstruction on a fresh pinned-base clone. Apply checks passed; four files
  gained 134 lines: Kernel 16, FocusSpec 22, LayoutSpec 60, MutantSuite 36.
- All four reconstructed blob prefixes matched the supplied diff indices.
  This is strong content evidence, not proof of original commit/tree equality.
- Reconstructed local commit:
  `962444de04c7717b1768887a0ce94419648c2ac6`.
  Tree: `277afe1c3e2265b69d1bcf571f8809d09951daae`.
- Build exit 0; exact mandatory audit exit 1, `ok: false`, 91/93 tight.
  Findings: `LeanUI.Spec.focusBorder_geometry`
  (`trivial_tautological_postcondition`) and
  `LeanUI.Spec.Mutant.focusAlwaysDamaged_negWitness`
  (`stubbed_definition_in_spec`: ignored `_before` and `_after` parameters).
- Controller REJECTED this candidate for gate 1. Build success is not acceptance.
  Failed commit and raw audit evidence remain preserved unchanged.

## Separate remediation: scoped MECHANICAL GATE 1 PASS

- Local remediation commit:
  `aa7969a6a9e27474018eabf1404edba772f8a15e`.
  Tree: `c889ba3ccab093d9aa9c4e703da39cc1d9e8a328`.
- Only FocusSpec and MutantSuite changed. The geometry obligation now states
  rendered-border injectivity across focus state, rectangle, and color.
  The always-damaged countermodel is explicitly state-independent; universal
  unchanged-state rejection and changed-state agreement witnesses remain visible.
- Build exit 0; exact mandatory audit exit 0, `ok: true`, 94/94 tight,
  zero trivial/vacuous specifications and no stub-definition findings.
- `#print axioms` checks for all 76 public spec theorems: exit 0, dependencies
  limited to `propext`, `Quot.sound`, and `Classical.choice`, or none.
- Independent gate mission `d43fcbc3-946f-4341-be10-0bae98ffcd43` reran the
  exact audit: exit 0, 94/94 tight; clean independent build compiled all 8 modules.
  Full artifact hashes were checked; forbidden axioms and `native_decide`: zero.
- Controller read the independent FINAL raw receipts and accepted the content
  remedy. Scoped decision: MECHANICAL GATE 1 PASS for exact remediation commit
  `aa7969a6a9e27474018eabf1404edba772f8a15e`, tree
  `c889ba3ccab093d9aa9c4e703da39cc1d9e8a328` only.
- Audit witness labels `heuristic_unverified` are not semantic or visual proof.
  This decision is not all-campaign PASS, row closure, or pushed progress.
  No policy, auditor, judge, or kernel changes were made by this remediation.
- C gate is absent: independent `wc -l c/*.c` exited 1 because no matching C
  source files exist. Visual, benchmark, and Orb CI gates remain unrun.

## REVIEW_1 rows 1 & 21 closure: ACCEPTED (`9fbc5aba7021784e0d678b810f86059ae765868a`)

- Local commit: `9fbc5aba7021784e0d678b810f86059ae765868a`.
- Closed remaining `REVIEW_1.md` rows 1 (`flexShrink`, `flexRedistribute`, `flexMainClamped`, `flexMain_fills_clamped`, `flexMain_clamp_loses_space_negWitness`, `flexNoShrink_overflows_negWitness`) and 21 (`Atlas.reset`, `Atlas.allocPadded`, `Atlas.allocPages`, `allocPadded_guard_owns`, `allocPadded_disjoint_guard`, `allocPages_live`, `allocPages_sound`, `allocUnpadded_abuts_negWitness`, `resetNoRewind_exhausts_negWitness`, `allocSinglePage_full_negWitness`), completing all 26 `REVIEW_1.md` rows alongside rows 24 and 25 from `aa7969a6a9e27474018eabf1404edba772f8a15e`.
- Independent gate worker `b23d68d5-f3f5-4345-929c-4c30f8dbe13f` verified cold `turbo-lean build LeanUI LeanUISpec --project-dir lean` (`exit 0`, 8 modules compiled) and `turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean` (`exit 0`, `ok: true`, `124/124` tight specs, `0` vacuous, `0` trivial, `0` sorryAx, `0` native_decide).
- Status: ACCEPTED (`kernel-checked`). Core spec & ABI freeze status is now `FROZEN` (all 26 `REVIEW_1.md` rows closed).

## Wave 1 C11 leaf shims & `LeanUI.FFI`: REJECTED (`92532705`) -> ACCEPTED (`392ad740`)

- Worker mission: `54601125-4a46-4713-ae9c-dc6ba42ba84c` (model: `builtin/smart`, backend: `opencode`, branch: `w1-c-shim`).
- Initial commit `925327050ed4e0541a5afda816ecd58359d5a501` was REJECTED by independent gate worker `4b14bd7b-4d22-40ab-a461-2ea05b303e25` on 4 blocking defects: (1) `lean/LeanUI/FFI.lean` contained pure-Lean `throw` stubs rather than `@[extern "lean_ui_*"]` bindings and `memfd` had signature `UInt32 → IO UInt64` instead of `UInt32 → IO UInt32`; (2) `c/lean_ui_wayland.c` had 4 memory/protocol safety bugs (`lean_ui_wl_make_interface` unchecked descriptor bounds, `lean_ui_wl_marshal` unchecked `args`/`blob` bounds, `lean_ui_wl_pump` `wl_display_cancel_read` without held `prepare_read` lock on `dispatch_pending < 0`, and `lean_ui_xkb_keymap` `size == 0` / non-NUL-terminated `mmap` string read); and (3) `lean/LeanUI.lean` imported `LeanUI.FFI`, causing `turbo-lean` pure-cone splitter rejection unless worked around. Rejected commit `925327050ed4e0541a5afda816ecd58359d5a501` is preserved in history.
- Remediation commit: `392ad7402db131b1e78aefd4391c39663c12d379` (tree `fc08dfe15381f2bc67c900d954a0542b831bac36`) on `w1-c-shim`.
  - Replaced all stubs in `lean/LeanUI/FFI.lean` with all 23 `@[extern "lean_ui_*"] opaque` declarations matching `c/lean_ui.h` (`memfd : UInt32 → IO UInt32`) and restored `lean/LeanUI.lean` to `9fbc5aba` so the pure proof cone stays disjoint from FFI leaf modules.
  - Hardened `c/lean_ui_wayland.c` (`rd_cstr`/`parse_msgs` bounds checks, `lean_ui_wl_marshal` `args` & `blob` bounds checks, `lean_ui_wl_pump` `prep` lock guard, `lean_ui_xkb_keymap` `size == 0` guard + `xkb_keymap_new_from_buffer`).
- Independent gate worker `4b14bd7b-4d22-40ab-a461-2ea05b303e25` verified `392ad7402db131b1e78aefd4391c39663c12d379`:
  - Mechanical Gate 2 (`wc -l c/*.c`): `198 c/lean_ui_text.c`, `71 c/lean_ui_vulkan.c`, `218 c/lean_ui_wayland.c` (`487` total, all `<= 220` LOC; `0` `.rs`/`.cpp`) — **PASS** (`executable-reproduced`).
  - All 4 C safety fixes in `c/lean_ui_wayland.c` and all 23 `@[extern "lean_ui_*"] opaque` declarations in `lean/LeanUI/FFI.lean` verified via runtime execution test linked against `c/lean_ui_*.c` — **PASS** (`executable-reproduced`).
  - Cold `turbo-lean build LeanUI LeanUISpec --project-dir lean` (`8` modules, `exit 0`) and `turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean` (`124/124` tight, `exit 0`) — **PASS** (`kernel-checked`).

## Wave 1 Pure UI Stack (`w1-pure`) & Native Runtime (`w1-runtime`): ACCEPTED & INTEGRATED

- **Wave 1 Shard A (`w1-pure` — `Style.lean`, `Layout.lean`, `Scene.lean`, `LeanUI.lean`)**:
  - Worker mission: `55db904e-593e-46ea-bd32-568a22270124` (branch: `w1-pure`, base: `dc5eca9a4889b33d91bad21bb4efce16a21d95ba`).
  - Initial candidate `b1ce296ea23580c6bef1f2ee03bde9a7e0f2e534` and intermediate fix `cf83d04bdcc55c38e24c7848414538bc4277a30e` were REJECTED (signed `Int` layout origin coordinates for scrolled children and paint-order `hitRegionsSub`/`hitRegionsDev` preservation for `Kernel.hitTest` `foldl`). Both rejected commits remain preserved in git history.
  - Accepted commit: `e2d4eb2ff8f2161d94e19aa353e2563f58e953ec` (tree `4bd7ffd236e6758555b0c953866bb4abb5570063`) — **ACCEPTED** (`kernel-checked`).
- **Wave 1 Shard B (`w1-runtime` — `Wayland.lean`, `Text.lean`, `Vulkan.lean`, `Runtime.lean`, `shaders/scene_sdf.glsl`, `lean/lakefile.lean`, `flake.nix`, `README.md`)**:
  - Worker mission: `54601125-4a46-4713-ae9c-dc6ba42ba84c` (branch: `w1-runtime`, parent: `dc5eca9a4889b33d91bad21bb4efce16a21d95ba`).
  - Accepted commit: `a2d445297f9a787afdbb5d2702b0e89873308789` (tree `21400b174fa9b9286bbacc3c94ca05906e016620`) — **ACCEPTED** (`executable-reproduced` + `kernel-checked`).
- **Unified Wave 1 Integration Commit**:
  - Executor mission: `49a57282-996d-4ab9-a0e1-d8605fdb4c78` (branch: `w2-canary`).
  - Integration commit: `a13c12d5376362f6e1fdd1320f2c56f93be40a0b` (tree `2d48f8479f50e819a216272718dca415049625fe`, parent `a2d445297f9a787afdbb5d2702b0e89873308789`) applying `w1_pure_v3.patch` (`e2d4eb2ff8f2161d94e19aa353e2563f58e953ec`) cleanly atop `a2d445297f9a787afdbb5d2702b0e89873308789`.

## Wave 2 End-to-End 1-Unit Canary Screen (`LeanUI/Canary.lean`) & Multi-Page Glyph Fix: ACCEPTED (`w2-canary`)

- Executor mission: `49a57282-996d-4ab9-a0e1-d8605fdb4c78` (model: `builtin/smart`, backend: `opencode`, branch: `w2-canary` / `main`).
- Wave 1 integration parent commit: `a13c12d5376362f6e1fdd1320f2c56f93be40a0b` (tree `2d48f8479f50e819a216272718dca415049625fe`).
- Wave 2 Canary commit: `05157805788c07a669060fda07c20d04fffafc10` (tree `dcefc8a064ba3e286a262c0483b84ca0fc5160c0`, parent `a13c12d5376362f6e1fdd1320f2c56f93be40a0b`, code/config tree `lean/` identical to `8cae25f27159cafc593b90d2f155568a1bcdb63a`):
  - `lean/LeanUI/Text.lean` (`layoutTextRun`): when `entry.page > 0 && !entry.isColor`, emit `.mask entry.page entry.uv dst color` so multi-page grayscale glyph atlases sample the exact page `entry.page` in `Vulkan.rasterizeScene`.
  - `lean/LeanUI/Canary.lean`: implements the 1-unit Orb Desktop Canary screen composing `LeanUI.Style` (`Theme.dark` / `Theme.light`, `Palette`, `BoxStyle`, `TextStyle`), `LeanUI.Layout` (`LayoutNode`, `ComputedBox`, `layoutTree`, Flexbox row/column + scroll container + inline text wrapping), `LeanUI.Scene` (`WidgetNode`, `SceneOutput`, `buildScene`, `hitTest`, `focusOrder`, `Kernel.focusBorder`), `LeanUI.Text` (`GlyphAtlasCache`, `layoutTextRun`), and `LeanUI.Runtime` (`RuntimeState`, `stepFrame`, `parseRuntimeArgs`, `--headless-golden <output.png>`). Exposes `buildCanaryWidgetTree`, `renderCanaryFrame`, and `main (args : List String) : IO UInt32`.
  - `lean/lakefile.lean`: added `` `LeanUI.Canary `` to `LeanUIRuntime` roots while preserving pure verification cone hygiene (`lean/LeanUI.lean` imports only `Defs`, `Kernel`, `Style`, `Layout`, `Scene`).
- Independent gate worker `a5ae0d02-fa19-45b9-93e5-03f4eedbde4c` verified all 6 mechanical gates on `05157805788c07a669060fda07c20d04fffafc10` — **ACCEPTED** (`kernel-checked` + `executable-reproduced`):
  1. Cold 11-module `turbo-lean --no-daemon --no-telemetry --max-memory-mb 6144 build LeanUI LeanUISpec --project-dir lean`: `0 reused, 0 cached, 11 compiled`, `exit 0` (`kernel-checked`).
  2. `turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean`: `ok: true`, `124/124` tight specs, `0` vacuous, `0` trivial, `0` sorryAx, `0` native_decide, `exit 0` (`kernel-checked`).
  3. `wc -l c/*.c`: `198 c/lean_ui_text.c`, `71 c/lean_ui_vulkan.c`, `218 c/lean_ui_wayland.c` (`487` total, all `<= 220` LOC, `0` `.rs`/`.cpp`) (`executable-reproduced`).
  4. All 12 modules (`Defs`, `Kernel`, `Style`, `Layout`, `Scene`, `FFI`, `Wayland`, `Text`, `Vulkan`, `Runtime`, `Canary`, `LeanUI`) compiled with `lean -DwarningAsError=true`, linked against `c/lean_ui_{wayland,vulkan,text}.o` into `/tmp/opencode/lean-ui-canary`, and verified across all 4 matrix variants (`dark_1x`, `dark_2x`, `light_1x`, `light_2x`) with repeat runs confirming byte-for-byte determinism (`SSIM = 1.000`) and `0` redraws when quiescent (`framesRendered = 1`, `quiescentSkips >= 1`):
     - `dark_1x` (`1280x800`): `4,100,192` bytes, SHA256 `2ed76613cf0fe2eaf60463b0e9abd09aea5c15774423586f2c409af0fbed61c0`
     - `dark_2x` (`2560x1600`): `16,397,877` bytes, SHA256 `ca0deb38f7c72c0f9ef0a8ef0ffdd91be279b680f8c3ffd81e6459c44591dce9`
     - `light_1x` (`1280x800`): `4,100,192` bytes, SHA256 `623b97406bdcf6975457fd04f06325d6e7626366f4996c3ee22aeace5c7b893b`
     - `light_2x` (`2560x1600`): `16,397,877` bytes, SHA256 `5a942cf430ad413c50a4da3e100e0e5764725cb8ff81988d1b08a80afb672198`

## Wave 2B Reusable Widget Library (`LeanUI/Widgets/*`): VERIFIED (`w2-canary` / `main`)

- Executor mission: `d1e18443-6f78-4f0f-8b12-bde8894b2ea7` (model: `builtin/smart`, backend: `opencode`, branch: `main` / `w2-canary`).
- Parent commit: `05157805788c07a669060fda07c20d04fffafc10` (tree `dcefc8a064ba3e286a262c0483b84ca0fc5160c0`).
- Implemented all 6 pure reusable widget modules under `lean/LeanUI/Widgets/` (`0` `@[extern]`, `0` `IO`, `0` `sorry`/`sorryAx`/`native_decide`/`axiom`/`opaque`/`unsafe`/`partial`), imported them in `lean/LeanUI.lean`, and wired them into `lean/LeanUI/Canary.lean`:
  1. `lean/LeanUI/Widgets/VirtualList.lean`: variable-height virtualized list anchored via `clampScrollOffset` (`Kernel.scrollLimit` / `Kernel.scrollStep`) and `ScrollSpec`, computing `(firstIdx, lastIdx, topSpacerSub, bottomSpacerSub, visibleItems)` and building a `WidgetNode.scrollClip` tree (`buildVirtualListWidget`).
  2. `lean/LeanUI/Widgets/RichText.lean`: Markdown block/inline AST (`RichBlock`, `RichInline`, `SyntaxRole`, `CodeToken`), syntax-highlighted `CodeBlock` with header + focusable copy button (`buildCodeBlockWidget`), and KaTeX-style 2D math box layout (`MathExpr`: `atom`, `operator`, `fraction`, `superscript`, `subscript`, `supSub`, `radical`, `delimited`, `row` via `buildMathWidget`).
  3. `lean/LeanUI/Widgets/DiffViewer.lean`: unified & split side-by-side diff viewer (`DiffLineKind`: `context`, `add`, `del`, `hunkHeader`; `DiffMode`: `unified`, `split`; dual line-number gutters, `diffAddBg`/`diffDelBg`/`diffHunkBg` styling, and collapsible file header bar via `buildDiffViewerWidget`).
  4. `lean/LeanUI/Widgets/MermaidSvg.lean`: native diagram & vector tile widget (`DiagramNode`, `DiagramEdge`, `SvgPathCmd`, directed Sugiyama-style layered rank/column layout in `SubPx`, box/pill/diamond nodes + orthogonal connector segments + labels via `buildMermaidDiagramWidget`).
  5. `lean/LeanUI/Widgets/Overlays.lean`: modal `Dialog`, `Field`, `Select`, `Tooltip`, `Toast`, and `SearchDialog` (with backdrop scrim, elevation shadow, focusable items, modal trap IDs, and case-insensitive active filter query via `buildSearchDialogWidget`).
  6. `lean/LeanUI/Widgets/Composer.lean`: multi-line composer state & widget (`ComposerBuffer` with cursor offset, bounded undo/redo stacks, atomic `applyImeBatch` and IME preedit span (`imePreeditOffset`, `imePreeditLen`, `imePreeditText`), attachment chips, drag-drop hover state, and focusable `WidgetNode` builder with `Kernel.focusBorder` via `buildComposerWidget`).
- Mechanical Gates on Wave 2B:
  1. Cold 17-module `turbo-lean --no-daemon --no-telemetry --max-memory-mb 6144 build LeanUI LeanUISpec --project-dir lean`: `0 reused, 0 cached, 17 compiled`, `exit 0` (`kernel-checked`).
  2. `turbo-lean --json audit-spec --require-nonempty lean/LeanUI/Spec/*.lean`: `ok: true`, `124/124` tight specs, `0` vacuous, `0` trivial, `0` sorryAx, `0` native_decide, `exit 0` (`kernel-checked`).
  3. `wc -l c/*.c`: `198 c/lean_ui_text.c`, `71 c/lean_ui_vulkan.c`, `218 c/lean_ui_wayland.c` (`487` total, all `<= 220` LOC, `0` `.rs`/`.cpp`) (`executable-reproduced`).
  4. All 18 modules (`Defs`, `Kernel`, `Style`, `Layout`, `Scene`, `Widgets/VirtualList`, `Widgets/RichText`, `Widgets/DiffViewer`, `Widgets/MermaidSvg`, `Widgets/Overlays`, `Widgets/Composer`, `LeanUI`, `FFI`, `Wayland`, `Text`, `Vulkan`, `Runtime`, `Canary`) compiled with `lean -DwarningAsError=true`, linked against `c/lean_ui_{wayland,vulkan,text}.o`, and verified across all 4 matrix variants (`dark_1x`, `dark_2x`, `light_1x`, `light_2x`) with repeat runs confirming byte-for-byte determinism (`run1 == run2`) and `0` redraws when quiescent (`framesRendered == 1`, `quiescentSkips >= 1`):
     - `dark_1x` (`1280x800`): `4,097,178` bytes, SHA256 `f04a319fd0cd20ca29bff22e42ad03c52122e298f21f98fee39b03159e7af484`
     - `dark_2x` (`2560x1600`): `16,386,918` bytes, SHA256 `1c894def2fa794e4a168901d9f61d509c7ac6567378985e4ada1723b024dff3e`
     - `light_1x` (`1280x800`): `4,097,178` bytes, SHA256 `1c57b4bdf7b066db57bece5931090032ea24efc0d4f19cbbb836e3b8fd7dd419`
     - `light_2x` (`2560x1600`): `16,386,918` bytes, SHA256 `ddcf1030020ac96c4a25b86f6c9a014c1efa98d363b7f18116e875e1c9f97490`

## Campaign blockers and controller status

- W0: BLOCKED, 0/36 reference PNGs and 0/20 benchmark runs.
- REVIEW_1 rows 1–25 (all 26 items): CLOSED (`9fbc5aba7021784e0d678b810f86059ae765868a`).
- Freeze status: FROZEN (core types, kernels, specs, and C11 leaf shims accepted). No campaign PASS is claimed.
- Historical W0 ledger transfer remains BLOCKED; trusted relay remains absent.
- Current VM probes: `pkg-config` finds GTK3 3.24.41 and WebKit2GTK 4.1 2.52.3,
  but GTK4, WebKitGTK 6.0, and Vulkan development metadata are missing (exit 1).
  `weston`, `sway`, `Hyprland`, `grim`, and `vulkaninfo` are absent from PATH.
  `sudo -n true` exits 1: the no-new-privileges flag prevents root escalation.
  These measurements do not establish rendering capability or complete W0.
- Baseline inconsistency requires controller/operator resolution, not relaxation:
  W0_GOLDENS and ORCHESTRATOR pin upstream `b043d5572`, GTK3 plus
  `webkit2gtk-4.1`; AGENTS final benchmark gate instead names GTK4 plus
  WebKitGTK. Neither baseline nor final gate is silently substituted.
- No token delivery or push occurred. Receipt-only and local commits are not
  published progress. Local git bundle and full raw author/gate evidence packaging
  with manifest hashes is not durable harvest. Trusted relay remains required;
  VM retained with no lifecycle changes or requested TTL extension.
