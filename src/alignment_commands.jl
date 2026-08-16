# Typed wrappers for the remaining sections of `foldseek -h`: "Prefiltering",
# "Alignment", "Clustering", and "Profile databases" — expandmultimer,
# tmalign, structurealign, structurerescorediagonal, aln2tmscore,
# scoremultimer, clust, result2profile.
#
# Unlike the workflow commands in main_workflows.jl, these operate on
# intermediate pipeline databases (a prefilter result, an alignment result)
# rather than raw structure databases from createdb — they're the individual
# stages that `search`/`easy-search`/etc. chain together internally. Building
# such an intermediate DB directly requires the hidden `prefilter` command
# (reachable via `foldseek"prefilter ..."`, not a typed wrapper — it isn't
# one of the ~27 commands `foldseek -h` prints). Every option beyond the
# required positional arguments is available as a keyword argument via the
# `foldseek(subcommand, args...; kwargs...)` dispatcher. Positional argument
# order below is transcribed directly from each command's `-h` usage line,
# not re-derived.

export expandmultimer, tmalign, structurealign, structurerescorediagonal, aln2tmscore, scoremultimer, clust, result2profile

"""
    expandmultimer(querydb, targetdb, alignmentdb, prefilterdb; kwargs...)

Run `foldseek expandmultimer`: re-prefilter `alignmentdb` (an alignment
result between `querydb` and `targetdb`) to ensure complete alignment
coverage between multimers, writing the expanded prefilter result to
`prefilterdb`. Every `foldseek expandmultimer` CLI option is available as a
keyword argument; run `foldseek"expandmultimer -h"` for the full,
version-specific list.
"""
function expandmultimer(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, prefilterdb::AbstractString; kwargs...)
    return foldseek("expandmultimer", querydb, targetdb, alignmentdb, prefilterdb; kwargs...)
end

"""
    tmalign(querydb, targetdb, prefilterdb, resultdb; kwargs...)

Run `foldseek tmalign`: compute TM-scores for the query-target pairs in
`prefilterdb` (a prefilter result, e.g. from `foldseek"prefilter ..."`),
writing the alignment result to `resultdb`. Every `foldseek tmalign` CLI
option is available as a keyword argument; run `foldseek"tmalign -h"` for
the full, version-specific list.
"""
function tmalign(querydb::AbstractString, targetdb::AbstractString, prefilterdb::AbstractString, resultdb::AbstractString; kwargs...)
    return foldseek("tmalign", querydb, targetdb, prefilterdb, resultdb; kwargs...)
end

"""
    structurealign(querydb, targetdb, prefilterdb, resultdb; kwargs...)

Run `foldseek structurealign`: compute structural alignments (3Di alphabet,
amino acids, and neighborhood information) for the query-target pairs in
`prefilterdb` (a prefilter result), writing the alignment result to
`resultdb`. Every `foldseek structurealign` CLI option is available as a
keyword argument; run `foldseek"structurealign -h"` for the full,
version-specific list.
"""
function structurealign(querydb::AbstractString, targetdb::AbstractString, prefilterdb::AbstractString, resultdb::AbstractString; kwargs...)
    return foldseek("structurealign", querydb, targetdb, prefilterdb, resultdb; kwargs...)
end

"""
    structurerescorediagonal(querydb, targetdb, prefilterdb, resultdb; kwargs...)

Run `foldseek structurerescorediagonal`: compute sequence identity along the
diagonal for the query-target pairs in `prefilterdb` (a prefilter result),
writing the result to `resultdb`. Every `foldseek structurerescorediagonal`
CLI option is available as a keyword argument; run
`foldseek"structurerescorediagonal -h"` for the full, version-specific list.
"""
function structurerescorediagonal(querydb::AbstractString, targetdb::AbstractString, prefilterdb::AbstractString, resultdb::AbstractString; kwargs...)
    return foldseek("structurerescorediagonal", querydb, targetdb, prefilterdb, resultdb; kwargs...)
end

"""
    aln2tmscore(querydb, targetdb, alndb, resultdb; kwargs...)

Run `foldseek aln2tmscore`: compute TM-scores for the alignments in `alndb`
(an alignment database, e.g. from [`structurealign`](@ref)), writing the
result to `resultdb`. Every `foldseek aln2tmscore` CLI option is available
as a keyword argument; run `foldseek"aln2tmscore -h"` for the full,
version-specific list.
"""
function aln2tmscore(querydb::AbstractString, targetdb::AbstractString, alndb::AbstractString, resultdb::AbstractString; kwargs...)
    return foldseek("aln2tmscore", querydb, targetdb, alndb, resultdb; kwargs...)
end

"""
    scoremultimer(querydb, targetdb, alignmentdb, complexdb; kwargs...)

Run `foldseek scoremultimer`: derive multimer-level alignments from
`alignmentdb` (a chain-level alignment result between `querydb` and
`targetdb`), writing the result to `complexdb`. Every `foldseek
scoremultimer` CLI option is available as a keyword argument; run
`foldseek"scoremultimer -h"` for the full, version-specific list.
"""
function scoremultimer(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, complexdb::AbstractString; kwargs...)
    return foldseek("scoremultimer", querydb, targetdb, alignmentdb, complexdb; kwargs...)
end

"""
    clust(sequencedb, resultdb, clusterdb; kwargs...)

Run `foldseek clust`: cluster `sequencedb` by the pairwise results in
`resultdb` (e.g. from [`structurealign`](@ref) or `foldseek"prefilter ..."`),
using Set-Cover, Connected-Component, or Greedy-Incremental clustering
(`cluster_mode`), writing the result to `clusterdb`. Every `foldseek clust`
CLI option is available as a keyword argument; run `foldseek"clust -h"` for
the full, version-specific list.
"""
function clust(sequencedb::AbstractString, resultdb::AbstractString, clusterdb::AbstractString; kwargs...)
    return foldseek("clust", sequencedb, resultdb, clusterdb; kwargs...)
end

"""
    result2profile(querydb, targetdb, resultdb, profiledb; kwargs...)

Run `foldseek result2profile`: compute a profile database (amino acid and
3Di) at `profiledb` from `resultdb` (an alignment or prefilter result
between `querydb` and `targetdb`). Every `foldseek result2profile` CLI
option is available as a keyword argument; run `foldseek"result2profile -h"`
for the full, version-specific list.
"""
function result2profile(querydb::AbstractString, targetdb::AbstractString, resultdb::AbstractString, profiledb::AbstractString; kwargs...)
    return foldseek("result2profile", querydb, targetdb, resultdb, profiledb; kwargs...)
end
