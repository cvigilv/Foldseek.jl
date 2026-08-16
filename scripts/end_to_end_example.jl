# Reproduces a full Foldseek workflow end to end through the Julia wrapper
# alone: build structure databases from PDB files, search one against the
# other, and convert the alignment result to a plain tabular file.
#
# Run from the package root:
#   julia --project=. scripts/end_to_end_example.jl

using Foldseek

fixture_dir = joinpath(@__DIR__, "..", "test", "data")
query_structure = joinpath(fixture_dir, "1tim.pdb.gz")
target_structure = joinpath(fixture_dir, "8tim.pdb.gz")

mktempdir() do dir
    querydb = joinpath(dir, "queryDB")
    targetdb = joinpath(dir, "targetDB")
    createdb(query_structure, querydb)
    createdb(target_structure, targetdb)

    alignmentdb = joinpath(dir, "alnDB")
    search(querydb, targetdb, alignmentdb, joinpath(dir, "tmp"))

    resultfile = joinpath(dir, "result.m8")
    hits = convertalis(querydb, targetdb, alignmentdb, resultfile)

    println("Found $(length(hits)) alignment(s) between 1TIM and 8TIM:\n")
    for hit in hits
        println(
            "  ", hit.query, " vs ", hit.target,
            ": ", round(100 * hit.fident; digits=1), "% identity over ",
            hit.alnlen, " residues (E-value ", hit.evalue, ")",
        )
    end
end
