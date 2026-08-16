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
self-match.
