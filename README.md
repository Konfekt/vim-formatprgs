This repository contains Vim configuration files that set the `formatprg` option for various common code file types, according to the availability of the most common format programs on your computer.
The `formatprg` option in Vim specifies an external program to use for formatting the current buffer.

It determines in particular the behavior of the `gq` operator;
for example, `gqip` formats the current text block.

Each configuration file in this repository is tailored to a specific file type and sets `formatprg` to a suitable formatter with appropriate options.

## File Types and Formatters

Some example file types and their formatters:


- For shell scripts, the `shfmt` tool is used with the following options:
    - `-ln posix`: Use POSIX shell language.
    - `-sr`: Simplify the code.
    - `-ci`: Indent switch cases.
    - `-s`: Minify the code.
    - `-i`: Set the indentation level to the value of `shiftwidth`.

```vim
let &l:formatprg = 'shfmt -ln posix -sr -ci -s -i ' . &l:shiftwidth
```

- For JavaScript files, `prettier` can be used as the formatter.
`prettier` is an opinionated code formatter.
- For HTML files, `tidy` can be used as the formatter. `tidy` is a tool for cleaning up and pretty-printing HTML.
- ...
- there are many more filetypes; please check the `ftplugin` folder.

## Installation

To use these configuration files, copy them to your Vim configuration directory (usually `~/.vim/ftplugin/`).

For example, to install the `sh.vim` configuration:

```sh
mkdir -p ~/.vim/ftplugin
cp sh.vim ~/.vim/ftplugin/
```

Repeat the above steps for each file type configuration you want to use.

You may also use a plug-in manager such as [vim-plug](https://github.com/junegunn/vim-plug). 
In this case, add `Plug 'konfekt/vim-formatprgs` to your `vimrc` to use them.

## Usage

Once installed, Vim will automatically use the specified formatter when you run the `:format` command in a buffer of the corresponding file type.

## Contributing

Contributions are welcome! If you have a configuration for a new file type or improvements to existing configurations, please open a pull request.

## License

This repository is licensed under the Unlicense.
See the `LICENSE` file for more details.

## References

- [Vim Documentation on `formatprg`](https://vimhelp.org/options.txt.html#%27formatprg%27)
- [shfmt](https://github.com/mvdan/sh)
- [prettier](https://prettier.io/)
- [tidy](http://www.html-tidy.org/)

Feel free to reach out if you have any questions or need further assistance.
