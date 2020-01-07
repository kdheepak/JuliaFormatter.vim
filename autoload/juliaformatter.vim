if get(g:, 'JuliaFormatter_setup')
    finish
endif

function! s:PutLines(lines, lineStart)
    call append(a:lineStart - 1, a:lines)
endfunction

function! s:DeleteLines(lineFirst, lineLast)
    silent! exec a:lineFirst . "," . a:lineLast ."d _"
endfunction

function! s:AddPrefix(message) abort
    return '[JuliaFormatter] ' . a:message
endfunction

function! s:Echo(message) abort
    echomsg s:AddPrefix(a:message)
endfunction

function! s:Echoerr(message) abort
    echohl Error | echomsg s:AddPrefix(a:message) | echohl None
endfunction

" vim execute callback for every line.
function! s:HandleMessage(job, lines, event) abort
    if a:event ==# 'stdout'
        call s:Echo(g:line_start)
        call s:Echo(g:line_end)
        call s:DeleteLines(g:line_start, g:line_end)
        call s:PutLines(a:lines, g:line_start)
    elseif a:event ==# 'exit'
        call s:Echo('Done')
    endif
endfunction

function! s:HandleVim(job, data) abort
    return s:HandleMessage(a:job, [a:data], '')
endfunction

let s:root = expand('<sfile>:p:h:h')

function! JuliaFormatter#binaryPath() abort
    let l:filename = 'julia'
    if has('win32')
        let l:filename .= '.exe'
    endif
    return l:filename
endfunction

function! s:Setup() abort
    let l:binpath = JuliaFormatter#binaryPath()

    let l:cmd = join([l:binpath, '--startup-file=no', '--project=' . s:root, '-e', '"using Pkg; Pkg.build()"'])
    let s:current_win = winnr()

    if has('nvim')
        let s:job = jobstart(l:cmd, {})
        if s:job == 0
            " call s:Echoerr('JuliaFormatter: Invalid arguments!')
            return 0
        elseif s:job == -1
            " call s:Echoerr('JuliaFormatter: ' . l:binpath .' not executable!')
            return 0
        else
            return 1
        endif
    elseif has('job')
        let s:job = job_start(l:cmd, {})
        if job_status(s:job) !=# 'run'
            " call s:Echoerr('JuliaFormatter: job failed to start or died!')
            return 0
        else
            return 1
        endif
    else
        " echoerr 'Not supported: not nvim nor vim with +job.'
        return 0
    endif
endfunction

function! s:get_visual_selection()
endfunction

" JuliaFormatter#Format formats text and replaces the text in the current buffer
" It takes a `mode` which either formats the entire buffer text
" or the text in the visual selection
"
" It sets global `line_start` and `line_end` variables
" It runs `jobstart`/`job_start` on (n)vim
" It registers callbacks for the output of stdout
" Deletes lines `line_start`:`line_end`
" Appends output of stdout
function! JuliaFormatter#Format(m) abort

    let l:binpath = JuliaFormatter#binaryPath()

    if executable(l:binpath) != 1
        call s:Echoerr('JuliaFormatter: binary (' . l:binpath . ') doesn''t exists! Please check installation guide.')
        return 0
    endif

    " visual mode == 1
    if a:m == 1
        let g:line_start = getpos("'<")[1]
        let g:line_end = getpos("'>")[1]
    else
        " Get all lines in the file
        let g:line_start =  1
        let g:line_end = line('$')
    endif
    let l:content = getline(g:line_start, g:line_end)
    let l:content = join(l:content, '\n')
    let l:content = substitute(l:content, '"', '\\"', "g")
    let l:content = substitute(l:content, "'", "\\'", "g")

    let l:cmd = join([l:binpath, '--startup-file=no', '--project=' . s:root, '-e', ' ''using JuliaFormatter; print(format_text("""' . l:content . '"""))'' '])
    if has('nvim')
        let s:job = jobstart(l:cmd, {
                    \ 'on_stdout': function('s:HandleMessage'),
                    \ 'on_stderr': function('s:HandleMessage'),
                    \ 'on_exit': function('s:HandleMessage'),
                    \ 'stdout_buffered': v:true,
                    \ })
        if s:job == 0
            call s:Echoerr('JuliaFormatter: Invalid arguments!')
            return 0
        elseif s:job == -1
            call s:Echoerr('JuliaFormatter: ' . l:binpath .' not executable!')
            return 0
        else
            return 1
        endif
    elseif has('job')
        " FIXME: stdout callback should fire after job finishes
        let s:job = job_start(l:cmd, {
                    \ 'out_cb': function('s:HandleVim'),
                    \ 'err_cb': function('s:HandleVim'),
                    \ 'exit_cb': function('s:HandleVim'),
                    \ })
        if job_status(s:job) !=# 'run'
            call s:Echoerr('JuliaFormatter: job failed to start or died!')
            return 0
        else
            return 1
        endif
    else
        echoerr 'Not supported: not nvim nor vim with +job.'
        return 0
    endif

endfunction

let g:JuliaFormatter_setup = s:Setup()
