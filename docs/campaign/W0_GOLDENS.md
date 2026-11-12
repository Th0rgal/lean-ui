# Wave 0 worker brief — reference goldens and baseline benchmarks

You build the *judge inputs* for the lean-ui campaign: reference screenshots and baseline
numbers of the existing Orb Linux desktop (GTK + WebKitGTK), captured inside this VM.
You do not write any lean-ui renderer code.

## Pinned inputs
- `https://github.com/Th0rgal/orb` at `b043d5572` (`master`). Shell: `linux_shell/` (GTK3 +
  `webkit2gtk-4.1`, default window 1470x923). UI: `orb/` (SolidJS + Vite, pnpm).
- `https://github.com/Th0rgal/lean-ui` `main`. Judge: `scripts/diff_goldens.py` (do not edit).
- Read `orb/AGENTS.md` build section. Use `turbo-lean` (check `--version`/`--help` first; the
  installed binary may lack flags the docs mention). Never run raw `lake`/`elan` unless a
  repo script does it for you. Bound Lean memory (`--max-memory-mb`).

## Environment to set up (record exact package versions in `goldens/ENV.txt`)
- Headless Wayland compositor with screenshot support (sway `WLR_BACKENDS=headless` + `grim`,
  or weston headless) and software Vulkan/GL (Mesa lavapipe/llvmpipe).
- One headless output per variant: logical 1470x923 at scale 1 (1470x923 px) and scale 2
  (2940x1846 px). The Orb window must fill the output exactly (no decorations/borders/bar).
- Fonts pinned: install Inter (`fonts-inter`) and a monospace; write the `fc-match` results
  for `Inter`, `sans-serif`, `monospace` to ENV.txt. No other font changes.
- Build `orb-locald` (`scripts/build_orb_bins.sh --only orb-locald`), the shell
  (`make -C linux_shell`), and the UI (`pnpm install --frozen-lockfile`).

## Screens (9) x theme (dark, light) x scale (1x, 2x) = 36 PNGs
The production `dist` has no fixture mode. The shell accepts
`ORB_DEV_URL=http://127.0.0.1:<port>/...`, and the Vite dev server serves `orb/tests/*.html`
harness pages; `orb/tests/appPerfCore.ts` `startCore()` is a Node mock of Core (HTTP + SSE)
for full-app screens. Theme is `localStorage["orb-theme"]`; API target is
`localStorage["orb.apiUrl"]` / `["orb.jwt"]`; selected view is
`localStorage["orb.selectedConversation"]`. Run with `ORB_NATIVE_CHROME=0` so the whole
window is the web UI (the surface lean-ui replaces).

| id | source |
|---|---|
| `inbox` | full app + mock Core, Inbox page |
| `transcript` | full app + mock Core, the long mission (settled) |
| `streaming` | same mission mid-stream: push a fixed number of SSE deltas, then capture |
| `diff` | DiffViewer — no harness exists; add a small `orb/tests/` page with a fixed unified diff |
| `math-mermaid` | `tests/markdown-math.html` + `tests/mermaid.html` content (one page or app mission) |
| `search` | full app + mock Core, SearchDialog open with a fixed query |
| `settings` | full app, Settings (first tab) |
| `approvals` | `tests/approval-queue.html` or app state with a pending approval |
| `side-question` | `tests/side-questions.html` or app with the /btw panel open |

Anything that needs seeding (localStorage, opening a dialog, typing a query) must be done by
a committed script, not by hand: e.g. a tiny bootstrap page under `orb/tests/` that sets
localStorage then navigates, and input via the compositor (`wtype`, `wlrctl`, `swaymsg`).
Freeze time-dependent content (relative timestamps, cursors, spinners): fixed clock in the
mock data and CSS animations settled/disabled *only via the fixture page*, not by patching
`orb/src`.

File names: `goldens/<id>__<theme>__<scale>.png`, e.g. `goldens/inbox__dark__2x.png`.

## Determinism gate (must pass before you report DONE)
Capture the full set twice from cold starts into `goldens/` and `goldens_repeat/`, then run
`python3 scripts/diff_goldens.py goldens goldens_repeat --threshold 0.999 --require 36`.
If a screen cannot reach 0.999 against itself, say which and why; do not hide it.

## Baseline benchmarks
Write `scripts/bench_desktop.sh` so the *same script* can later measure a different binary:
`bench_desktop.sh --cmd '<launch command>' --label <name> --runs N --out <file.json>`.
It must measure from outside the app (no in-page JS), for N >= 20 cold runs:
- `cold_ms`: exec to first committed non-blank frame (detect via `WAYLAND_DEBUG=client`
  commit timestamps and/or first `grim` capture that differs from the blank background);
- `rss_mib` and `pss_mib`: sum over the whole process tree (`/proc/<pid>/smaps_rollup`),
  peak during startup and steady after 5 s idle;
- `transcript_open_ms`: selecting the long mission to its first stable frame;
- `frame_p50_ms`, `frame_p99_ms`: commit-to-commit intervals during a scripted 5 s scroll
  of the long transcript on a 120 Hz headless output;
- `idle_cpu_pct`: process-tree CPU over 10 s while the window is unfocused.
Each run emits a JSON line with `work_units` (frames or runs measured) and `error_count`;
a run that could not measure something reports an error, never a zero.
Record the baseline to `bench/baseline_gtk_webkit.json` with machine info (CPU, RAM, kernel,
Mesa, compositor, WebKitGTK versions). Also write `scripts/capture_orb_goldens.sh` wrapping
your capture procedure end to end.

## Delivery
Work in a clone of lean-ui on branch `w0-goldens` and commit: `goldens/`, `goldens_repeat/`
(or its JSON report only), `bench/`, `scripts/capture_orb_goldens.sh`,
`scripts/bench_desktop.sh`, any `orb/tests/` fixture pages you added (as a patch file under
`docs/campaign/orb-fixtures.patch`). Try `git push origin w0-goldens`. If this machine has
no push credentials, do NOT look for tokens: leave the work committed under
`/var/lib/orb-node/work/caches/lean-ui`, share the PNGs and JSON in your final message, and
say so. End with `DONE`, `BLOCKED` (exact failing command and output) or `NOT_FEASIBLE`.
Never report a screen or metric you did not actually capture.
