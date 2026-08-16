# Session Handoff — 2026-08-16

## Project maturity target
`releasable-package` — Foldseek.jl

## What was just completed
CHUNK-001: cli-recon
Enumerated the full `foldseek` CLI surface, not just what `foldseek -h` shows. `-h` only lists ~24 curated commands; Foldseek is built on the mmseqs2 command framework and inherits 141 additional commands that are hidden from `-h` (`hide_base_commands = true`) but fully callable — confirmed directly (`foldseek createtsv -h`, `foldseek mvdb -h`, `foldseek version` all work). Got the authoritative list by shallow-cloning `steineggerlab/foldseek` and parsing `src/FoldseekBase.cpp` (39 foldseek-specific commands) and `lib/mmseqs/src/MMseqsBase.cpp` (141 inherited commands). Full inventory, flag conventions, and a proposed Tier 1 / Tier 2 / out-of-scope categorization are in `CLI_NOTES.md`.

## Key decisions made
- Test fixtures for CHUNK-004: bundle `example/1tim.pdb.gz` + `example/8tim.pdb.gz` from foldseek's own repo (public-domain PDB coordinate data, two homologous structures — gives search/cluster/rbh a real positive hit to assert on). No synthetic alternative exists for structure files the way inline FASTA text works for sequences.
- Restructured CHUNK-005 through CHUNK-008 (originally a 4-chunk db/search/convert/remaining split) into CHUNK-005 through CHUNK-015, because the real CLI surface (~180 commands total) is far larger than the original plan assumed. Split by category: easy-workflows, main-workflows, database-management, db-lifecycle-utility, format-conversion, alignment-and-scoring, result-processing, cluster-utility, then docs and the end-to-end example. Full rationale in `CLI_NOTES.md`.
- **Superseded same day, after user review**: the Tier 1/2/3 split above (and CHUNK-013) is replaced. The user decided typed wrappers are scoped to exactly the 27 commands `foldseek -h` prints (CHUNK-006–010, renumbered), and everything else — hidden foldseek commands and all ~141 inherited mmseqs2 commands — goes through a new `foldseek"..."` passthrough string macro (CHUNK-005) instead of individual wrappers. Both open scope questions are resolved by this decision, not answered case-by-case. `ANALYSIS_PLAN.md` and `CLI_NOTES.md` ("Scope decision" section) reflect the current, correct chunk list — CHUNK-013 no longer exists.
- The macro's canonical invocation is `foldseek"easy-search q.pdb t.pdb out.m8 tmp"` (Julia's `prefix"..."` sugar for `macro foldseek_str`), not `@foldseek"..."` — Julia's string-macro sugar only expands for macros named `..._str`, so `@foldseek"..."` (as literally suggested) isn't valid syntax for this.

## State of the codebase
- Files created or modified: `CLI_NOTES.md` (new), `ANALYSIS_PLAN.md` (chunk restructure, Working knowledge, Open Questions, session ledger).
- No package code changed this session — CHUNK-001 was pure recon.
- Package loads cleanly: yes (unchanged from prior session).
- Test suite passes: yes (unchanged — `test/runtests.jl` still just the `foldseek(`version`)` smoke test).
- Known issues: none.

## Next chunk
CHUNK-003: core-command-dispatcher
The only chunk with all dependencies satisfied (CHUNK-001, CHUNK-002 are both `complete`). Refactor `foldseek(::Cmd)` in `src/Foldseek.jl` into the shared dispatcher: subcommand name + positional args + Julia kwargs → `Cmd`, run it, raise a Julia error with captured stderr on nonzero exit. Get the BOOL-flag mapping right here (see Watch out for, below) since every later wrapper chunk depends on it. CHUNK-004 (test-fixtures) has no unmet dependencies either and could be done in the same or a following session before CHUNK-005.

## Watch out for
- **BOOL flags take an explicit value.** `-a BOOL` / `--diag-score BOOL` etc. need `--flag 0` or `--flag 1`, never a bare `--flag`. This must be correct in CHUNK-003's dispatcher from the start — get it wrong there and every downstream wrapper (and CHUNK-005's macro, indirectly, since it shares the dispatcher for running the resolved `Cmd`) inherits the bug.
- `foldseek -h` **is** now the source of truth for typed-wrapper scope (CHUNK-006–010) — this flipped from the previous note in this file. It is still not the source of truth for "does this command exist at all": everything else is real and callable via `foldseek"..."` (CHUNK-005), just not worth a typed wrapper.
- Category membership (`COMMAND_MAIN`, `COMMAND_ALIGNMENT`, ...) does **not** imply `-h` visibility — use the literal 27-command list in `CLI_NOTES.md`'s "Scope decision" section, not the category tables above it.
