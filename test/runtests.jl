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

    @testset "test fixtures" begin
        fixture_dir = joinpath(@__DIR__, "data")
        mktempdir() do dir
            db = joinpath(dir, "DB")
            foldseek(
                "createdb",
                joinpath(fixture_dir, "1tim.pdb.gz"),
                joinpath(fixture_dir, "8tim.pdb.gz"),
                db,
            )
            @test isfile(db)
            @test isfile(db * ".index")
        end
    end
end
