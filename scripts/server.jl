using JuliaFormatter
using Dates
using JSON

format_text("")

const logfile = open(joinpath(@__DIR__, "juliaformatter.log"), "w")

function log(msg; spacer = " ")
    write(logfile, "[$(Dates.now())]$spacer$msg\n")
    flush(logfile)
end

function main()

    server_state = "start"
    while server_state != "quit"
        text = readavailable(stdin)
        data = JSON.parse(String(text))
        if data["method"] == "exit"
            server_state = "quit"
        elseif data["method"] == "format"
            text = data["params"]["text"]
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
                output = format_text(
                    join(text, "\n"),
                    indent = 4,
                    margin = 92,
                    always_for_in = false,
                    whitespace_typedefs = false,
                    whitespace_ops_in_indices = true,
                )
                data["status"] = "success"
            catch
                log("failed")
                output = join(text, "\n")
                data["status"] = "error"
            end
            log("\n---------------------------------------------------------------------\n")
            log(output, spacer = "\n")
            data["params"]["text"] =
                [rstrip(lpad(l, length(l) + indent)) for l in split(output, "\n")]
            print(stdout, JSON.json(data))
            log("Done.")
        end
    end

    log("exiting ...")
end

log("calling main ...")

main()
