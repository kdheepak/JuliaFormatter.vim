# JuliaFormatter.vim

Plugin for formatting Julia code in (n)vim using [`JuliaFormatter.jl`](https://github.com/domluna/JuliaFormatter.jl).

![](https://user-images.githubusercontent.com/1813121/72941091-0b146300-3d68-11ea-9c95-75ec979caf6e.gif)

## Install

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

## Usage

Open any Julia file, type `:` to open the command prompt and type the following:

```vim
" format full file
:JuliaFormatterFormat
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

You can access the `JuliaFormatter` server log file by running the following:

```vim
:JuliaFormatterLog
```

Feel free to open an issue for debugging a problem, questions or feature requests.

## Options

### Setting Format Options

<details>

<summary> Click to expand! </summary>

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

</details>

### Compatibility with `BlueStyle` and `YASStyle`

<details>

<summary> Click to expand! </summary>

`JuliaFormatter.vim` enables compatibility with [BlueStyle](https://github.com/invenia/BlueStyle) and [YAS](https://github.com/jrevels/YASGuide).

Here is how to configure (n)vim for `BlueStyle` or `YAS`:

1. Install [`JuliaFormatter.vim`](#install)

2. Add the following to your `vimrc` to follow the `BlueStyle` standard:

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

   Add the following to your `vimrc` to follow the `YAS` standard:

   ```vim
   let g:JuliaFormatter_options = {
           \ 'style' : 'yas',
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

</details>

### Support `.JuliaFormatter.toml` configuration

<details>

<summary> Click to expand! </summary>

When `:JuliaFormatterFormat` is called, it will look for `.JuliaFormatter.toml` in the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found.
When found, the configurations in the file will overwrite the options provided by `g:JuliaFormatter_options`.

See <https://domluna.github.io/JuliaFormatter.jl/stable/config/> for more information.

</details>

### Precompiling `JuliaFormatter` using `PackageCompiler`

<details>

<summary> Click to expand! </summary>

Using a custom system image can speedup the initialization time of the plugin.
This can be done using
[`PackageCompiler.jl`](https://github.com/JuliaLang/PackageCompiler.jl).

`PackageCompiler.jl` can be used with `JuliaFormatter.vim` by running the following:

```
$ cd /path/to/JuliaFormatter.vim/
$ julia --project scripts/packagecompiler.jl
```

This will create a Julia `sysimage` that is stored in `/path/to/JuliaFormatter.vim/scripts` folder.
You can type `:echo g:JuliaFormatter_root` in (n)vim to find where `/path/to/JuliaFormatter.vim/` is.
For more information check (n)vim documentation or consult your plugin manager documentation.

Then in your `vimrc` set:

```vim
let g:JuliaFormatter_use_sysimage=1
```

If you would like to use a sysimage that is located elsewhere, you can do so too.
Add the following to your `vimrc`:

```vim
let g:JuliaFormatter_use_sysimage=1
let g:JuliaFormatter_sysimage_path="/path/to/julia_sysimage.so"
```

</details>

### Launching the `JuliaFormatter` server when opening a Julia file

<details>

<summary> Click to expand! </summary>

By default, the `JuliaFormatter` server is only started the first time you call `:JuliaFormatterFormat`.
This means your first format will be slower than the remaining times for an open session of (n)vim.
`PackageCompiler.jl` compiles `JuliaFormatter.jl`, `JSON.jl` and other methods used for formatting Julia code
and this significantly speeds up the first call to `:JuliaFormatterFormat`.
Once the server is started, it is waiting for input on `stdin` and remaining calls will be fast.

Additionally, if you would like, you can start the server when you open a Julia file for the first time instead of when
you call `:JuliaFormatterFormat` for the first time.
Just add the following in your `vimrc`:

```vim
let g:JuliaFormatter_always_launch_server=1
```

</details>

### Troubleshooting

<details>

<summary> Click to expand! </summary>

See [`MINRC`](./tests/MINRC) before opening an issue.

</details>
