local juliaformatter_sysimage = ""
local juliaformatter_project = vim.fn.expand("%:p:h")
local formatCommand = 'julia '

local ext = ""
if vim.g.os == "Darwin" then
    ext = ".dylib"
elseif vim.g.os == "Windows" then
    ext = ".dll"
else
    ext = ".so"
end

local sysimage_path = juliaformatter_project .. '/scripts/juliaformatter' .. ext
if vim.fn.filereadable(vim.fn.expand(sysimage_path)) then
    juliaformatter_sysimage = sysimage_path
    formatCommand = formatCommand .. '-J' .. juliaformatter_sysimage .. ' '
end

formatCommand = formatCommand .. '--project ' .. juliaformatter_project
                    .. [[ startup-file=no color=no -e 'using JuliaFormatter print(format_text(String(read(stdin))))']]

return {efmConfig = {formatCommand = formatCommand, formatStdin = true}}
