module Foldseek

using Foldseek_jll: Foldseek_jll

export foldseek, @foldseek_str

"""
    foldseek(args::Cmd)

Run the `foldseek` executable with `args`. Standard output streams live to
the caller; standard error is captured so that a failure can be reported with
the message `foldseek` actually printed. Returns the resulting `Process` on
success and throws an `ErrorException` — including the captured stderr — on a
nonzero exit code, rather than the less informative `ProcessFailedException`
that plain `run` would throw.
"""
function foldseek(args::Cmd)
    exe = Foldseek_jll.foldseek()
    cmd = `$exe $args`
    err = IOBuffer()
    proc = run(pipeline(ignorestatus(cmd); stderr=err))
    if !success(proc)
        message = String(take!(err))
        detail = isempty(message) ? "" : ":\n" * message
        error("foldseek exited with code $(proc.exitcode)$detail")
    end
    return proc
end

"""
    foldseek(subcommand::AbstractString, args::AbstractString...; kwargs...)

Run `foldseek subcommand args... --flag1 value1 --flag2 value2 ...`. Each
keyword argument becomes a long-form CLI flag: underscores in the key become
hyphens (`comp_bias_corr` → `--comp-bias-corr`), a `Bool` value becomes an
explicit `"0"`/`"1"` (Foldseek's `BOOL`-typed options require a value; they
are not bare presence/absence switches), and a value of `nothing` omits the
flag entirely so typed wrappers can use `nothing` as an "unset" default.
"""
function foldseek(subcommand::AbstractString, args::AbstractString...; kwargs...)
    parts = String[subcommand]
    append!(parts, String.(args))
    for (key, value) in pairs(kwargs)
        value === nothing && continue
        push!(parts, "--" * replace(String(key), '_' => '-'))
        push!(parts, flag_string(value))
    end
    return foldseek(Cmd(parts))
end

flag_string(value::Bool) = value ? "1" : "0"
flag_string(value) = string(value)

"""
    foldseek"subcommand args..."

Run a `foldseek` command written exactly as it would be on the command line,
e.g. `foldseek"easy-search query.pdb target.pdb result.m8 tmp"`. The string is
tokenized the way a shell would (quoted substrings containing spaces stay
together), via the same tokenizer Julia's own `` `cmd` `` literal uses
internally, then run through [`foldseek`](@ref)`(::Cmd)`.

This is the escape hatch for the ~150 `foldseek` commands that don't have a
typed Julia wrapper — every hidden foldseek command and everything inherited
from mmseqs2 (see `CLI_NOTES.md`) is still reachable this way.

Note: unlike `` `cmd` `` literals, this macro does **not** support
`\$`-interpolation of Julia values — Julia only special-cases interpolation
for the built-in backtick command syntax, not custom string macros. Build the
command with string interpolation first if needed, e.g.
`` foldseek(Cmd(["easy-search", queryfile, targetfile, "result.m8", "tmp"])) ``
or the [`foldseek`](@ref)`(subcommand, args...; kwargs...)` method.
"""
macro foldseek_str(s)
    return :(foldseek(Cmd($(Base.shell_split(s)))))
end

include("easy_workflows.jl")
include("main_workflows.jl")
include("database_commands.jl")

end
