This repository contains Vim configuration files that set the `formatprg` (respectively `:formatexpr`) option for various common code file types, according to the availability of the most common format programs on your computer.

The `formatprg` option in Vim specifies an external program to use for formatting the current buffer.
In particular, the behavior of the `gq` operator;
for example, `gqip` formats the current text block.

This plug-in adds file type specific settings (for common programming languages such as Python, Java, ...) that set it to popular options.
Rather meant for inspiration, but can be used as-is.

# Use `gw` to Format Paragraphs

While the gq operator (`:help gq`) defaults to formatting C (`:help C-indenting`) and is often universally used to format comments, say `gqip` to add line breaks to a paragraph, it respects a formatting program option (`:help 'formatprg'`) that can be set to a tool of one's choice.

What `gq` with default settings does, C-style formatting, is more conveniently achieved by `gw` (`:help gw`) keeping cursor position (so that both operators become complimentary, instead of `gq` rather redundant).

With suitable `'formatlistpat'` and `'formatoptions'` such as 

```vim
set formatoptions+=nw
set formatlistpat=\\C^\\s*\\([\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|[-+o*>]\\s\\+\\)\\+
```

`gw` respects lists well.

# File Text Object

Most formatters require additional context then the lines themselves to be formatted, some even the whole file or at least the code up to the cursor position.
(If formatting fails, use `:redo`, mapped to `U` or `<C-R>` by default to learn about the reasons.)
To give more context, add to your `vimrc` a text-object, say `<CR>` which operates on the whole buffer and [keeps the cursor position in the same position](https://vi.stackexchange.com/questions/2319/is-there-a-text-object-for-the-entire-buffer/24811#24811) or just up to the cursor position:

```vim
xnoremap          <cr>       ggoGg_
function! TextObjectAll()
    let g:restore_position = winsaveview()
    keepjumps normal! ggVG
    " For delete/change, we don't wish to restore cursor position.
    if index(['c','d'], v:operator) == -1
        call feedkeys("\<Plug>(RestoreView)")
    end
endfunction
nnoremap <silent> <Plug>(RestoreView) :call winrestview(g:restore_position)<CR>
onoremap <silent> <cr>                :<C-U>keepjumps call TextObjectAll()<CR>
```


# Language Servers Formatters

For example, if using a language server plug-in such as [lsp](https://github.com/yegappan/lsp/), then, in any file type for which a language server capable of formatting has been set up, or mapping, setting 

```vim
setlocal formatexpr=lsp#lsp#FormatExpr()
```

or

```vim
xnoremap <buffer>       gq <cmd>LspFormat<cr>
nnoremap <buffer>       gq <plug>(LspFormat)
```

will instead bind that formatter to `gq`.
To have both available, say the formatter set up by this plug-in as a fallback, keep `&formatexpr` as is and instead use other mappings, such as

```vim
xnoremap <buffer>       gb <cmd>LspFormat<cr>
nnoremap <buffer>       gb <plug>(LspFormat)
```

# File Types and Formatters

Some example file types and their formatters (without regarding the included fall-back formatters):

- For JavaScript, Typescript, CSS, YAML, ... files, `prettier` is used as the formatter, whenever available.
- For Python, `black(-mocchachino)` is used as the default formatter, whenever available, falling back to `ruff format`, `yapf` or `autopep8`.
- For C(++), Java ... files, `clang-format` is used as the formatter, whenever available.
- For shell scripts, the `shfmt` tool is used with the following options:

    - `--simplify`: Minify the code.
    - `--case-indent`: Indent switch cases.
    - `--space-redirects `: add trailing space to redirect operators.
    - `--indent`: Set the indentation level to the value of `shiftwidth` (if applicable).

- For HTML files, `tidy` is used as the formatter, whenever available, tool for cleaning up and pretty-printing HTML.
- ...
- there are many more filetypes; please check the `ftplugin` folder.

# Installation

To use these configuration files, copy them to your Vim configuration directory (usually `~/.vim/ftplugin/`).

For example, to install the `sh.vim` configuration:

```bash
mkdir -p ~/.vim/ftplugin
cp sh.vim ~/.vim/ftplugin/
```

Repeat the above steps for each file type configuration you want to use.

You may also use a plug-in manager such as [vim-plug](https://github.com/junegunn/vim-plug). 
In this case, add `Plug 'konfekt/vim-formatprgs'` to your `vimrc` to use them.

# Usage

Once installed, Vim will automatically use the specified formatter when you use the `gq` command (see `:help gq`) in a buffer of the corresponding file type.

# Forcing a specific formatter with `b:formatprg`

Set the buffer-local variable `b:formatprg` to select a known formatter for a filetype.
The ftplugin will honor this if the executable is found on `$PATH`, otherwise it falls back to auto-detection.

Examples:

- C: `let b:formatprg = 'clang-format'` or `'uncrustify'` or `'astyle'`.
- JavaScript: `let b:formatprg = 'prettier'` or `'biome'` or `'clang-format'`.

Recommended ways to set it:

- Per filetype (user ftplugin):
    - `~/.vim/ftplugin/c.vim` with `let b:formatprg = 'uncrustify'`
    - `~/.vim/ftplugin/javascript.vim` with `let b:formatprg = 'prettier'`

- Global autocommand:
    ```vim
    augroup MyFormatPrg
        autocmd!
        autocmd FileType c,cpp let b:formatprg = 'clang-format'
        autocmd FileType javascript,typescript let b:formatprg = 'prettier'
    augroup END
    ```

Notes:

- `b:formatprg` is a selector for this plugin, not Vim's `'formatprg'` option.
- The plugin configures `'formatexpr'` or `'formatprg'` accordingly.
- If using LSP-based formatting via `'formatexpr'`, that takes precedence over `'formatprg'`; consider separate mappings to access both.

# Customizing formatter arguments with `b:formatprg_args`

Set the buffer-local variable `b:formatprg_args` to override the default CLI arguments used by the selected formatter.
The plugin will insert `b:formatprg_args` immediately after the formatter executable.
Formatter-specific flags that must be computed at runtime (for example `--assume-filename`, `--stdin-filepath`, `--lines`, wrapping and indentation derived from `'textwidth'`, `'shiftwidth'`, `'expandtab'`) are still appended by the plugin.

Behavior:

- If `b:formatprg_args` is set, it replaces the plugin's default argument string for that formatter.
- If `b:formatprg_args` is not set, the plugin uses its default arguments.
- This variable is buffer-local, enabling per-file overrides.
- Combine with `b:formatprg` to select the executable and its argument preset.

Examples:

- C/C++ with clang-format:

    ```vim
    let b:formatprg = 'clang-format'
    let b:formatprg_args = '--style="{BasedOnStyle: Google, ColumnLimit: 100}" --fallback-style=LLVM'
    ```

- JavaScript with Prettier:

    ```vim
    let b:formatprg = 'prettier'
    let b:formatprg_args = '--log-level=error --no-color --single-quote --trailing-comma=all'
    ```

- JavaScript with Biome:

    ```vim
    let b:formatprg = 'biome'
    let b:formatprg_args = '--format-with-errors=true --colors=off'
    ```

- BibTeX with bibtex-tidy:

    ```vim
    let b:formatprg = 'bibtex-tidy'
    let b:formatprg_args = '--quiet --merge combine --strip-enclosing-braces --encode-urls'
    ```

Tip: add `unlet! b:formatprg_args` to `b:undo_ftplugin` to clean up buffer-local overrides.

# Contributing

Contributions are welcome! If you have a configuration for a new file type or improvements to existing configurations, please open a pull request.

# License

This repository is licensed under the Unlicense.
See the `LICENSE` file for more details.

# References

- [Vim Documentation on `formatprg`](https://vimhelp.org/options.txt.html#%27formatprg%27)
- [shfmt](https://github.com/mvdan/sh)
- [prettier](https://prettier.io/)
- [tidy](http://www.html-tidy.org/)

Feel free to reach out if you have any questions or need further assistance.
