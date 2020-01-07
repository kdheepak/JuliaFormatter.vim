if exists("g:loaded_juliaformatter")
    finish
endif

let s:is_win = has('win32') || has('win64')
let s:root = expand('<sfile>:h:h')

let g:loaded_juliaformatter = 1

function! JuliaFormatter_Launch()
    return call('JuliaFormatter#Launch', a:000)
endfunction

augroup juliaformatter

    autocmd VimLeavePre * call JuliaFormatter#handleVimLeavePre()

augroup END
