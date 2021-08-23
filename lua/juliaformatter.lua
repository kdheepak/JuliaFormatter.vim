local juliaformatter_sysimage = ""
local juliaformatter_project = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])"):sub(1, -2):match("(.*[/\\])")
local formatCommand = "julia "

if vim.fn.has("win64") ~= 0 or vim.fn.has("win32") ~= 0 or vim.fn.has("win16") ~= 0 then
  vim.g.os = "Windows"
else
  vim.g.os = vim.fn.substitute(vim.fn.system("uname"), "\n", "", "")
end

local ext = ""
if vim.g.os == "Darwin" then
  ext = ".dylib"
elseif vim.g.os == "Windows" then
  ext = ".dll"
else
  ext = ".so"
end

local sysimage_path = juliaformatter_project .. "scripts/juliaformatter" .. ext
if vim.fn.filereadable(vim.fn.expand(sysimage_path)) then
  juliaformatter_sysimage = sysimage_path
  formatCommand = formatCommand .. "--sysimage=" .. juliaformatter_sysimage .. " "
end

formatCommand = formatCommand
  .. "--project="
  .. juliaformatter_project
  .. [[ --startup-file=no --color=no -e 'using JuliaFormatter; print(format_text(String(read(stdin))))']]

local function generate_efm_config()
  return { formatCommand = formatCommand, formatStdin = true }
end

local function generate_null_ls()
  local args = {
    "--project=" .. juliaformatter_project,
    "--startup-file=no",
    "--color=no",
    "-e",
    [['using JuliaFormatter; format("$FILENAME")']],
  }

  if vim.fn.filereadable(vim.fn.expand(sysimage_path)) == 1 then
    juliaformatter_sysimage = sysimage_path
    table.insert(args, 1, "--sysimage=" .. juliaformatter_sysimage)
  end

  local juliaformatter = require("null-ls.helpers").make_builtin({
    method = require("null-ls.methods").internal.FORMATTING,
    filetypes = { "julia" },
    generator_opts = {
      command = "julia",
      to_stdin = false,
      args = args,
    },
    factory = require("null-ls.helpers").formatter_factory,
  })
  return juliaformatter
end

return {
  efm_config = generate_efm_config,
  null_ls = generate_null_ls,
}
