if !executable('biome') | finish | endif

augroup formatprgsSvelte
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'biome format ' .
      \ get(b:, 'formatprg_args', '--write --format-with-errors=true --colors=off') . ' ' .
      \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
      \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
      \ '--indent-width=' . shiftwidth() . ' ' .
      \ '--indent-style=' . (&expandtab ? 'space' : 'tab')

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') .
      \ 'setlocal formatprg< | silent! autocmd! formatprgsSvelte * <buffer>'
