# Foldseek CLI surface (recon notes, CHUNK-001)

Source: `foldseek -h` / `foldseek <cmd> -h` output from the `Foldseek_jll` v10.0.0+0
executable (git rev `941cd33f`), cross-checked against the upstream source
(`steineggerlab/foldseek`, `src/FoldseekBase.cpp` and
`lib/mmseqs/src/MMseqsBase.cpp`, both at `master` as of 2026-08-16).

## The CLI has two layers, and `-h` only shows one of them

`foldseek -h` prints a curated list of ~24 commands grouped into "Easy
workflows", "Main workflows", "Input database creation", "Format conversion",
"Prefiltering", "Alignment", "Clustering", "Profile databases". Running
`foldseek` with no arguments shows an even shorter list and says "An extended
list of all modules can be obtained by calling `foldseek -h`" — that extended
list is still not everything.

Foldseek is built on the mmseqs2 command framework and inherits its full
command table (`lib/mmseqs/src/MMseqsBase.cpp`, 141 commands) in addition to
its own 39 commands (`src/FoldseekBase.cpp`). `src/foldseek.cpp` sets
`hide_base_commands = true`, which hides the inherited mmseqs2 commands from
`-h` display — **but they are still registered and callable**. Confirmed
directly: `foldseek createtsv -h`, `foldseek mvdb -h`, `foldseek version`, etc.
all work despite not appearing anywhere in `-h` output. Some foldseek-specific
commands are similarly marked `COMMAND_HIDDEN` and absent from `-h` (e.g.
`version`, `structureto3didescriptor`, `scorecomplex`) but are fully
functional.

**Implication for CHUNK-005 onward**: enumerating "the full CLI" means reading
the source command tables, not just `foldseek -h`. There is no in-CLI way to
list hidden commands.

## Flag conventions (important for CHUNK-003's dispatcher)

From `easy-search -h` / `createdb -h`:

- Positional args are documented in the usage line as `<i:...>` (input) /
  `<o:...>` (output), e.g. `foldseek createdb <i:PDB|mmCIF...> ... <o:sequenceDB>`.
  Some commands accept a variadic list of input files before a single output path.
- Options are `--long-flag TYPE` or `-x TYPE` where `TYPE ∈ {INT, FLOAT, BOOL,
  STR, TWIN, BYTE}`.
- **`BOOL` options require an explicit value** (`-a BOOL` with default `[0]`,
  set via `-a 1`), not a bare presence/absence switch as in typical Unix CLIs.
  This corrects the original CHUNK-003 description, which assumed
  booleans map to a bare `--flag`. See Working Knowledge in the plan.
- Options are grouped into named stages in the help text (`prefilter:`,
  `align:`, `misc:`, `common:`, `expert:`) purely for documentation; flag names
  are globally unique per command, so the dispatcher doesn't need to know
  about stages.
- Help text is consistently machine-parseable (`usage: foldseek <cmd> ... ` +
  ` --flag TYPE   description [default]`), which could support auto-generating
  wrapper stubs later — noted as a possible future shortcut, not attempted here.

## Structure input requirements

`createdb --input-format` auto-detects by extension among PDB, mmCIF, mmJSON,
ChemComp, and Foldcomp. Real structure files are required — there's no
trivial single-line synthetic format analogous to a FASTA string.

## Test fixture recommendation (for CHUNK-004)

Use `example/1tim.pdb.gz` and `example/8tim.pdb.gz` from the foldseek
repository itself (~72 KB / 84 KB gzipped) — these are RCSB PDB entries 1TIM
and 8TIM (triosephosphate isomerase from two species), public-domain
structural coordinate data, and they're the exact files foldseek's own `-h`
examples use (`foldseek createdb examples/1tim.pdb.gz examples/8tim.pdb.gz DB`).
Being two homologous structures from different species, they also give
search/cluster/rbh commands a genuine positive hit to assert on, rather than a
degenerate self-match. Small enough to commit; no synthetic alternative
produces a realistic result.

CHUNK-003's dispatcher tests don't need any fixture — `version` and `-h` need
no input files.

## Command inventory

### Foldseek-specific (`src/FoldseekBase.cpp`, 39 commands)

| Command | Category | Description |
|---|---|---|
| easy-search | EASY | Structural search |
| easy-cluster | EASY | Slower, sensitive clustering |
| easy-rbh | EASY | Find reciprocal best hit |
| easy-multimercluster | EASY | Multimer level cluster |
| easy-multimersearch | EASY | Multimer level search |
| easy-complexsearch | HIDDEN | (multimer search, complex-DB variant) |
| createdb | MAIN | Convert PDB/mmCIF/tar[.gz]/DB files or directory/TSV to a structure DB |
| search | MAIN | Sensitive homology search |
| rbh | MAIN | Reciprocal best hit search |
| cluster | MAIN | Slower, sensitive clustering |
| multimercluster | MAIN | Multimer level cluster |
| multimersearch | MAIN | Multimer level search |
| structureclusterupdate | MAIN | Update structure clustering with new sequences using structural alignment |
| databases | DATABASE_CREATION | List and download databases |
| createindex | DATABASE_CREATION | Store precomputed index on disk to reduce search overhead |
| createclusearchdb | DATABASE_CREATION | Build a searchable cluster database allowing for faster searches |
| mmcreateindex | HIDDEN | (mmseqs-style index creation variant) |
| createsubdb | SET | Create a subset of a DB from list of DB keys |
| convertalis | FORMAT_CONVERSION | Convert alignment DB to BLAST-tab, SAM or custom format |
| convert2pdb | FORMAT_CONVERSION | Convert a foldseek structure db to a single multi model PDB file or a directory of PDB files |
| createmultimerreport | FORMAT_CONVERSION | Convert complexDB to tsv format |
| createcomplexreport | HIDDEN | (complex-DB variant of createmultimerreport) |
| compressca | FORMAT_CONVERSION\|EXPERT | Create a new C-alpha DB with chosen compression encoding from a sequence DB |
| tmalign | ALIGNMENT | Compute tm-score |
| lolalign | ALIGNMENT | LoLalign — structure alignment optimizing the Local distance log odds (LoL) score |
| structurealign | ALIGNMENT | Compute structural alignment using 3Di alphabet, amino acids and neighborhood information |
| structurerescorediagonal | ALIGNMENT | Compute sequence identity for diagonal |
| aln2tmscore | ALIGNMENT | Compute tmscore of an alignment database |
| scoremultimer | ALIGNMENT | Get multimer level alignments from alignmentDB |
| scorecomplex | HIDDEN | (complex-DB variant of scoremultimer) |
| expandmultimer | PREFILTER | Re-prefilter to ensure complete alignment between multimers |
| expandcomplex | HIDDEN | (complex-DB variant of expandmultimer) |
| structureto3didescriptor | HIDDEN | Convert PDB/mmCIF/tar[.gz] files to a db |
| clust | CLUSTER | Cluster result by Set-Cover/Connected-Component/Greedy-Incremental |
| result2profile | PROFILE | Compute profile DB from a result DB for both amino acid and 3di |
| complexsearch | HIDDEN | (complex-DB variant of multimersearch) |
| samplemulambda | EXPERT | Sample mu and lambda from random shuffled sequences |
| multimersearch | MAIN | (listed above) |
| version | HIDDEN | Print the foldseek build version |

(`makepaddedseqdb` also appears, HIDDEN, generates a padded sequence/3Di/C-alpha DB — internal.)

### Inherited from mmseqs2 (`lib/mmseqs/src/MMseqsBase.cpp`, 141 commands)

All hidden from `-h` (`hide_base_commands = true`) but callable. Grouped by
category with counts; full command names listed per group.

**Generic / DB-lifecycle (structure-DB-agnostic — relevant to Foldseek.jl):**

| Category | Commands |
|---|---|
| STORAGE (10) | compress, decompress, rmdb, mvdb, cpdb, lndb, aliasdb, unpackdb, touchdb, gpuserver |
| SET (5) | concatdbs, splitdb, mergedbs, subtractdbs (createsubdb is foldseek's own, listed above) |
| DB (7) | setextendeddbtype, view, filterdb, swapdb, prefixid, suffixid, renamedbkeys |
| FORMAT_CONVERSION (3, base) | convertalis (foldseek overrides), createtsv, convert2fasta |
| RESULT (12) | swapresults, result2rbh, result2msa, result2dnamsa, result2stats, filterresult, offsetalignment, proteinaln2nucl, result2repseq, sortresult, summarizealis, summarizeresult |
| CLUSTER (3, base beyond foldseek's `clust`) | pickconsensusrep, clusthash, mergeclusters |

**Internal pipeline stages / advanced (ambiguous value as standalone typed
wrappers — usually invoked automatically by `search`/`easy-search`; scope
decision needed, see Open Questions):**

| Category | Commands |
|---|---|
| PREFILTER (5) | prefilter, ungappedprefilter, gappedprefilter, kmermatcher, kmersearch |
| ALIGNMENT (6, base) | align, alignall, transitivealign, rescorediagonal, fwbw, alignbykmer |
| PROFILE (7, base) | sequence2profile, profile2pssm, profile2neff, profile2consensus, profile2repseq, convertprofiledb (result2profile is foldseek's own, listed above) |
| PROFILE_PROFILE (4) | tsv2exprofiledb, convertca3m, expandaln, expand2profile |
| HIDDEN/EXPERT misc (~13) | makepaddedseqdb, appenddbtoindex, indexdb, kmerindexdb, filtera3m, enrich, calculatelambda, dbtype, diskspaceavail, recoverlongestorf, pairaln |

**Sequence/taxonomy/nucleotide-specific (recommend excluding — orthogonal to
structural search; see Open Questions):**

| Category | Commands |
|---|---|
| TAXONOMY (12) | createtaxdb, filtertaxdb, filtertaxseqdb, aggregatetax, aggregatetaxweights, lcaalign, lca, createbintaxonomy, createdmptaxonomy, createbintaxmapping, addtaxonomy, majoritylca, taxonomyreport |
| MULTIHIT (5) | multihitdb, multihitsearch, besthitperset, combinepvalperset, mergeresultsbyset |
| SEQUENCE (9) | extractorfs, extractframes, orftocontig, reverseseq, translatenucs, translateaa, splitsequence, masksequence, extractalignedregion |
| SPECIAL (10) | diffseqdbs, summarizetabs, gff2db, maskbygff, convertkb, convertblastdb, summarizeheaders, nrtotaxmapping, extractdomains, countkmer |
| MAIN (base, non-structural) | map, linclust, clusterupdate, taxonomy, linsearch |
| CLUSTPROTEOME | proteomecluster |
| EASY (base, non-structural) | easy-linclust, easy-linsearch, easy-proteomecluster, easy-taxonomy |
| DATABASE_CREATION (base, non-structural) | createlinindex, convertmsa, tar2db, db2tar, tsv2db |

## Scope decision (resolved 2026-08-16, supersedes the original Tier proposal)

The first pass of this document proposed a Tier 1 (~79 commands) / Tier 2
(~35, blocked) / out-of-scope (~48) split based on C++ command category. After
review, the actual decision taken is narrower and simpler: **typed wrappers
are scoped to exactly the commands `foldseek -h` prints — nothing more.**
Everything else is reached through a `foldseek"..."` passthrough string macro
(plan CHUNK-005) instead of a bespoke wrapper per command. This sidesteps the
Tier 2/3 category judgment calls entirely rather than resolving them.

Category membership is **not** a reliable predictor of `-h` visibility —
e.g. `structureclusterupdate` (`COMMAND_MAIN`) and `lolalign`
(`COMMAND_ALIGNMENT`) are in categories that partly show up in `-h`, but
neither command itself is printed. The literal list below, transcribed
directly from `foldseek -h` output, is the actual scope for CHUNK-006–010:

| Section (as printed by `-h`) | Commands |
|---|---|
| Easy workflows (5) | `easy-search`, `easy-cluster`, `easy-rbh`, `easy-multimercluster`, `easy-multimersearch` |
| Main workflows (6) | `createdb`, `search`, `rbh`, `cluster`, `multimercluster`, `multimersearch` |
| Input database creation (3) | `databases`, `createindex`, `createclusearchdb` |
| Unite and intersect databases (1) | `createsubdb` |
| Format conversion (4) | `convertalis`, `compressca`, `convert2pdb`, `createmultimerreport` |
| Prefiltering (1) | `expandmultimer` |
| Alignment (5) | `tmalign`, `structurealign`, `structurerescorediagonal`, `aln2tmscore`, `scoremultimer` |
| Clustering (1) | `clust` |
| Profile databases (1) | `result2profile` |

27 commands total. Every other command in the two inventory tables above
(the remaining ~12 foldseek-specific commands and all ~141 inherited mmseqs2
commands) is reachable only via `foldseek"..."`, not a typed function.
