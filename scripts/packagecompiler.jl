using PackageCompiler

const EXT = if Sys.isapple()
    ".dylib"
elseif Sys.iswindows()
    ".dll"
elseif Sys.islinux()
    ".so"
else
    @warn "This operating system may not be supported."
    ".so"
end

PackageCompiler.create_sysimage(
    [:JuliaFormatter, :JSON];
    precompile_execution_file=joinpath(@__DIR__, "precompile.jl"),
    sysimage_path=joinpath(@__DIR__, "juliaformatter$EXT")
)
