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

### Run JuliaFormatter

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

See [MINRC](./MINRC) for an example of a minimal vimrc file.
