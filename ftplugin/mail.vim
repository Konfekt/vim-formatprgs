augroup formatprgsMail
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

" Though par\ 80p2dh formats paragraphs to 80 columns, with 2 spaces of hanging
" indent, but par does not detect indented lists, so use it as &equalprg for =
if empty(&l:equalprg) && executable('par')
  autocmd BufWinEnter <buffer> ++once
        \ let s:tw = &textwidth > 0 ? &textwidth : 80 |
        \ let &l:equalprg = join(map(['par','e','g',printf('%dp',s:tw),'w'.s:tw,'rTbgqR','B=.,?_A_a_0','Q=_s>'], 'shellescape(v:val, 1)'), ' ') |
        \ unlet s:tw
endif

setlocal commentstring=>\ %s
setlocal comments-=mb:* comments-=fb:-

setlocal formatlistpat=\\C^\\s*\\([\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|[-+o*>]\\s\\+\\)\\+
setlocal formatoptions+=nw

let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '') . 'setlocal cinoptions< formatprg< equalprg< commentstring< comments< formatlistpat< | silent! autocmd! formatprgsMail * <buffer>'
