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
        # Foldseek's `easy-*` commands are internally implemented as shell
        # scripts that re-invoke the `foldseek` binary as a subprocess for
        # each stage; that nested invocation can fail to find a shared
        # library depending on the platform's dynamic linker behavior,
        # regardless of whether the given paths are valid, so a full
        # successful run isn't a portable thing to assert on here.
        # Flag validation happens in the same top-level process before any
        # internal script runs, so a deliberately-bad flag is a reliable,
        # environment-independent way to confirm each wrapper reaches the CLI
        # with the right subcommand name and the right positional arg count —
        # if either were wrong, foldseek would report a path-count error
        # instead of ever reaching flag validation.
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

        # search, rbh, cluster, multimercluster, and multimersearch are all
        # internally implemented as shell-script workflows that re-invoke
        # `foldseek` as a subprocess (confirmed for search and cluster; the
        # same pattern is expected to hold for the rest), so — as with the
        # easy-* commands — a full run isn't portable to assert on here, and
        # flag validation (which happens before any internal script runs) is
        # used instead to confirm subcommand routing and positional arg shape.
        @test_throws "Unrecognized parameter" search("a", "b", "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" rbh("a", "b", "c", "d"; bad_flag=1)
        @test_throws "Unrecognized parameter" cluster("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" multimercluster("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" multimersearch("a", "b", "c", "d"; bad_flag=1)
    end

    @testset "database-and-set commands" begin
        # createindex and createsubdb were confirmed (like search/cluster
        # before them) to be shell-script workflows hitting the same
        # nested-subprocess limitation; databases genuinely downloads
        # multi-gigabyte reference data, which is never appropriate to run in
        # a test suite regardless of environment. All four are tested via
        # flag validation only, consistent with every other command chunk
        # where a full run isn't a portable thing to assert on.
        @test_throws "Unrecognized parameter" databases("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" createindex("a", "b"; bad_flag=1)
        @test_throws "Unrecognized parameter" createclusearchdb("a", "b", "c"; bad_flag=1)
        @test_throws "Unrecognized parameter" createsubdb("a", "b", "c"; bad_flag=1)
    end
end
