# Converts every structure file in a directory into its Foldseek 3Di
# structural sequence (one FASTA entry per chain).
#
# createdb builds one database per representation from the same input:
# DB (amino acid sequence), DB_ss (3Di structural sequence), and DB_ca
# (C-alpha coordinates). DB_ss has no header sub-database of its own, so
# convert2fasta needs one linked in via lndb before it can label each
# entry — both are commands with no typed wrapper (out of scope per
# CLI_NOTES.md), reached directly through the dispatcher.
#
# Run from the package root:
#   julia --project=. scripts/structures_to_3di.jl [directory]
# With no argument, converts the structures bundled under test/data/.

using Foldseek

structure_dir = length(ARGS) >= 1 ? ARGS[1] : joinpath(@__DIR__, "..", "test", "data")

mktempdir() do dir
    db = joinpath(dir, "DB")
    createdb(structure_dir, db)
    foldseek("lndb", db * "_h", db * "_ss_h")

    fastafile = joinpath(dir, "DB_ss.fasta")
    foldseek("convert2fasta", db * "_ss", fastafile)

    print(read(fastafile, String))
end
