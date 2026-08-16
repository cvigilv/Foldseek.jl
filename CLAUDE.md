# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this package is

Foldseek.jl is a thin Julia wrapper around [Foldseek_jll.jl](https://github.com/JuliaBinaryWrappers/Foldseek_jll.jl), the binary-artifact package for [Foldseek](https://github.com/steineggerlab/foldseek) (fast and sensitive protein structure searching). It does not reimplement any Foldseek functionality — it just exposes a Julia-friendly way to invoke the bundled `foldseek` executable.

The whole package is `src/Foldseek.jl`: a single `foldseek(args::Cmd)` function that resolves the JLL-provided executable and runs it with the given arguments, e.g. `foldseek(`easy-search query.pdb target.pdb result.m8 tmp`)`.

## Commands

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'   # resolve deps (Foldseek_jll from General)
julia --project=. -e 'using Pkg; Pkg.test()'           # run test/runtests.jl
```

To run a single test, filter with `Test.@testset` names or run the file directly via `julia --project=. test/runtests.jl` after adding `Test` to `LOAD_PATH`/activating the test env — for a package this small, editing `test/runtests.jl` directly is usually simplest.

## Notes for changes

- `Foldseek_jll.foldseek()` (no do-block) returns a `Cmd` pointing at the artifact executable; the do-block form is deprecated by JLLWrappers. Build commands as `foldseek(`$(Foldseek_jll.foldseek()) subcommand args...`)`.
- Bumping the `Foldseek_jll` compat bound in `Project.toml` is how this package picks up new upstream Foldseek releases; there's no vendored logic to update.
