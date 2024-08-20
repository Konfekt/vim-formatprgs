augroup vimrcFileTypeLua
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

setlocal textwidth=80
if executable('stylua')
  autocmd vimrcFileTypeLua BufWinEnter <buffer> ++once let &l:formatprg = 'stylua ' .
        \ ' --column-width ' . &l:textwidth .
        \ ' --indent-type ' . (&l:expandtab ? 'Spaces' : 'Tabs') .
        \ ' --indent-width ' . &l:shiftwidth .
        \ ' --stdin-filepath ' . expand('%:S') . ' -- -'
elseif executable('prettier')
  autocmd vimrcFileTypeLua BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'prettier --stdin-filepath=%:S --parser=lua --single-quote' .
        \ ' --print-width=' . &textwidth .
        \ ' --tab-width=' . &l:shiftwidth . (&expandtab ? '' : '--use-tabs') . ' --'
endif

