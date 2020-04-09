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
}
```

See full list of options over on the [JuliaFormatter API documentation](https://domluna.github.io/JuliaFormatter.jl/stable/api/#JuliaFormatter.format_file-Tuple{AbstractString}).

### Precompiling the JuliaFormatter

Using a custom system image can speedup the initialization time of the plugin.
This can be done using the
[`PackageCompiler`](https://github.com/JuliaLang/PackageCompiler.jl). The
[drawbacks](https://julialang.github.io/PackageCompiler.jl/dev/sysimages/#Drawbacks-to-custom-sysimages-1)
of the `PackageCompiler`

> It should be clearly stated that there are some drawbacks to using a custom
> sysimage, thereby sidestepping the standard Julia package precompilation
> system. The biggest drawback is that packages that are compiled into a
> sysimage (including their dependencies!) are "locked" to the version they
> where at when the sysimage was created. This means that no matter what package
> version you have installed in your current project, the one in the sysimage
> will take precedence. This can lead to bugs where you start with a project
> that needs a specific version of a package, but you have another one compiled
> into the sysimage.

The `PackageCompiler` compiler can be used with the `JuliaFormatter` using the
following commands (from a top-level directory of a clone of
`JuliaFormatter.vim`)
```
$ julia -q
julia> using Pkg
julia> Pkg.add("PackageCompiler")
julia> using PackageCompiler
julia> Pkg.activate(@__DIR__)
julia> PackageCompiler.create_sysimage([:JuliaFormatter, :JSON]; precompile_execution_file=joinpath(@__DIR__, "scripts/precompile.jl"), replace_default=true)
```

If you cannot (or do want to) modify the default system image, instead the
following commands can be used
```
$ julia -q
julia> using Pkg
julia> Pkg.add("PackageCompiler")
julia> using PackageCompiler
julia> Pkg.activate(joinpath(@__DIR__,".dev"))
julia> PackageCompiler.create_sysimage([:JuliaFormatter, :JSON]; precompile_execution_file=joinpath(@__DIR__, "scripts/precompile.jl"), sysimage_path="path/to/sysimage.so")
```
In this case you should also set
`g:JuliaFormatter_sysimage='path/to/sysimage.so'` in your `vimrc`.

### Troubleshooting

See [`MINRC`](./tests/MINRC) before opening an issue.
