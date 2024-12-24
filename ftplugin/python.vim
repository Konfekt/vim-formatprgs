augroup formatprgsPython
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('ruff')
  let &l:formatprg = 'ruff format --quiet --preview ' .
        \ (filereadable(expand('%')) ? '--stdin-filename %:S' : '') .
        \ ' -'
elseif executable('black')
  setlocal formatprg=black\ --quiet\ -
elseif executable('yapf')
  setlocal formatprg=yapf\ -
elseif executable('autopep8')
  setlocal formatprg=autopep8\ --quiet\ --skip-string-normalization\ -
endif
