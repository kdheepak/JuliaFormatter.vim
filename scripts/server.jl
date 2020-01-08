using JuliaFormatter
using Dates
using JSON

format_text("")

const logfile = open(joinpath(@__DIR__, "juliaformatter.log"), "w")

function log(msg)
    write(logfile, "[$(Dates.now())] $msg\n")
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
            log("Formatting: ")
            text = replace(text, "\\n"=>"\n")
            write(logfile, text)
            try
                text = format_text(text)
                data["status"] = "success"
            catch
                log("failed")
                text = text
                data["status"] = "error"
            end
            write(logfile, "\n---------------------------------------------------------------------\n")
            write(logfile, text)
            print(logfile, "\n")
            data["params"]["text"] = text
            print(stdout, JSON.json(data))
        end
    end

    log("exiting ...")
end

log("calling main ...")

main()
