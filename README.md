# Foldseek.jl

A Julia wrapper around [Foldseek](https://github.com/steineggerlab/foldseek),
via the bundled executable in
[Foldseek_jll.jl](https://github.com/JuliaBinaryWrappers/Foldseek_jll.jl). It
does not reimplement any Foldseek functionality — it exposes the CLI as
Julia functions, and a passthrough macro for anything not covered by a
typed function.

## Installation

```julia
using Pkg
Pkg.add("Foldseek")
```

## Usage

Every command `foldseek -h` prints has a typed Julia function: positional
arguments match the CLI's own usage line, and every other CLI option is
available as a keyword argument (underscores become hyphens, e.g.
`comp_bias_corr` → `--comp-bias-corr`; a single-character keyword name
becomes a short `-x` flag instead).

```julia
using Foldseek

easy_search("query.pdb", "target.pdb", "result.m8", "tmp")
```

Anything not covered by a typed function — foldseek commands hidden from
`-h`, and everything inherited from the underlying mmseqs2 command
framework (see `CLI_NOTES.md`) — is still reachable through
`foldseek` directly, or through the `@foldseek_str` macro,
which runs a command written exactly as it would be on the command line:

```julia
foldseek"createtsv queryDB targetDB clusterDB clusters.tsv"
```

## Command coverage

Every command `foldseek -h` prints is wrapped, grouped below exactly as
`-h` groups them.

### Easy workflows for plain text input/output

| Command | Function |
|---|---|
| `easy-search` | `easy_search` |
| `easy-cluster` | `easy_cluster` |
| `easy-rbh` | `easy_rbh` |
| `easy-multimercluster` | `easy_multimercluster` |
| `easy-multimersearch` | `easy_multimersearch` |

### Main workflows for database input/output

| Command | Function |
|---|---|
| `createdb` | `createdb` |
| `search` | `search` |
| `rbh` | `rbh` |
| `cluster` | `cluster` |
| `multimercluster` | `multimercluster` |
| `multimersearch` | `multimersearch` |

### Input database creation

| Command | Function |
|---|---|
| `databases` | `databases` |
| `createindex` | `createindex` |
| `createclusearchdb` | `createclusearchdb` |

### Unite and intersect databases

| Command | Function |
|---|---|
| `createsubdb` | `createsubdb` |

### Format conversion for downstream processing

| Command | Function |
|---|---|
| `convertalis` | `convertalis` |
| `compressca` | `compressca` |
| `convert2pdb` | `convert2pdb` |
| `createmultimerreport` | `createmultimerreport` |

### Prefiltering

| Command | Function |
|---|---|
| `expandmultimer` | `expandmultimer` |

### Alignment

| Command | Function |
|---|---|
| `tmalign` | `tmalign` |
| `structurealign` | `structurealign` |
| `structurerescorediagonal` | `structurerescorediagonal` |
| `aln2tmscore` | `aln2tmscore` |
| `scoremultimer` | `scoremultimer` |

### Clustering

| Command | Function |
|---|---|
| `clust` | `clust` |

### Profile databases

| Command | Function |
|---|---|
| `result2profile` | `result2profile` |

### Everything else

`foldseek -h` prints a curated subset (~27 commands) of a much larger CLI —
Foldseek is built on the mmseqs2 command framework and inherits its full
command table, plus a number of its own commands hidden from `-h`. None of
those (~150 commands total) has a typed wrapper; all remain reachable
through `foldseek` or `@foldseek_str`. See `CLI_NOTES.md`
for the full inventory.

## License

GPL-3.0 (see `LICENSE`).
