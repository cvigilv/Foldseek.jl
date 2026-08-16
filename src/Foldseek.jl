module Foldseek

using Foldseek_jll: Foldseek_jll

export foldseek

"""
    foldseek(args::Cmd)

Run the `foldseek` executable with `args`, forwarding stdout/stderr, and
return the resulting `Process`.
"""
function foldseek(args::Cmd)
    exe = Foldseek_jll.foldseek()
    return run(`$exe $args`)
end

end
