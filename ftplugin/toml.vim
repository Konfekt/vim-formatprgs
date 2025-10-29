augroup formatprgsToml
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('tombi')
  let &l:formatprg = 'tombi format --quiet ' ..
        \ (filereadable(expand('%')) ? '--stdin-filename %:S' : '') .. ' -'
endif
