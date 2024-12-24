augroup formatprgsBib
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('bibtex-tidy')
  autocmd formatprgsBib BufWinEnter <buffer> ++once let &l:formatprg = 'bibtex-tidy --quiet ' .
        \ ' --merge combine --strip-enclosing-braces --drop-all-caps --encode-urls --trailing-commas --tidy-comments --remove-empty-fields --sort ' .
        \ (&textwidth > 0 ? ' --wrap=' . &textwidth : '') .
        \ ' --blank-lines --space=' . &shiftwidth . ' ' . (&expandtab ? '--no-tab' : '--tab')
elseif executable('prettybib.py')
  setlocal formatprg=prettybib.py
endif
