using Dates
const logfile = open(joinpath(@__DIR__, "juliaformatter.log"), "w")

function log(msg; spacer = " ")
    write(logfile, "[$(Dates.now())]$spacer$msg\n")
    flush(logfile)
end

try
    using Pkg
    Pkg.instantiate()

    using JuliaFormatter
    using JSON
catch
    project_path = joinpath(@__DIR__, "..")
    log("Cannot Instantiate the project! Install dependencies by yourself: `julia --project=$project_path -e 'using Pkg; Pkg.add(\"JuliaFormatter\"); Pkg.add(\"JSON\")'`")
    exit(1)
end

format_text("")



const CONFIG_FILE_NAME = JuliaFormatter.CONFIG_FILE_NAME

function find_config_file(dir)
    dir2config = Dict{String,Any}()
    next_dir = dirname(dir)
    config = if (next_dir == dir || # ensure to escape infinite recursion
                 isempty(dir)) # reached to the system root
        nothing
    elseif haskey(dir2config, dir)
        dir2config[dir]
    else
        path = joinpath(dir, CONFIG_FILE_NAME)
        isfile(path) ? JuliaFormatter.parse_config(path) : find_config_file(next_dir)
    end
    return dir2config[dir] = config
end

function main()
    server_state = "start"
    while server_state != "quit"
        text = readline(stdin)
        data = String(text)
        format_options = Dict{Symbol,Any}()
        if length(data) == 0
            continue
        end
        try
            data = JSON.parse(String(data))
        catch e
            iob = IOBuffer()
            showerror(iob, e, catch_backtrace())
            log("Unable to parse json: \"$data\". $(String(take!(iob)))")
            continue
        end
        if data["method"] == "exit"
            server_state = "quit"
        elseif data["method"] == "isconnectedcheck"
            log("Connected.")
        elseif data["method"] == "format"
            log("Setting up defaults ...")
            text = data["params"]["text"]
            options = data["params"]["options"]
            filepath = data["params"]["filepath"]
            style = pop!(options, "style", nothing)
            style = if style == "blue"
                BlueStyle()
            elseif style == "yas"
                YASStyle()
            elseif style == nothing || style == "default"
                DefaultStyle()
            else
                log("Unknown style option $style")
                DefaultStyle()
            end
            for (k, v) in options
                format_options[Symbol(k)] = v
            end
            format_options[:style] = style
            log("Searching for .JuliaFormatter.toml ...")
            dir = dirname(filepath)
            format_options = if (config = find_config_file(dir)) !== nothing
                log("Found .JuliaFormatter.toml with config: $config")
                merge(format_options, config)
            else
                log("No .JuliaFormatter.toml")
                format_options
            end
            log("Using options: $format_options with style: $(format_options[:style])")
            output = text
            indent = typemax(Int64)
            for line in text
                if length(line) > 0
                    indent = min(length(line) - length(lstrip(line)), indent)
                end
            end
            if indent == typemax(Int64)
                indent = 0
            end
            log("Formatting: ")
            log(join(text, "\n"), spacer = "\n")
            try
                output = format_text(join(text, "\n"); format_options...)
                data["status"] = "success"
                log("Success")
            catch e
                output = join(text, "\n")
                data["status"] = "error"
                iob = IOBuffer()
                showerror(iob, e, catch_backtrace())
                log(String(take!(iob)))
            end
            log("\n---------------------------------------------------------------------\n")
            log("Formatted: ")
            log(output, spacer = "\n")
            data["params"]["text"] = [rstrip(lpad(l, length(l) + indent)) for l in split(output, "\n")]
            println(stdout, JSON.json(data))
            log("Done.")
        end
    end

    log("exiting ...")
end

log("calling main ...")

try
    main()
catch e
    iob = IOBuffer()
    showerror(iob, e, catch_backtrace())
    log(String(take!(iob)))
end
