let s:root = expand('<sfile>:p:h:h')

let s:job = 0
let s:filename = 'julia'

if has('win32')
    let s:filename .= '.exe'
endif

let s:binpath = s:filename
if !exists("g:JuliaFormatter_use_sysimage")
    let s:cmd = join([s:binpath,
          \ '--startup-file=no',
          \ '--color=no',
          \ '--project=' . s:root,
          \ s:root . '/scripts/server.jl',
          \ ])
else
    let s:cmd = join([s:binpath,
          \ '-J' . g:JuliaFormatter_sysimage_path,
          \ '--startup-file=no',
          \ '--color=no',
          \ '--project=' . s:root,
          \ s:root . '/scripts/server.jl',
          \ ])
endif

function! s:PutLines(lines, lineStart)
    call append(a:lineStart - 1, a:lines)
endfunction

function! s:DeleteLines(lineFirst, lineLast)
    silent! exec a:lineFirst . "," . a:lineLast ."d _"
endfunction

function! s:AddPrefix(message)
    return '[JuliaFormatter] ' . a:message
endfunction

function! s:Echo(message)
    echomsg s:AddPrefix(a:message)
endfunction

function! s:Echoerr(message)
    echohl Error | echomsg s:AddPrefix(a:message) | echohl None
endfunction

" vim execute callback for every line.
function! s:HandleMessage(job, lines, event)
    if a:event ==# 'stdout'
        try
            let l:message = json_decode(join(a:lines))
        catch
            " call s:Echo("Unable to decode " . join(a:lines))
            return
        endtry
        if get(l:message, 'status') ==# 'success'
            " Save current editting layout
            let l:curw = {}
            try
                mkview!
            catch
                let l:curw = winsaveview()
            endtry

            " Check if buffer is modifed before formatting
            let l:isdirty = &modified

            let l:text = get(get(l:message, 'params'), 'text')
            call s:DeleteLines(s:line_start, s:line_end)
            call s:PutLines(l:text, s:line_start)
            if s:delete_last_line
                execute "normal dd"
            endif

            " Load the saved view
            if empty(l:curw)
                silent! loadview
            else
                call winrestview(l:curw)
            endif

            if !l:isdirty
                noa w " Save again without triggering autocmd
            endif
            echomsg ""
        elseif get(l:message, 'status') ==# 'error'
            call s:Echoerr("ERROR: JuliaFormatter.jl could not parse text.")
        endif
    elseif a:event ==# 'stderr'
        " call s:Echo(join(a:lines))
    elseif a:event ==# 'exit'
        " call s:Echo('Done')
    endif
endfunction

function! s:HandleVim(job, data)
    return s:HandleMessage(a:job, [ch_readraw(a:job), a:data], 'stdout')
endfunction

function! JuliaFormatter#binaryPath()
    let s:filename = 'julia'
    if has('win32')
        let s:filename .= '.exe'
    endif
    return s:filename
endfunction

function! JuliaFormatter#Kill()
    if has('nvim')
        if s:job > 0
            silent! call jobstop(s:job)
            let s:job = 0
        endif
    else
        if s:job != 0 && job_status(s:job)=='run'
            call job_stop(s:job, 'kill')
            let s:job = 0
        endif
    endif
endfunction

function! JuliaFormatter#EchoCmd()
  call s:Echo(s:cmd)
endfunction

function! JuliaFormatter#Launch()

    if executable(s:binpath) != 1
        call s:Echoerr('binary (' . s:binpath . ') doesn''t exists! Please check installation guide.')
        return 0
    endif

    if !exists("g:JuliaFormatter_use_sysimage")
        let s:cmd = join([s:binpath,
              \ '--startup-file=no',
              \ '--color=no',
              \ '--project=' . s:root,
              \ s:root . '/scripts/server.jl',
              \ ])
    else
        let s:cmd = join([s:binpath,
              \ '-J' . g:JuliaFormatter_sysimage_path,
              \ '--startup-file=no',
              \ '--color=no',
              \ '--project=' . s:root,
              \ s:root . '/scripts/server.jl',
              \ ])
    endif
    if has('nvim')
        let s:job = jobstart(s:cmd, {
                    \ 'on_stdout': function('s:HandleMessage'),
                    \ 'on_stderr': function('s:HandleMessage'),
                    \ 'on_exit': function('s:HandleMessage'),
                    \ })
        if s:job == 0
            call s:Echoerr('Invalid arguments!')
            let g:JuliaFormatter_server = 0
            return 0
        elseif s:job == -1
            call s:Echoerr(s:binpath .' not executable!')
            let g:JuliaFormatter_server = 0
            return 0
        else
            call s:Echo('started JuliaFormatter server (see :JuliaFormatterEchoCmd for more info)')
            let g:JuliaFormatter_server = 1
            return 1
        endif
    elseif has('job')
        " FIXME: stdout callback should fire after job finishes
        let s:job = job_start(s:cmd, {
                    \ "out_cb": function('s:HandleVim'),
                    \ })
        if job_status(s:job) !=# 'run'
            call s:Echoerr('job failed to start or died!')
            let g:JuliaFormatter_server = 0
            return 0
        else
            call s:Echo('started JuliaFormatter server (see :JuliaFormatterEchoCmd)' . s:cmd)
            let g:JuliaFormatter_server = 1
            return 1
        endif
    else
        echoerr 'Not supported: not nvim nor vim with +job.'
        let g:JuliaFormatter_server = 0
        return 0
    endif
endfunction

function! JuliaFormatter#Write(message)
    " Add new line so server can split on lines
    let l:message = a:message . "\n"
    if has('nvim')
        " chansend respond 1 for success.
        return !chansend(s:job, l:message)
    elseif has('channel')
        return ch_sendraw(s:job, l:message)
    else
        echoerr 'Not supported: not nvim nor vim with +channel.'
    endif
endfunction

function! JuliaFormatter#CheckJobId()
    try
        call JuliaFormatter#Write(json_encode({
                    \ 'method': 'isconnectedcheck',
                    \ }))
        return 1
    catch
        let g:JuliaFormatter_server = 0
        call s:Echoerr("JuliaFormatter server seems to have crashed. " . v:exception . ". Check logs for more information. Restarting JuliaFormatter server ...")
        call JuliaFormatter#Launch()
        return 1
    endtry
endfunction

function! JuliaFormatter#Send(method, params)
    let l:isconnected = JuliaFormatter#CheckJobId()
    if l:isconnected == 1
      return JuliaFormatter#Write(json_encode({
                  \ 'method': a:method,
                  \ 'params': a:params,
                  \ }))
    endif
endfunction

" JuliaFormatter#Format
function! JuliaFormatter#Format(m)
    if !get(g:, 'JuliaFormatter_server')
        call JuliaFormatter#Launch()
    end
    " visual mode == 1
    if a:m == 1
        let s:line_start = getpos("'<")[1]
        let s:line_end = getpos("'>")[1]
    else
        " Get all lines in the file
        let s:line_start =  1
        let s:line_end = line('$')
    endif
    if s:line_start ==# 1 && s:line_end ==# line('$')
        let s:delete_last_line = v:true
    else
        let s:delete_last_line = v:false
    endif
    let l:content = getline(s:line_start, s:line_end)
    return JuliaFormatter#Send('format', {
        \ 'text': l:content,
        \ 'options': g:JuliaFormatter_options,
        \ 'filepath': expand('%:p'),
        \ })
endfunction


function! JuliaFormatter#FormatCommand(line1, count, range, mods, arg, args) abort
  let s:line_start = a:count > 0 ? a:line1 : 1
  let s:line_end = a:count > 0 ? a:count : line('$')
  if s:line_start ==# 1 && s:line_end ==# line('$')
      let s:delete_last_line = v:true
  else
      let s:delete_last_line = v:false
  endif
  try
    if !get(g:, 'JuliaFormatter_server')
        call JuliaFormatter#Launch()
    end
    let l:content = getline(s:line_start, s:line_end)
    return JuliaFormatter#Send('format', {
        \ 'text': l:content,
        \ 'options': g:JuliaFormatter_options,
        \ 'filepath': expand('%:p'),
        \ })
  endtry
endfunction
