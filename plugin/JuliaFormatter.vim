if exists("g:JuliaFormatter_loaded") | finish | endif

let s:save_cpo = &cpoptions
set cpoptions&vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:is_win = has('win32') || has('win64')
let s:root = expand('<sfile>:h:h')

if !exists("g:JuliaFormatter_options")
    let g:JuliaFormatter_options = {
        \ 'indent'                    : 4,
        \ 'margin'                    : 92,
        \ 'always_for_in'             : v:false,
        \ 'whitespace_typedefs'       : v:false,
        \ 'whitespace_ops_in_indices' : v:true,
        \ }
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
