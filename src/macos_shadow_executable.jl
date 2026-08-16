# On macOS, Foldseek_jll's binary has no local `lib/` directory bundling its
# @rpath dependencies (libz, libbz2, libomp) — it resolves them entirely via
# DYLD_FALLBACK_LIBRARY_PATH, which Julia injects only for the top-level
# process it spawns directly. Many `foldseek` commands (easy-*, search,
# cluster, createindex, createsubdb, ...) internally re-invoke `foldseek` as
# a nested subprocess via `/bin/sh`, and macOS's dyld strips DYLD_*
# environment variables across an exec into that SIP-protected system
# binary, so the nested process can't find its dependencies and aborts.
#
# The binary's own LC_RPATH is `@loader_path/../lib`, so satisfying that
# locally — independent of environment variables — fixes nested invocations
# universally. `@loader_path` resolves from the executable's real on-disk
# location rather than whatever invocation path led there, so a symlink to
# the real binary does not satisfy it (confirmed empirically): the binary
# itself must physically reside next to a `lib/` directory. Rather than
# writing into the Pkg-managed artifact directory, a real copy of the binary
# is cached in scratch space, alongside symlinks to its runtime library
# dependencies.

using Zlib_jll: Zlib_jll
using Bzip2_jll: Bzip2_jll
using LLVMOpenMP_jll: LLVMOpenMP_jll
using Scratch: @get_scratch!

const _macos_shadow_exe = Ref{Union{Nothing, String}}(nothing)

function _macos_shadow_executable()
    cached = _macos_shadow_exe[]
    cached === nothing || return cached

    source = only(Foldseek_jll.foldseek().exec)
    dir = @get_scratch!("foldseek-macos-shadow")
    bindir = joinpath(dir, "bin")
    libdir = joinpath(dir, "lib")
    exe = joinpath(bindir, "foldseek")
    marker = joinpath(dir, "source")

    if !isfile(exe) || !isfile(marker) || read(marker, String) != source
        mkpath(bindir)
        mkpath(libdir)
        cp(source, exe; force = true)
        chmod(exe, 0o755)
        # Target names are the exact `@rpath/...` dependency names `foldseek`
        # declares (see `otool -L`), which do not always match the on-disk
        # filename of the JLL-provided library (e.g. Zlib_jll currently
        # provides `libz.1.3.1.dylib`, but the binary looks specifically for
        # `libz.1.dylib`) — dyld resolves by exact name, not by prefix match.
        for (target_name, libpath) in (
                "libz.1.dylib" => Zlib_jll.libz_path,
                "libbz2.1.0.dylib" => Bzip2_jll.libbzip2_path,
                "libomp.dylib" => LLVMOpenMP_jll.libomp_path,
            )
            target = joinpath(libdir, target_name)
            ispath(target) && rm(target; force = true)
            symlink(libpath, target)
        end
        write(marker, source)
    end

    _macos_shadow_exe[] = exe
    return exe
end
