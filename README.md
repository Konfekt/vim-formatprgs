This repository contains Vim configuration files that set the `formatprg` option for various common code file types, according to the availability of the most common format programs on your computer.
The `formatprg` option in Vim specifies an external program to use for formatting the current buffer.

It determines in particular the behavior of the `gq` operator;
for example, `gqip` formats the current text block.

While the gq operator (`:help gq`) defaults to C (`:help C-indenting`) and is often universally used to format comments, say `gqip` to add line breaks to a paragraph, it respects a formatting program option (`:help 'formatprg'`) that can be set to a tool of one's choice.

This plug-in adds file type specific settings (for common programming languages such as python, java, ...) that set it to popular options.
Rather meant for inspiration, but can be used as-is.

What `gq` with default settings does, C-style formatting, is more conveniently achieved by `gw` (`:help gw`) keeping cursor position (so that both operators become complimentary, instead of `gq` rather redundant).

# File Types and Formatters

Some example file types and their formatters:

- For shell scripts, the `shfmt` tool is used with the following options:

    - `--simplify`: Minify the code.
    - `--case-indent`: Indent switch cases.
    - `--space-redirects `: add trailing space to redirect operators.
    - `--indent`: Set the indentation level to the value of `shiftwidth` (if applicable).

- For JavaScript files, `prettier` is used as the formatter, whenever available.
`prettier` is an opinionated code formatter.
- For HTML files, `tidy` is used as the formatter, whenever available, tool for cleaning up and pretty-printing HTML.
- ...
- there are many more filetypes; please check the `ftplugin` folder.

# Installation

To use these configuration files, copy them to your Vim configuration directory (usually `~/.vim/ftplugin/`).

For example, to install the `sh.vim` configuration:

```sh
mkdir -p ~/.vim/ftplugin
cp sh.vim ~/.vim/ftplugin/
```

Repeat the above steps for each file type configuration you want to use.

You may also use a plug-in manager such as [vim-plug](https://github.com/junegunn/vim-plug). 
In this case, add `Plug 'konfekt/vim-formatprgs` to your `vimrc` to use them.

# Usage

Once installed, Vim will automatically use the specified formatter when you use the `gq` command (see `:help gq`) in a buffer of the corresponding file type.

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
