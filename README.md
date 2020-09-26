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
" format from line 5 to line 15 inclusive
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

You can access the JuliaFormatter log file by running the following:

```vim
:JuliaFormatterLog
```

Feel free to open an issue for debugging a problem, questions or feature requests.

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

### Compatibility with BlueStyle and YAS

`JuliaFormatter.vim` enables compatibility with [BlueStyle](https://github.com/invenia/BlueStyle) and [YAS](https://github.com/jrevels/YASGuide).

Here is how to configure (n)vim for `BlueStyle` or `YAS`:

1. Install [`JuliaFormatter.vim`](#install)

2. Add the following to your vimrc to follow the `BlueStyle` standard:

   ```vim
   let g:JuliaFormatter_options = {
           \ 'style' : 'blue',
           \ }
   ```

   This translates to a call to:

   ```julia
   style = BlueStyle()
   JuliaFormatter.format_text(vim_text_selection_or_buffer, style = style)
   ```

   OR

   Add the following to your vimrc to follow the `BlueStyle` standard:

   ```vim
   let g:JuliaFormatter_options = {
           \ 'style' : 'blue',
           \ }
   ```

   This translates to a call to:

   ```julia
   style = YASStyle()
   JuliaFormatter.format_text(vim_text_selection_or_buffer, style = style)
   ```

3. (_Optional_) Create a file in the path `~/.vim/after/ftplugin/julia.vim` and add to the julia.vim file the following:

   ```vim
   " ~/.vim/after/ftplugin/julia.vim
   setlocal expandtab       " Replace tabs with spaces.
   setlocal textwidth=92    " Limit lines according to Julia's CONTRIBUTING guidelines.
   setlocal colorcolumn+=1  " Highlight first column beyond the line limit.
   ```

### Support `.JuliaFormatter.toml` configuration

When `:JuliaFormatterFormat` is called, it will look for `.JuliaFormatter.toml` in the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found.
When found, the configurations in the file will overwrite the options provided by `g:JuliaFormatter_options`.

See <https://domluna.github.io/JuliaFormatter.jl/stable/config/> for more information.

### Precompiling JuliaFormatter using PackageCompiler

Using a custom system image can speedup the initialization time of the plugin.
This can be done using
[`PackageCompiler`](https://github.com/JuliaLang/PackageCompiler.jl).

`PackageCompiler` can be used with `JuliaFormatter.vim` by running the following:

```
$ cd /path/to/JuliaFormatter.vim/
$ julia --project scripts/packagecompiler.jl
```

You can type `:echo g:JuliaFormatter_root` to find where `/path/to/JuliaFormatter.vim/` is. For more information check vim documentation or consult your plugin manager documentation.
This will create a Julia `sysimage` that is stored in `scripts` folder.

Then in your `vimrc` set:

```vim
let g:JuliaFormatter_use_sysimage=1
```

If you would like to use a sysimage that is located elsewhere, you can do so:

```
let g:JuliaFormatter_use_sysimage=1
let g:JuliaFormatter_sysimage_path="/path/to/julia_sysimage.so"
```

### Troubleshooting

See [`MINRC`](./tests/MINRC) before opening an issue.
