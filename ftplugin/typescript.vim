if executable('prettier')
  augroup formatprgsTypeScript
    autocmd! * <buffer>
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    autocmd formatprgsTypeScript BufWinEnter <buffer> ++once let &l:formatprg = 'prettier --stdin-filepath=%:S --parser=typescript --single-quote --tab-width=' . &l:shiftwidth . (&expandtab ? '' : '--use-tabs') . ' --'
  augroup END
endif
