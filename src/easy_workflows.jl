# Typed wrappers for the "Easy workflows" section of `foldseek -h`:
# easy-search, easy-cluster, easy-rbh, easy-multimercluster, easy-multimersearch.
#
# Each accepts one or more query structure files as either a single path or a
# vector of paths; every other `foldseek <cmd>` option is available as a
# keyword argument via the `foldseek(subcommand, args...; kwargs...)`
# dispatcher (see its docstring for the flag-naming and Bool/nothing
# conventions). Positional argument order below is transcribed directly from
# each command's `-h` usage line (recorded in CLI_NOTES.md), not re-derived.

export easy_search, easy_cluster, easy_rbh, easy_multimercluster, easy_multimersearch

"""
    easy_search(queryfiles, target, alignmentfile, tmpdir; kwargs...)

Run `foldseek easy-search`: structural search of one or more query structures
against `target` (a FASTA file or an existing Foldseek target database),
writing results to `alignmentfile` using `tmpdir` for scratch space.
`queryfiles` is a path to a single PDB/mmCIF[.gz] file or a vector of paths.
Every `foldseek easy-search` CLI option is available as a keyword argument;
run `foldseek"easy-search -h"` for the full, version-specific list.
"""
function easy_search(
    queryfiles::AbstractVector{<:AbstractString},
    target::AbstractString,
    alignmentfile::AbstractString,
    tmpdir::AbstractString;
    kwargs...,
)
    return foldseek("easy-search", String.(queryfiles)..., target, alignmentfile, tmpdir; kwargs...)
end
easy_search(queryfile::AbstractString, target::AbstractString, alignmentfile::AbstractString, tmpdir::AbstractString; kwargs...) =
    easy_search([queryfile], target, alignmentfile, tmpdir; kwargs...)

"""
    easy_cluster(queryfiles, clusterprefix, tmpdir; kwargs...)

Run `foldseek easy-cluster`: cluster one or more query structures, writing
output files prefixed with `clusterprefix` and using `tmpdir` for scratch
space. `queryfiles` is a path to a single PDB/mmCIF[.gz] file or a vector of
paths. Every `foldseek easy-cluster` CLI option is available as a keyword
argument; run `foldseek"easy-cluster -h"` for the full, version-specific list.
"""
function easy_cluster(
    queryfiles::AbstractVector{<:AbstractString}, clusterprefix::AbstractString, tmpdir::AbstractString; kwargs...
)
    return foldseek("easy-cluster", String.(queryfiles)..., clusterprefix, tmpdir; kwargs...)
end
easy_cluster(queryfile::AbstractString, clusterprefix::AbstractString, tmpdir::AbstractString; kwargs...) =
    easy_cluster([queryfile], clusterprefix, tmpdir; kwargs...)

"""
    easy_rbh(queryfile, target, alignmentfile, tmpdir; kwargs...)

Run `foldseek easy-rbh`: find reciprocal best hits between `queryfile` and
`target` (a FASTA file or an existing Foldseek target database), writing
results to `alignmentfile` using `tmpdir` for scratch space. Unlike the other
easy workflows, `foldseek easy-rbh` takes exactly one query file, not several.
Every `foldseek easy-rbh` CLI option is available as a keyword argument; run
`foldseek"easy-rbh -h"` for the full, version-specific list.
"""
function easy_rbh(queryfile::AbstractString, target::AbstractString, alignmentfile::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("easy-rbh", queryfile, target, alignmentfile, tmpdir; kwargs...)
end

"""
    easy_multimercluster(queryfiles, clusterprefix, tmpdir; kwargs...)

Run `foldseek easy-multimercluster`: cluster one or more query multimer
structures at the multimer level, writing output files prefixed with
`clusterprefix` and using `tmpdir` for scratch space. `queryfiles` is a path
to a single PDB/mmCIF[.gz] file or a vector of paths. Every
`foldseek easy-multimercluster` CLI option is available as a keyword
argument; run `foldseek"easy-multimercluster -h"` for the full,
version-specific list.
"""
function easy_multimercluster(
    queryfiles::AbstractVector{<:AbstractString}, clusterprefix::AbstractString, tmpdir::AbstractString; kwargs...
)
    return foldseek("easy-multimercluster", String.(queryfiles)..., clusterprefix, tmpdir; kwargs...)
end
easy_multimercluster(queryfile::AbstractString, clusterprefix::AbstractString, tmpdir::AbstractString; kwargs...) =
    easy_multimercluster([queryfile], clusterprefix, tmpdir; kwargs...)

"""
    easy_multimersearch(queryfiles, target, outputfile, tmpdir; kwargs...)

Run `foldseek easy-multimersearch`: search one or more query multimer
structures against `target` (a FASTA file or an existing Foldseek target
database) at the multimer level, writing results to `outputfile` using
`tmpdir` for scratch space. `queryfiles` is a path to a single PDB/mmCIF[.gz]
file or a vector of paths. Every `foldseek easy-multimersearch` CLI option is
available as a keyword argument; run `foldseek"easy-multimersearch -h"` for
the full, version-specific list.
"""
function easy_multimersearch(
    queryfiles::AbstractVector{<:AbstractString}, target::AbstractString, outputfile::AbstractString, tmpdir::AbstractString; kwargs...
)
    return foldseek("easy-multimersearch", String.(queryfiles)..., target, outputfile, tmpdir; kwargs...)
end
easy_multimersearch(queryfile::AbstractString, target::AbstractString, outputfile::AbstractString, tmpdir::AbstractString; kwargs...) =
    easy_multimersearch([queryfile], target, outputfile, tmpdir; kwargs...)
