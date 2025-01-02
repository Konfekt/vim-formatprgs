augroup formatprgsC
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error "..v:shell_error..", undoing changes"' | undo | endif
  endif
augroup END

if executable('uncrustify')
  if !exists('s:ft')
    let s:slash = exists('+shellslash') && !&g:shellslash ? '\' : '/'
    if empty($XDG_CONFIG_HOME) | let $XDG_CONFIG_HOME = $HOME..s:slash..'.config' | endif
    if filereadable($XDG_CONFIG_HOME..s:slash..'uncrustify'..s:slash..&filetype..'.cfg')
      let s:ft = $XDG_CONFIG_HOME..s:slash..'uncrustify'..s:slash..&filetype..'.cfg'
    else
      let s:ft = ''
    endif
  endif
  autocmd formatprgsC BufWinEnter <buffer> ++once let &l:formatprg = 'uncrustify -q -l CPP '..
        \ (&textwidth > 0 ? ' --set code_width='..&textwidth..' --set cmt_width='..&textwidth : '')..
        \ ' --set indent_columns='..&shiftwidth..(&expandtab ? ' --set indent_with_tabs=0' : '')..
        \ (filereadable(expand('%')) ? ' --assume %:S' : '')..
        \ empty(s:ft) ? '' : ' -c '..s:ft
elseif executable('astyle')
  autocmd formatprgsC BufWinEnter <buffer> ++once let &l:formatprg='astyle --mode=c --style=google '..
              \ ' --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none '..
              \ (&textwidth > 0 ? ' --max-code-length='..&textwidth : '')..
              \ ' --indent=spaces='..&shiftwidth..(&expandtab ? ' --convert-tabs' : '')
elseif executable('clang-format')
  let &l:formatprg = 'clang-format -style=file --fallback-style=Google --assume-filename=%:S'
endif
