augroup vimrcFileTypeCMake
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('cmake-format')
  autocmd vimrcFileTypeCMake BufWinEnter <buffer> ++once
        \ let &l:formatprg='cmake-format'
        \ . (&textwidth > 0 ? ' --line-width=' . &textwidth : '') . ' --tab-size=' . &shiftwidth . (&expandtab ? '' : ' --use-tabchars')
        \ . ' -'
elseif executable('neocmakelsp')
  setlocal formatprg=neocmakelsp\ format
endif
