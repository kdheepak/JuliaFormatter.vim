if exists("g:loaded_juliaformatter")
    finish
endif

let s:is_win = has('win32') || has('win64')
let s:root = expand('<sfile>:h:h')

let g:loaded_juliaformatter = 1

if !exists("g:JuliaFormatter_options")
    let g:JuliaFormatter_options = {
        \ 'indent'                    : 4,
        \ 'margin'                    : 92,
        \ 'always_for_in'             : v:false,
        \ 'whitespace_typedefs'       : v:false,
        \ 'whitespace_ops_in_indices' : v:true,
        \ }
endif
