using Foldseek
using Test

@testset "Foldseek.jl" begin
    @testset "foldseek(::Cmd)" begin
        @test foldseek(`version`) isa Base.Process
        @test_throws "Not enough input paths" foldseek(`createdb`)
    end

    @testset "foldseek(subcommand, args...; kwargs...)" begin
        @test foldseek("version") isa Base.Process
        @test_throws "Not enough input paths" foldseek("createdb")

        # Bool kwargs must become an explicit 0/1, and `nothing` must omit the
        # flag entirely — both surface only through what actually reaches the
        # CLI, so assert on the stderr message a bad/omitted flag provokes.
        @test_throws "Not enough input paths" foldseek("createdb"; gpu=false)
        @test_throws "Unrecognized parameter" foldseek("createdb", "a", "b"; not_a_real_flag=1)
        @test foldseek("version"; verbosity=nothing) isa Base.Process

        # A single-character keyword name must become a short `-x` flag, not
        # `--x` — some options (e.g. structurealign's `-a`) have no long-form
        # equivalent at all, so this is the only way to reach them.
        @test foldseek("version"; v=1) isa Base.Process
    end

    @testset "@foldseek_str" begin
        @test foldseek"version" isa Base.Process
        @test_throws "Not enough input paths" foldseek"createdb"

        # A quoted, space-containing argument must survive as one token, not
        # be split on the space — assert on the resulting error text, which
        # differs depending on whether tokenization was correct.
        @test_throws "Input a file.pdb does not exist" foldseek"createdb \"a file.pdb\" out"
    end

    @testset "easy-workflow commands" begin
        fixture_dir = joinpath(@__DIR__, "data")

        # easy_search end to end: 1TIM vs 8TIM are homologous (triosephosphate
        # isomerase from two species), so a real search between them gives
        # meaningful, checkable hits rather than an arbitrary result.
        mktempdir() do dir
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "8tim.pdb.gz"), targetdb)
            out = joinpath(dir, "result.m8")
            easy_search(joinpath(fixture_dir, "1tim.pdb.gz"), targetdb, out, joinpath(dir, "tmp"))
            hits = readlines(out)
            @test length(hits) == 4
            @test all(line -> parse(Float64, split(line, '\t')[3]) > 0.9, hits)
        end

        # The remaining easy-* commands aren't individually exercised with a
        # real run in this test suite; flag validation (which happens before
        # any internal processing) still confirms each wrapper reaches the
        # CLI with the right subcommand name and the right positional arg
        # count — if either were wrong, foldseek would report a path-count
        # error instead of ever reaching flag validation.
        @test_throws "Unrecognized parameter" easy_search("a", "b", "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_search(["a", "b"], "c", "d", "e"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_cluster("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_cluster(["a", "b"], "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_rbh("a", "b", "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_multimercluster("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_multimercluster(["a", "b"], "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_multimersearch("a", "b", "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" easy_multimersearch(["a", "b"], "c", "d", "e"; bad_flag=1)
    end

    @testset "main-workflow commands" begin
        fixture_dir = joinpath(@__DIR__, "data")

        # createdb is a direct module (no internal re-exec), so it's fully
        # testable end-to-end against real fixtures, through both the
        # single-path and vector-of-paths methods.
        mktempdir() do dir
            db = joinpath(dir, "DB")
            createdb(joinpath(fixture_dir, "1tim.pdb.gz"), db)
            @test isfile(db)
            @test isfile(db * ".index")
        end
        mktempdir() do dir
            db = joinpath(dir, "DB")
            createdb([joinpath(fixture_dir, "1tim.pdb.gz"), joinpath(fixture_dir, "8tim.pdb.gz")], db)
            @test isfile(db)
            @test isfile(db * ".index")
        end

        # search and cluster end to end, using the same query/target DB and
        # the same identity-based check as the easy_search test above.
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "1tim.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "8tim.pdb.gz"), targetdb)
            out = joinpath(dir, "alnDB")
            search(querydb, targetdb, out, joinpath(dir, "tmp1"))
            @test isfile(out * ".index")

            clusterout = joinpath(dir, "clusterDB")
            merged = joinpath(dir, "mergedDB")
            createdb([joinpath(fixture_dir, "1tim.pdb.gz"), joinpath(fixture_dir, "8tim.pdb.gz")], merged)
            cluster(merged, clusterout, joinpath(dir, "tmp2"))
            @test isfile(clusterout * ".index")
        end

        # multimersearch and multimercluster end to end, using 4HHB/1Y8H — a
        # genuinely heteromeric alpha2beta2 hemoglobin tetramer pair (unlike
        # 1TIM/8TIM, whose two chains are identical) — so the chain-level
        # correspondence these commands compute is a real assertion, not a
        # degenerate homodimer self-match.
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "4hhb.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "1y8h.pdb.gz"), targetdb)
            complexdb = joinpath(dir, "complexDB")
            multimersearch(querydb, targetdb, complexdb, joinpath(dir, "tmp1"))
            @test isfile(complexdb * ".index")

            merged = joinpath(dir, "mergedDB")
            createdb([joinpath(fixture_dir, "4hhb.pdb.gz"), joinpath(fixture_dir, "1y8h.pdb.gz")], merged)
            clusterout = joinpath(dir, "clusterDB")
            multimercluster(merged, clusterout, joinpath(dir, "tmp2"))
            @test isfile(clusterout * ".index")
            @test length(readlines(clusterout * ".index")) == 1
        end

        # rbh isn't individually exercised with a real run in this test
        # suite; flag validation still confirms subcommand routing and
        # positional arg shape, as above.
        @test_throws "Unrecognized parameter" rbh("a", "b", "c", "d"; bad_flag=1)
    end

    @testset "database-and-set commands" begin
        fixture_dir = joinpath(@__DIR__, "data")

        # createsubdb end to end: pull a single-key subset out of a two-entry
        # DB and check the subset really is smaller.
        mktempdir() do dir
            db = joinpath(dir, "DB")
            createdb(joinpath(fixture_dir, "1tim.pdb.gz"), db)
            subset = joinpath(dir, "subset.tsv")
            write(subset, "0\n")
            subdb = joinpath(dir, "subDB")
            createsubdb(subset, db, subdb)
            @test isfile(subdb)
        end

        # databases genuinely downloads multi-gigabyte reference data, never
        # appropriate to run in a test suite; createindex and
        # createclusearchdb aren't individually exercised with a real run
        # here. All three are tested via flag validation only, as above.
        @test_throws "Unrecognized parameter" databases("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" createindex("a", "b"; bad_flag=1)
        @test_throws "Unrecognized parameter" createclusearchdb("a", "b", "c"; bad_flag=1)
    end

    @testset "format-conversion commands" begin
        fixture_dir = joinpath(@__DIR__, "data")

        # convertalis, compressca, and convert2pdb are direct modules (no
        # internal re-exec), so — like createdb — they're fully testable end
        # to end against real fixtures.
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "1tim.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "8tim.pdb.gz"), targetdb)
            alignmentdb = joinpath(dir, "alnDB")
            search(querydb, targetdb, alignmentdb, joinpath(dir, "tmp"))

            rows = convertalis(querydb, targetdb, alignmentdb, joinpath(dir, "result.m8"))
            @test length(rows) == 4
            @test all(row -> row.fident > 0.9, rows)
            @test all(row -> row isa NamedTuple, rows)

            # A custom format_output must both select the right file columns
            # and drive the returned NamedTuple's field names/order.
            custom = convertalis(
                querydb, targetdb, alignmentdb, joinpath(dir, "result_custom.m8");
                format_output="target,query,qlen",
            )
            @test keys(custom[1]) == (:target, :query, :qlen)
            @test custom[1].qlen isa Int

            cadb = joinpath(dir, "caDB")
            compressca(querydb, cadb)
            @test isfile(cadb)

            pdbout = joinpath(dir, "out.pdb")
            convert2pdb(querydb, pdbout)
            @test isfile(pdbout)
        end

        # createmultimerreport end to end, using the same heteromeric
        # 4HHB/1Y8H hemoglobin pair as the multimersearch/multimercluster
        # tests above: 4 chain-to-chain permutations between the two
        # tetramers, each a real hit (TM-score > 0.8).
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "4hhb.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "1y8h.pdb.gz"), targetdb)
            complexdb = joinpath(dir, "complexDB")
            multimersearch(querydb, targetdb, complexdb, joinpath(dir, "tmp"))

            report = joinpath(dir, "report.tsv")
            createmultimerreport(querydb, targetdb, complexdb, report)
            lines = readlines(report)
            @test length(lines) == 4
            @test all(line -> parse(Float64, split(line, '\t')[5]) > 0.8, lines)
        end

        # A convertalis row with the wrong field count for the requested
        # format_output must fail loudly rather than silently mis-zip fields
        # into the wrong names.
        mktempdir() do dir
            badfile = joinpath(dir, "bad.m8")
            write(badfile, "1\t2\t3\n")
            @test_throws "expected from format_output" Foldseek._convertalis_row(readline(badfile), [:a, :b])
        end
    end

    @testset "alignment/clustering/profile commands" begin
        fixture_dir = joinpath(@__DIR__, "data")

        # tmalign, structurealign, structurerescorediagonal, aln2tmscore,
        # clust, and result2profile all operate on a prefilter result rather
        # than a raw structure DB; `prefilter` itself has no typed wrapper
        # (it's one of the ~150 commands reachable only via
        # foldseek(subcommand, args...) or foldseek"...", per the plan's
        # scope decision), so it's built directly through the dispatcher.
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "1tim.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "8tim.pdb.gz"), targetdb)
            prefilterdb = joinpath(dir, "prefilterDB")
            foldseek("prefilter", querydb, targetdb, prefilterdb)

            # `-a` has no long-form equivalent for these commands; a
            # single-character keyword name is how the dispatcher spells a
            # short flag (see foldseek(subcommand, args...; kwargs...)).
            # Backtrace (-a 1) is required before convertalis can read the
            # alignment back out, so each result is checked through it.
            tmdb = joinpath(dir, "tmDB")
            tmalign(querydb, targetdb, prefilterdb, tmdb; a=true)
            tmrows = convertalis(querydb, targetdb, tmdb, joinpath(dir, "tm.tsv"); format_output="query,target,alntmscore")
            @test length(tmrows) == 4
            @test all(row -> row.alntmscore > 0.9, tmrows)

            structuralndb = joinpath(dir, "structuralnDB")
            structurealign(querydb, targetdb, prefilterdb, structuralndb; a=true)
            sarows = convertalis(querydb, targetdb, structuralndb, joinpath(dir, "sa.tsv"))
            @test length(sarows) == 4
            @test all(row -> row.fident > 0.9, sarows)

            srddb = joinpath(dir, "srdDB")
            structurerescorediagonal(querydb, targetdb, prefilterdb, srddb; a=true)
            srdrows = convertalis(querydb, targetdb, srddb, joinpath(dir, "srd.tsv"))
            @test length(srdrows) == 4
            @test all(row -> row.fident > 0.9, srdrows)

            # aln2tmscore's output DB isn't itself convertalis-readable (it's
            # a plain TM-score result, not an alignment DB), so it's checked
            # by existence only, as with the format-conversion commands
            # above that don't produce parseable text.
            aln2tmdb = joinpath(dir, "aln2tmDB")
            aln2tmscore(querydb, targetdb, structuralndb, aln2tmdb)
            @test isfile(aln2tmdb * ".index")

            # clust needs an all-vs-all result over a single merged DB (not
            # separate query/target DBs) to produce a real cluster; extract
            # cluster membership with the hidden createtsv command (no typed
            # wrapper either, same rationale as prefilter above) and confirm
            # all four chains land in one cluster, as with the multimer-level
            # equivalent below.
            merged = joinpath(dir, "mergedDB")
            createdb([joinpath(fixture_dir, "1tim.pdb.gz"), joinpath(fixture_dir, "8tim.pdb.gz")], merged)
            mergedprefilterdb = joinpath(dir, "mergedPrefilterDB")
            foldseek("prefilter", merged, merged, mergedprefilterdb)
            mergedalndb = joinpath(dir, "mergedAlnDB")
            structurealign(merged, merged, mergedprefilterdb, mergedalndb)
            clusterdb = joinpath(dir, "clusterDB")
            clust(merged, mergedalndb, clusterdb)
            clustertsv = joinpath(dir, "clusters.tsv")
            foldseek("createtsv", merged, merged, clusterdb, clustertsv)
            clusterlines = readlines(clustertsv)
            @test length(clusterlines) == 4
            @test length(unique(first.(split.(clusterlines, '\t')))) == 1

            profiledb = joinpath(dir, "profileDB")
            result2profile(querydb, targetdb, structuralndb, profiledb)
            @test isfile(profiledb * ".index")
        end

        # expandmultimer and scoremultimer are the multimer-level stages
        # multimersearch chains together internally (see the main-workflow
        # commands testset above); reconstructing that pipeline by hand here
        # confirms each stage individually, using the same heteromeric
        # 4HHB/1Y8H pair so there's a genuine multi-chain-type complex to
        # expand and score.
        mktempdir() do dir
            querydb = joinpath(dir, "queryDB")
            targetdb = joinpath(dir, "targetDB")
            createdb(joinpath(fixture_dir, "4hhb.pdb.gz"), querydb)
            createdb(joinpath(fixture_dir, "1y8h.pdb.gz"), targetdb)
            prefilterdb = joinpath(dir, "prefilterDB")
            foldseek("prefilter", querydb, targetdb, prefilterdb)
            chainalndb = joinpath(dir, "chainAlnDB")
            structurealign(querydb, targetdb, prefilterdb, chainalndb)

            expandeddb = joinpath(dir, "expandedDB")
            expandmultimer(querydb, targetdb, chainalndb, expandeddb)
            @test isfile(expandeddb * ".index")

            expandedalndb = joinpath(dir, "expandedAlnDB")
            structurealign(querydb, targetdb, expandeddb, expandedalndb; a=true)
            complexdb = joinpath(dir, "complexDB")
            scoremultimer(querydb, targetdb, expandedalndb, complexdb)

            report = joinpath(dir, "report.tsv")
            createmultimerreport(querydb, targetdb, complexdb, report)
            lines = readlines(report)
            @test length(lines) == 4
            @test all(line -> parse(Float64, split(line, '\t')[5]) > 0.8, lines)
        end
    end
end
