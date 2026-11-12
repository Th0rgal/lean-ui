# Review 1 — adversarial read of the frozen core (statements at `c6eac02`, ABI at `53892f2`)

Quorum: **degraded**. Requested `gpt-6-astra` and `fable-5.2` through Orb `consult_model`;
both missions were created but never ran (parked `awaiting_user`, zero events) because the
coordinating session had no Orb mission identity. Effective reviewer: one local
`claude-opus` read-only agent. No second model family has voted.

Verdict of that reviewer: no false statement; `FROZEN` (all 26 rows closed).

| # | Finding | Status |
|---|---|---|
| 1 | `flexMain` is wrong against CSS when a clamp binds; no `shrink` | **closed** — kernels `flexShrink`, `flexRedistribute`, `flexMainClamped`; theorems `flexShrink_length`, `flexShrink_bounds`, `flexShrink_fills`, `flexRedistribute_length`, `flexRedistribute_bounds`, `flexMainClamped_length`, `flexMainClamped_bounds`, `flexMain_fills_clamped`; negative witnesses `flexMain_clamp_loses_space_negWitness`, `flexNoShrink_overflows_negWitness` |
| 2 | `distribute` proportionality unspecified (greedy mutant passes) | statement added: `distribute_proportional` |
| 3 | no half-pixel bound on `roundDev` | statement added: `roundDev_half_pixel` |
| 4 | damage has no outward rounding | kernel `roundRectOut` + `roundRectOut_covers` |
| 5 | `Damage.add` may over-cover; empty `some` inflates | `union_least`, `DamageWF`, `damage_add_wf` |
| 6 | `hitTest_topmost` pins only the last element | replaced by `hitTest_last_containing` |
| 7 | trap stack has no frame law | `pushTrap_refuses`, `pushTrap_keeps`, `popTrap_pushTrap` |
| 8 | `alloc` has no liveness | `alloc_live` (no `WF` hypothesis needed) |
| 9–13 | Wayland ABI: typed new_id, recorder on event-created proxies, tags, signature, fd ownership | `c/lean_ui.h` revised |
| 14 | `Event` lacks IME batch, pointer leave, drop, time | constructors appended |
| 15 | no xkb compose, keymap-dependent mods | `lean_ui_xkb_key` revised |
| 16 | `Prim` too small for a web-faithful UI | `rrect`, `linear`, `mask`, `image`, `clipPushRounded`, `layerPush/Pop` appended; backdrop blur out of scope |
| 17–20 | ABI documentation gaps | `c/lean_ui.h` revised |
| 21 | no atlas padding / reset / pages | **closed** — kernels `Atlas.reset`, `Atlas.allocPadded`, `Atlas.allocPages`; theorems `reset_wf`, `reset_clears_owns`, `reset_preserves_dims`, `allocPadded_wf`, `allocPadded_size`, `allocPadded_guard_owns`, `allocPadded_disjoint_guard`, `allocPages_live`, `allocPages_sound`; negative witnesses `allocUnpadded_abuts_negWitness`, `resetNoRewind_exhausts_negWitness`, `allocSinglePage_full_negWitness` |
| 22 | cache collision witness one-sided | `lookupHead_wrong_entry` added |
| 23 | seam docstring wrong | fixed |
| 24 | scroll detail, resize units, buffer-size lemma | **closed** — `Event.time` added; kernels `resizeSub`, `bufferSize`; theorems `resizeSub_units`, `bufferSize_covers`, `bufferSize_least`, `bufferSize_from_resize`; negative witness `bufferFloor_negWitness` |
| 25 | charter promises a focus-border step and scroll kernels that do not exist | **closed** — kernels `scrollLimit`, `scrollStep`, `focusBorder`, `focusBorderDamage`; theorems `scrollStep_bounds`, `scrollStep_interior`, `scrollStep_start`, `scrollStep_end`, `scrollStep_idle`, `scrollStep_no_overflow`, `scrollStep_mono`, `focusBorder_geometry`, `focusBorder_step`, `focusBorderDamage_quiet`, `focusBorderDamage_changed`, `focusBorderDamage_empty`; negative witnesses `scrollUnsigned_negWitness`, `scrollUnbounded_negWitness`, `borderScaled_negWitness`, `focusAlwaysDamaged_negWitness`, `focusAlwaysDamaged_changedWitness` |
