if exists("g:loaded_juliaformatter")
    finish
endif

let s:is_win = has('win32') || has('win64')
let s:root = expand('<sfile>:h:h')

let g:loaded_juliaformatter = 1
