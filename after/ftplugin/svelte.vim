if !executable('biome') | finish | endif

augroup formatprgsSvelte
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

function! s:Biome(default_args) abort
  return 'biome format ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
endfunction

execute 'autocmd formatprgsSvelte BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Biome('--write --format-with-errors=true --colors=off')"

if exists('#formatprgsSvelte#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsSvelte BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | unlet! b:formatprg_args | execute ''silent! autocmd! formatprgsSvelte * <buffer>'''
