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
:JuliaFormatter
" format last/current selection
:'<,'>JuliaFormatterFormat
" format from lines 5 to 15 inclusive
:5,15JuliaFormatterFormat
```

You can remap this to a keyboard shortcut as well.

```vim
" normal mode mapping
nnoremap <localleader>jf :JuliaFormatterFormat<CR>
" visual mode mapping
vnoremap <localleader>jf :JuliaFormatterFormat<CR>
```

The (n)vim documentation recommends using `<localleader>` for a filetype plugin, but feel free to use `<leader>` or `<localleader>` for this remap.
In (n)vim, both `<leader>` and `<localleader>` are set to the `\` key by default.

### Setting Format Options

To modify the formatting options can be modified by setting `g:JuliaFormatter_options` in your `vimrc`. An example of this is:

```vim
let g:JuliaFormatter_options = {
        \ 'indent'                    : 4,
        \ 'margin'                    : 92,
        \ 'always_for_in'             : v:false,
        \ 'whitespace_typedefs'       : v:false,
        \ 'whitespace_ops_in_indices' : v:true,
        \ }
```

This translates to a call to:

```julia
JuliaFormatter.format_text(vim_text_selection_or_buffer, indent = 4, margin = 92; always_for_in = true, whitespace_typedef = false, whitespace_ops_in_indices = true)
```

See full list of options over on the [JuliaFormatter API documentation](https://domluna.github.io/JuliaFormatter.jl/stable/api/#JuliaFormatter.format_file-Tuple{AbstractString}).

### Compatibility with BlueStyle

JuliaFormatter enables complete compatibility with [BlueStyle](https://github.com/invenia/BlueStyle).

Here is how to configure (n)vim for BlueStyle:

1. Install JuliaFormatter.vim

2. Add the following to your vimrc to follow the BlueStyle standard:

```vim
let g:JuliaFormatter_options = {
        \ 'style' : 'blue',
        \ }
```

This translates to a call to:

```julia
style = BlueStyle()
JuliaFormatter.format_text(vim_text_selection_or_buffer, style)
```

3. Create a file in the path `~/.vim/after/ftplugin/julia.vim` and add to the julia.vim file the following:

```vim
" ~/.vim/after/ftplugin/julia.vim
setlocal expandtab       " Replace tabs with spaces.
setlocal textwidth=92    " Limit lines according to Julia's CONTRIBUTING guidelines.
setlocal colorcolumn+=1  " Highlight first column beyond the line limit.
```


### Troubleshooting

See [`MINRC`](./tests/MINRC) before opening an issue.
