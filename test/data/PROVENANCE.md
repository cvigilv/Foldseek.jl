# Test fixture provenance

`1tim.pdb.gz` and `8tim.pdb.gz` are copied unmodified from the
[foldseek](https://github.com/steineggerlab/foldseek) repository's own
`example/` directory, commit `21952ed84e0f4a06ec6af08d58add77cef8dec14`
(`master`, 2026-08-16):

- `example/1tim.pdb.gz` — RCSB PDB entry [1TIM](https://www.rcsb.org/structure/1TIM), triosephosphate isomerase (chicken).
- `example/8tim.pdb.gz` — RCSB PDB entry [8TIM](https://www.rcsb.org/structure/8TIM), triosephosphate isomerase (yeast).

Both are gzip-compressed legacy PDB-format coordinate files. Structural
coordinate data deposited in the PDB is public domain (per RCSB PDB's
[usage policy](https://www.rcsb.org/pages/policies)). These are also the
exact files foldseek's own CLI help text uses as examples
(`foldseek createdb examples/1tim.pdb.gz examples/8tim.pdb.gz DB`), and being
two homologous structures from different species, they give search/cluster
commands a genuine positive hit to assert on rather than a degenerate
self-match. Both happen to be homodimers (chains A and B are the same
sequence), so they don't exercise a genuinely heteromeric complex — see
`4hhb.pdb.gz`/`1y8h.pdb.gz` below for that.

`4hhb.pdb.gz` and `1y8h.pdb.gz` were downloaded directly from RCSB
(`https://files.rcsb.org/download/<ID>.pdb`, 2026-08-16) and gzip-compressed
the same way:

- [4HHB](https://www.rcsb.org/structure/4HHB) — human deoxyhemoglobin, an
  alpha2beta2 heterotetramer (chains A/C = alpha, 141 residues; B/D = beta,
  146 residues).
- [1Y8H](https://www.rcsb.org/structure/1Y8H) — horse methemoglobin, the
  same alpha2beta2 architecture (chains A/C = alpha, B/D = beta) from a
  different species.

Same public-domain rationale as above. Chosen so `multimersearch`,
`multimercluster`, and `createmultimerreport` have a real heteromeric
(two distinct chain types, not a homodimer) complex-to-complex match to
assert on: `foldseek multimersearch` between them reports all 4
query-chain-to-target-chain permutations with TM-scores in the 0.86-0.91
range (lower than the homodimeric 1TIM/8TIM pair's ~0.98, since these are a
deoxy- vs. met-hemoglobin pair at lower resolution — still an unambiguous
positive hit).
