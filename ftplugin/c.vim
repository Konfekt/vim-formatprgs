augroup formatprgsC
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif

if b:formatprg ==# 'clang-format' || empty(b:formatprg) && executable('clang-format')
  function! s:ClangFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = 'clang-format ' .
            \ get(b:, 'formatprg_args', '--style=file --fallback-style=Google') . ' ' .
            \ '--assume-filename=' . (filereadable(expand('%')) ? expand('%:p:S') : 'stdin.c') .
            \  printf(' --lines=%d:%d -', start, end)
    let view  = winsaveview()
    try
      " exe start ',' end '!' cmd
      silent exe '%!' cmd
    finally
      call winrestview(view)
    endtry
  endfunction
  setlocal formatexpr=<SID>ClangFormatexpr()
elseif b:formatprg ==# 'uncrustify' || empty(b:formatprg) && executable('uncrustify')
  if !exists('s:ft')
    let s:slash = exists('+shellslash') && !&g:shellslash ? '\' : '/'
    let s:cfg_home = empty($XDG_CONFIG_HOME) ? expand('$HOME') . s:slash . '.config' : $XDG_CONFIG_HOME
    let s:ft = s:cfg_home . s:slash . 'uncrustify' . s:slash . &filetype . '.cfg'
    unlet s:slash s:cfg_home
  endif
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'uncrustify ' .
        \ get(b:, 'formatprg_args', '-q') . ' -l ' . &filetype . ' ' .
        \ (&textwidth > 0 ? ' --set code_width=' . &textwidth . ' --set cmt_width=' . &textwidth : '') .
        \ ' --set indent_columns=' . shiftwidth() . (&expandtab ? ' --set indent_with_tabs=0' : '') .
        \ (filereadable(expand('%')) ? ' --assume ' . expand('%:p:S') : '') .
        \ (filereadable(s:ft) ? (' -c ' . shellescape(s:ft)) : '') .
        \ ' -'
elseif b:formatprg ==# 'astyle' || empty(b:formatprg) && executable('astyle')
  autocmd BufWinEnter <buffer> ++once let &l:formatprg='astyle ' .
              \ get(b:, 'formatprg_args', '--quiet --mode=c --style=google --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none') . ' ' .
              \ (&textwidth > 0 ? ' --max-code-length=' . &textwidth : '') .
              \ ' --indent=spaces=' . shiftwidth() . (&expandtab ? ' --convert-tabs' : '') .
              \ ' -'
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal formatprg< formatexpr< | silent! autocmd! formatprgsC * <buffer>'
