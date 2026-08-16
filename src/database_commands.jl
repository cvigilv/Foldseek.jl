# Typed wrappers for the "Input database creation" and "Unite and intersect
# databases" sections of `foldseek -h`: databases, createindex,
# createclusearchdb, createsubdb.
#
# Every option beyond the required positional arguments is available as a
# keyword argument via the `foldseek(subcommand, args...; kwargs...)`
# dispatcher — see its docstring for the flag-naming and Bool/nothing
# conventions. Positional argument order below is transcribed directly from
# each command's `-h` usage line (recorded in CLI_NOTES.md), not re-derived.

export databases, createindex, createclusearchdb, createsubdb

"""
    databases(name, outputdb, tmpdir; kwargs...)

Run `foldseek databases`: download the named reference database (e.g.
`"PDB"`, `"Alphafold/Swiss-Prot"` — run `foldseek"databases -h"` for the full,
version-specific list of names) into a Foldseek database at `outputdb`, using
`tmpdir` for scratch space. Downloads can be tens to hundreds of gigabytes;
every `foldseek databases` CLI option is available as a keyword argument.
"""
function databases(name::AbstractString, outputdb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("databases", name, outputdb, tmpdir; kwargs...)
end

"""
    createindex(sequencedb, tmpdir; kwargs...)

Run `foldseek createindex`: store a precomputed index for `sequencedb` (an
existing Foldseek database) on disk, using `tmpdir` for scratch space, to
reduce the overhead of future searches against it. Every
`foldseek createindex` CLI option is available as a keyword argument; run
`foldseek"createindex -h"` for the full, version-specific list.
"""
function createindex(sequencedb::AbstractString, tmpdir::AbstractString; kwargs...)
    return foldseek("createindex", sequencedb, tmpdir; kwargs...)
end

"""
    createclusearchdb(sequencedb, clusterdb, outputdb; kwargs...)

Run `foldseek createclusearchdb`: build a searchable cluster database at
`outputdb` from `sequencedb` (an existing Foldseek database) and `clusterdb`
(a clustering result, e.g. from [`cluster`](@ref)). Every
`foldseek createclusearchdb` CLI option is available as a keyword argument;
run `foldseek"createclusearchdb -h"` for the full, version-specific list.
"""
function createclusearchdb(sequencedb::AbstractString, clusterdb::AbstractString, outputdb::AbstractString; kwargs...)
    return foldseek("createclusearchdb", sequencedb, clusterdb, outputdb; kwargs...)
end

"""
    createsubdb(subset, db, outputdb; kwargs...)

Run `foldseek createsubdb`: create a subset of `db` (an existing Foldseek
database) containing only the keys listed in `subset` (a text file of keys,
or another database whose keys are used), writing the result to `outputdb`.
Every `foldseek createsubdb` CLI option is available as a keyword argument;
run `foldseek"createsubdb -h"` for the full, version-specific list.
"""
function createsubdb(subset::AbstractString, db::AbstractString, outputdb::AbstractString; kwargs...)
    return foldseek("createsubdb", subset, db, outputdb; kwargs...)
end
