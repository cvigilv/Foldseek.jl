# Typed wrappers for the "Format conversion" section of `foldseek -h`:
# convertalis, compressca, convert2pdb, createmultimerreport.
#
# Every option beyond the required positional arguments is available as a
# keyword argument via the `foldseek(subcommand, args...; kwargs...)`
# dispatcher — see its docstring for the flag-naming and Bool/nothing
# conventions. Positional argument order below is transcribed directly from
# each command's `-h` usage line, not re-derived.

export convertalis, compressca, convert2pdb, createmultimerreport

const CONVERTALIS_DEFAULT_COLUMNS = "query,target,fident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits"

function _convertalis_field(s::AbstractString)
    i = tryparse(Int, s)
    i === nothing || return i
    f = tryparse(Float64, s)
    f === nothing || return f
    return String(s)
end

function _convertalis_row(line::AbstractString, columns::Vector{Symbol})
    fields = split(line, '\t')
    if length(fields) != length(columns)
        error(
            "convertalis output line has $(length(fields)) columns but $(length(columns)) were expected from format_output; " *
            "pass a matching `format_output` value, or omit `format_mode`/use `format_mode=0` (the only mode this parses).",
        )
    end
    return NamedTuple{Tuple(columns)}(Tuple(_convertalis_field(f) for f in fields))
end

"""
    convertalis(querydb, targetdb, alignmentdb, alignmentfile; kwargs...)

Run `foldseek convertalis`, converting the alignment database `alignmentdb`
(produced by e.g. [`search`](@ref)) into a tabular alignment file at
`alignmentfile`, then parse that file into a `Vector` of `NamedTuple`s — one
entry per alignment, one field per output column. The column set comes from
the `format_output` keyword argument if given, otherwise from `foldseek
convertalis`'s own default column set
(`"query,target,fident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits"`).
Each field is parsed as an `Int`, then a `Float64`, then left as a `String`,
since the available columns (and each one's natural type) are
version-specific — run `foldseek"convertalis -h"` for the full list.

Parsing assumes the default `--format-mode` (0, tab-separated BLAST-TAB);
other format modes (SAM, HTML, superposed PDB) aren't tabular per
`format_output`, and a row with the wrong number of fields raises an error
rather than returning malformed data. Every other `foldseek convertalis` CLI
option is available as a keyword argument.
"""
function convertalis(querydb::AbstractString, targetdb::AbstractString, alignmentdb::AbstractString, alignmentfile::AbstractString; kwargs...)
    foldseek("convertalis", querydb, targetdb, alignmentdb, alignmentfile; kwargs...)
    columns = Symbol.(split(get(kwargs, :format_output, CONVERTALIS_DEFAULT_COLUMNS), ','))
    return [_convertalis_row(line, columns) for line in eachline(alignmentfile)]
end

"""
    compressca(db, cadb; kwargs...)

Run `foldseek compressca`: write a compressed C-alpha-coordinate database at
`cadb` from `db` (an existing Foldseek database). Every `foldseek compressca`
CLI option is available as a keyword argument; run `foldseek"compressca -h"`
for the full, version-specific list.
"""
function compressca(db::AbstractString, cadb::AbstractString; kwargs...)
    return foldseek("compressca", db, cadb; kwargs...)
end

"""
    convert2pdb(db, pdbout; kwargs...)

Run `foldseek convert2pdb`: convert `db` (an existing Foldseek structure
database) to PDB format at `pdbout`, either a single multi-model file or a
directory of one-file-per-chain/complex, depending on `pdb_output_mode`.
Every `foldseek convert2pdb` CLI option is available as a keyword argument;
run `foldseek"convert2pdb -h"` for the full, version-specific list.
"""
function convert2pdb(db::AbstractString, pdbout::AbstractString; kwargs...)
    return foldseek("convert2pdb", db, pdbout; kwargs...)
end

"""
    createmultimerreport(querydb, targetdb, complexdb, complexfile; kwargs...)

Run `foldseek createmultimerreport`: convert `complexdb` (a multimer-level
result database, e.g. from `multimersearch`) into a tabular report at
`complexfile`, using `querydb` and `targetdb` for identifier lookup. Every
`foldseek createmultimerreport` CLI option is available as a keyword
argument; run `foldseek"createmultimerreport -h"` for the full,
version-specific list.
"""
function createmultimerreport(querydb::AbstractString, targetdb::AbstractString, complexdb::AbstractString, complexfile::AbstractString; kwargs...)
    return foldseek("createmultimerreport", querydb, targetdb, complexdb, complexfile; kwargs...)
end
