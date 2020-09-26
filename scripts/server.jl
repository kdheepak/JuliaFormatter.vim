using Pkg
Pkg.instantiate()

using JuliaFormatter
using Dates
using JSON

format_text("")

const logfile = open(joinpath(@__DIR__, "juliaformatter.log"), "w")

function log(msg; spacer = " ")
    write(logfile, "[$(Dates.now())]$spacer$msg\n")
    flush(logfile)
end

format_options = Dict{Symbol, Any}()

function main()
    server_state = "start"
    while server_state != "quit"
        log("waiting for stdin ... ")
        text = readavailable(stdin)
        data_lines = String(text)
        log("received text: $data_lines")
        for data in split(data_lines, '\n')
            try
                data = JSON.parse(String(data))
            catch e
                log("Unable to parse json: $data. $e")
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
                for (k,v) in options
                    format_options[Symbol(k)] = v
                end
                log("Using options: $format_options with style: $style")
                output = text
                indent = typemax(Int64)
                for line in text
                    if length(line) > 0
                        indent = min(length(line) - length(lstrip(line)), indent)
                    end
                end
                log("Formatting: ")
                log(join(text, "\n"), spacer = "\n")
                try
                    output = format_text(join(text, "\n"), style; format_options...)
                    log("Success")
                    data["status"] = "success"
                catch e
                    log("failed $e")
                    output = join(text, "\n")
                    data["status"] = "error"
                end
                log("\n---------------------------------------------------------------------\n")
                log("Formatted: ")
                log(output, spacer = "\n")
                data["params"]["text"] =
                    [rstrip(lpad(l, length(l) + indent)) for l in split(output, "\n")]
                println(stdout, JSON.json(data))
                log("Done.")
            end
        end
    end

    log("exiting ...")
end

log("calling main ...")

main()
