augroup vimrcFileTypeJava
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

setlocal textwidth=80
if executable('uncrustify')
  autocmd vimrcFileTypeJava BufWinEnter <buffer> ++once let &l:formatprg = 'uncrustify -q -l JAVA ' .
        \ ' --set code_width=' . &textwidth . ' --set cmt_width=' . &textwidth .
        \ ' --set indent_columns=' . &shiftwidth . (&expandtab ? ' --set indent_with_tabs=0' : '') .
        \ (filereadable(expand('%')) ? ' --assume %:S' : '')
elseif executable('astyle')
  autocmd vimrcFileTypeJava BufWinEnter <buffer> ++once let &l:formatprg='astyle --mode=java --style=java ' .
              \ ' --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none ' .
              \ ' --max-code-length=' . &textwidth .
              \ ' --indent=spaces=' . &shiftwidth . (&expandtab ? ' --convert-tabs' : '')
endif
