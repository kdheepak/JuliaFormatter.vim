local juliaformatter_sysimage = ""
local juliaformatter_project = vim.fn.expand('<sfile>:p:h')
local formatCommand = 'julia '

if vim.fn.has("win64") ~= 0 or vim.fn.has("win32") ~= 0 or vim.fn.has("win16") ~= 0 then
    vim.g.os = "Windows"
else
    vim.g.os = vim.fn.substitute(vim.fn.system('uname'), '\n', '', '')
end

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
                    .. [[ startup-file=no color=no -e 'using JuliaFormatter; print(format_text(String(read(stdin))))']]

return {efmConfig = {formatCommand = formatCommand, formatStdin = true}}
