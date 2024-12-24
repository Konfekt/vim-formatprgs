if executable('prettier')
  augroup formatprgsCss 
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'prettier --stdin-filepath=%:S --parser=css --single-quote --tab-width=' . &l:shiftwidth . (&expandtab ? '' : '--use-tabs') . ' --'
  augroup END
endif
