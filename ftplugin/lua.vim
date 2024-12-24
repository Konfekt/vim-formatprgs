augroup formatprgsLua
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('stylua')
  autocmd formatprgsLua BufWinEnter <buffer> ++once let &l:formatprg = 'stylua ' .
        \ ' --column-width ' . &l:textwidth .
        \ ' --indent-type ' . (&l:expandtab ? 'Spaces' : 'Tabs') .
        \ ' --indent-width ' . &l:shiftwidth .
        \ ' --stdin-filepath ' . expand('%:S') . ' -- -'
elseif executable('prettier')
  autocmd formatprgsLua BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'prettier --stdin-filepath=%:S --parser=lua --single-quote' .
        \ (&textwidth > 0 ? ' --print-width=' . &textwidth : '') .
        \ ' --tab-width=' . &l:shiftwidth . (&expandtab ? '' : '--use-tabs') . ' --'
endif

