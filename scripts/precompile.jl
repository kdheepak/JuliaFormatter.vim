using JuliaFormatter
using JSON

function main()
    # Data read from `test/test.jl`
    text = JSON.json(Dict(
        "method" => "format",
        "params" => Dict("text" => String(read(abspath(joinpath(@__DIR__, "..", "tests", "test.jl")))))
    ))
    data = JSON.parse(String(text))
    text = data["params"]["text"]
    output = text
    indent = typemax(Int64)
    format_options = Dict{Symbol,Any}()
    for line in split(text, '\n')
        if length(line) > 0
            indent = min(length(line) - length(lstrip(line)), indent)
        end
    end
    output = format_text(text; format_options...)
    data["status"] = "success"
    data["params"]["text"] =
        [rstrip(lpad(l, length(l) + indent)) for l in split(output, "\n")]
    println(stdout, JSON.json(data))
end

main()
