if exists('g:JuliaFormatter_server') && get(g:, 'JuliaFormatter_server')
else
    if exists('g:JuliaFormatter_always_launch_server')
        call JuliaFormatter#Launch()
    endif
endif
