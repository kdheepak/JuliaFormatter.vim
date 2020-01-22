using   Pkg

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath( @__DIR__, "..","deps","deps.jl")

if !isfile(depsjl_path)




    error("Package not installed properly, run Pkg.build(\"Package\"), restart Julia and try again",)
end
include(depsjl_path)

# Module initialization function
function __init__()
# Always check your dependencies from `deps.jl`
check_deps(   )
end


include(joinpath("..", "deps", "build.jl"))

const MaybeFloat64 = Union{Float64, Nothing }

function foo(
    x ::Union{Nothing,Vector{UInt}} = nothing,
    y:: Union{Nothing,UInt64} = nothing;
    z :: Bool = true,
    a::AbstractString="John Doe",
    b::Integer= 12345,
    c::AbstractString ="XYZ\n\nABC",
)

    for i in 1:b

        println( x[i] )
    end

end

    function foo(
        x ::Union{Nothing,Vector{UInt}} = nothing,
        y:: Union{Nothing,UInt64} = nothing;
        z :: Bool = true,
        a::AbstractString="John Doe",
        b::Integer= 12345,
        c::AbstractString ="XYZ\n\nABC",
    )

        for i in 1:b

            println( x[i] )
        end

    end
