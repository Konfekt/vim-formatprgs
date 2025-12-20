if !executable('rubocop') | finish | endif

augroup formatprgsRuby
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if !executable(get(b:, 'formatprg', '')) | let b:formatprg = '' | endif

if b:formatprg ==# 'rubocop' || empty(b:formatprg) && executable('rubocop')
  " Note: --stdin FILE ignored, not needed for formatting
  let &l:formatprg = 'rubocop -x --stdin _ ' .
        \ get(b:, 'formatprg_args', '') .
        \ ' --stderr 2>' . (has('win32') ? 'NUL' : '/dev/null')
endif

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< | unlet! b:formatprg b:formatprg_args | silent! autocmd! formatprgsRuby * <buffer> '
