# Typed wrappers for the "Main workflows" section of `foldseek -h`:
# createdb, search, rbh, cluster, multimercluster, multimersearch.
#
# Unlike the easy-* workflows, these operate on Foldseek databases (built by
# `createdb`) rather than raw structure files directly. Every option beyond
# the required positional arguments is available as a keyword argument via
# the `foldseek(subcommand, args...; kwargs...)` dispatcher — see its
# docstring for the flag-naming and Bool/nothing conventions. Positional
# argument order below is transcribed directly from each command's `-h`
# usage line (recorded in CLI_NOTES.md), not re-derived.

export createdb, search, rbh, cluster, multimercluster, multimersearch

"""
    createdb(inputs, outputdb; kwargs...)

Run `foldseek createdb`: convert one or more PDB/mmCIF[.gz]/tar[.gz]/DB files
or a directory or TSV file into a Foldseek structure database at `outputdb`.
`inputs` is a path to a single input or a vector of paths. Every
`foldseek createdb` CLI option is available as a keyword argument; run
`foldseek"createdb -h"` for the full, version-specific list.
"""
function createdb(inputs::AbstractVector{<:AbstractString}, outputdb::AbstractString; kwargs...)
    return foldseek("createdb", String.(inputs)..., outputdb; kwargs...)
end
createdb(input::AbstractString, outputdb::AbstractString; kwargs...) = createdb([input], outputdb; kwargs...)

"""
    search(querydb, targetdb, alignmentdb, tmpdir; kwargs...)

Run `foldseek search`: sensitive homology search of `querydb` against
`targetdb` (both existing Foldseek databases, e.g. from [`createdb`](@ref)),
writing results to `alignmentdb` using `tmpdir` for scratch space. Every
`foldseek search` CLI option is available as a keyword argument; run
`foldseek"search -h"` for the full, version-specific list.
"""
function search(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("search", querydb, targetdb, alignmentdb, tmpdir; kwargs...)
end

"""
    rbh(querydb, targetdb, alignmentdb, tmpdir; kwargs...)

Run `foldseek rbh`: reciprocal best hit search between `querydb` and
`targetdb` (both existing Foldseek databases), writing results to
`alignmentdb` using `tmpdir` for scratch space. Every `foldseek rbh` CLI
option is available as a keyword argument; run `foldseek"rbh -h"` for the
full, version-specific list.
"""
function rbh(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("rbh", querydb, targetdb, alignmentdb, tmpdir; kwargs...)
end

"""
    cluster(sequencedb, clusterdb, tmpdir; kwargs...)

Run `foldseek cluster`: cluster `sequencedb` (an existing Foldseek database),
writing results to `clusterdb` using `tmpdir` for scratch space. Every
`foldseek cluster` CLI option is available as a keyword argument; run
`foldseek"cluster -h"` for the full, version-specific list.
"""
function cluster(sequencedb::AbstractString, clusterdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("cluster", sequencedb, clusterdb, tmpdir; kwargs...)
end

"""
    multimercluster(sequencedb, clusterdb, tmpdir; kwargs...)

Run `foldseek multimercluster`: cluster `sequencedb` (an existing Foldseek
database) at the multimer level, writing results to `clusterdb` using
`tmpdir` for scratch space. Every `foldseek multimercluster` CLI option is
available as a keyword argument; run `foldseek"multimercluster -h"` for the
full, version-specific list.
"""
function multimercluster(sequencedb::AbstractString, clusterdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("multimercluster", sequencedb, clusterdb, tmpdir; kwargs...)
end

"""
    multimersearch(querydb, targetdb, alignmentdb, tmpdir; kwargs...)

Run `foldseek multimersearch`: search `querydb` against `targetdb` (both
existing Foldseek databases) at the multimer level, writing results to
`alignmentdb` using `tmpdir` for scratch space. Every `foldseek
multimersearch` CLI option is available as a keyword argument; run
`foldseek"multimersearch -h"` for the full, version-specific list.
"""
function multimersearch(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("multimersearch", querydb, targetdb, alignmentdb, tmpdir; kwargs...)
end
