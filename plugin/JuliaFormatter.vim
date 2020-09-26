if exists("g:JuliaFormatter_loaded") | finish | endif

let s:save_cpo = &cpoptions
set cpoptions&vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

let s:root = expand('<sfile>:h:h')
let g:JuliaFormatter_root = s:root

if g:os ==# "Darwin"
    let s:ext = ".dylib"
elseif g:os ==# "Windows"
    let s:ext = ".dll"
else
    let s:ext = ".so"
endif

if !exists("g:JuliaFormatter_options")
    let g:JuliaFormatter_options = {
        \ 'indent'                    : 4,
        \ 'margin'                    : 92,
        \ 'always_for_in'             : v:false,
        \ 'whitespace_typedefs'       : v:false,
        \ 'whitespace_ops_in_indices' : v:true,
        \ }
endif

if !exists("g:JuliaFormatter_sysimage_path")
    let g:JuliaFormatter_sysimage_path = s:root . '/scripts/juliaformatter' . s:ext
endif

command! -range=% -nargs=* JuliaFormatterFormat call JuliaFormatter#FormatCommand(
    \ <line1>,
    \ <count>,
    \ +"<range>",
    \ "<mods>",
    \ <q-args>,
    \ [<f-args>]
    \ )


""""""""""""""""""""""""""""""""""""""""""""""""""""""

let &cpoptions = s:save_cpo
unlet s:save_cpo

let g:JuliaFormatter_loaded = 1
