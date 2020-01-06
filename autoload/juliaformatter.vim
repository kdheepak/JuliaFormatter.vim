if get(g:, 'JuliaFormatter_setup')
    finish
endif

function! s:AddPrefix(message) abort
    return '[JF] ' . a:message
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
        " call s:Echoerr(join(a:lines, "\n"))
    elseif a:event ==# 'stderr'
        if len(a:lines) > 0
            call s:Echoerr('JuliaFormatter Error: ' . join(a:lines, "\n"))
        endif
    elseif a:event ==# 'exit'
        checktime
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
    if has('nvim')
        let s:job = jobstart(l:cmd, {
                    \ 'on_stdout': function('s:HandleMessage'),
                    \ 'on_stderr': function('s:HandleMessage'),
                    \ 'on_exit': function('s:HandleMessage'),
                    \ })
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
        let s:job = job_start(l:cmd, {
                    \ 'out_cb': function('s:HandleVim'),
                    \ 'err_cb': function('s:HandleVim'),
                    \ 'exit_cb': function('s:HandleVim'),
                    \ })
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


function! JuliaFormatter#FormatFile(filename) abort

    let l:binpath = JuliaFormatter#binaryPath()

    if executable(l:binpath) != 1
        call s:Echoerr('LanguageClient: binary (' . l:binpath . ') doesn''t exists! Please check installation guide.')
        return 0
    endif

    let l:cmd = join([l:binpath, '--startup-file=no', '--project=' . s:root, '-e', '"using JuliaFormatter; format_file(\"' . a:filename . '\")"'])
    if has('nvim')
        let s:job = jobstart(l:cmd, {
                    \ 'on_stdout': function('s:HandleMessage'),
                    \ 'on_stderr': function('s:HandleMessage'),
                    \ 'on_exit': function('s:HandleMessage'),
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
