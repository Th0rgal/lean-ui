# Review 1 — adversarial read of the frozen core (statements at `c6eac02`, ABI at `53892f2`)

Quorum: **degraded**. Requested `gpt-6-astra` and `fable-5.2` through Orb `consult_model`;
both missions were created but never ran (parked `awaiting_user`, zero events) because the
coordinating session had no Orb mission identity. Effective reviewer: one local
`claude-opus` read-only agent. No second model family has voted.

Verdict of that reviewer: no false statement; `FREEZE_BLOCKED` on weak contracts and ABI gaps.

| # | Finding | Status |
|---|---|---|
| 1 | `flexMain` is wrong against CSS when a clamp binds; no `shrink` | **open** — needs a freeze-and-redistribute kernel and `flexMain_fills_clamped` |
| 2 | `distribute` proportionality unspecified (greedy mutant passes) | statement added: `distribute_proportional` |
| 3 | no half-pixel bound on `roundDev` | statement added: `roundDev_half_pixel` |
| 4 | damage has no outward rounding | kernel `roundRectOut` + `roundRectOut_covers` |
| 5 | `Damage.add` may over-cover; empty `some` inflates | `union_least`, `DamageWF`, `damage_add_wf` |
| 6 | `hitTest_topmost` pins only the last element | replaced by `hitTest_last_containing` |
| 7 | trap stack has no frame law | `pushTrap_refuses`, `pushTrap_keeps`, `popTrap_pushTrap` |
| 8 | `alloc` has no liveness | `alloc_live` |
| 9–13 | Wayland ABI: typed new_id, recorder on event-created proxies, tags, signature, fd ownership | `c/lean_ui.h` revised |
| 14 | `Event` lacks IME batch, pointer leave, drop, time | constructors appended |
| 15 | no xkb compose, keymap-dependent mods | `lean_ui_xkb_key` revised |
| 16 | `Prim` too small for a web-faithful UI | `rrect`, `linear`, `mask`, `image`, `clipPushRounded`, `layerPush/Pop` appended; backdrop blur out of scope |
| 17–20 | ABI documentation gaps | `c/lean_ui.h` revised |
| 21 | no atlas padding / reset / pages | **open** |
| 22 | cache collision witness one-sided | `lookupHead_wrong_entry` added |
| 23 | seam docstring wrong | fixed |
| 24 | scroll detail, resize units, buffer-size lemma | **open** (time added as `Event.time`) |
| 25 | charter promises a focus-border step and scroll kernels that do not exist | **open** |
