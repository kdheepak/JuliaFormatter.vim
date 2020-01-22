# JuliaFormatter.vim

Plugin for formatting Julia code in (n)vim using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl).

![](https://user-images.githubusercontent.com/1813121/72941091-0b146300-3d68-11ea-9c95-75ec979caf6e.gif)

### Install

Use any plugin manager:

**[vim-plug](https://github.com/junegunn/vim-plug)**

```vim
Plug 'kdheepak/JuliaFormatter.vim'
```

**[dein.vim](https://github.com/Shougo/dein.vim)**

```vim
call dein#add('kdheepak/JuliaFormatter.vim')
```

**[Vundle.vim](https://github.com/junegunn/vim-plug)**

```vim
Plugin 'kdheepak/JuliaFormatter.vim'
```

### Usage

Open any Julia file, type `:` to open the command prompt and type the following:

```vim
" format full file
:call JuliaFormatter#Format(0)
" format last/current selection
:call JuliaFormatter#Format(1)
```

You can remap this to a keyboard shortcut as well.

```vim
" normal mode mapping
nnoremap <localleader>jf :<C-u>call JuliaFormatter#Format(0)<CR>
" visual mode mapping
vnoremap <localleader>jf :<C-u>call JuliaFormatter#Format(1)<CR>
```

The vim documentation recommends using `<localleader>` for a filetype plugin, but feel free to use `<leader>` or `<localleader>` for this remap.
In vim, both `<leader>` and `<localleader>` are set to the `\` key by default.

### Troubleshooting

If after installing JuliaFormatter.vim, you are having trouble getting it to work, try the following minimal vimrc file.


```vim
set nocompatible              " be iMproved, required
filetype off                  " required

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

Plug 'kdheepak/JuliaFormatter.vim'

" Initialize plugin system
call plug#end()

nnoremap <localleader>jf :<C-u>call JuliaFormatter#Format(0)<CR>
vnoremap <localleader>jf :<C-u>call JuliaFormatter#Format(1)<CR>
```

Save the above to a file `MINRC`, and run `vim -u MINRC tests/test.jl` and try hitting `\jf` in normal or visual mode.
