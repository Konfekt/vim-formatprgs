augroup formatprgsToml
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('tombi')
  " See https://github.com/tombi-toml/tombi/pull/1044#issuecomment-3465851563
  let &l:formatprg = 'tombi format ' ..
        \ (filereadable(expand('%')) ? '--stdin-filename %:S' : '') .. ' - ' ..
        \ (has('win32') ? '2>nul' : '2>/dev/null')
endif
