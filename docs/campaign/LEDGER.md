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

## Campaign blockers and controller status

- W0: BLOCKED, 0/36 reference PNGs and 0/20 benchmark runs.
- REVIEW_1 rows 1 and 21: OPEN; rows 24 and 25: partial.
- Freeze status: FREEZE_BLOCKED. No campaign PASS is claimed.
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
