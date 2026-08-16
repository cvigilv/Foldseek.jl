using Foldseek
using Test

@testset "Foldseek.jl" begin
    @test foldseek(`version`) isa Base.Process
end
