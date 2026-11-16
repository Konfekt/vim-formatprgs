call formatprgs#init('formatprgsMail')

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

" Though par\ 80p2dh formats paragraphs to 80 columns, with 2 spaces of hanging
" indent, but par does not detect indented lists, so use it as &equalprg for =
if empty(&l:equalprg) && executable('par')
  call formatprgs#on_bufwinenter('formatprgsMail', "let &l:equalprg = 'par ' . get(b:, 'formatprg_args'," .
        \ " join(map(['e', 'g', printf('%dp', &textwidth > 0 ? &textwidth : 80), 'w' . (&textwidth > 0 ? &textwidth : 80)," .
        \ " 'rTbgqR', 'B=.,?_A_a_0', 'Q=_s>'], 'shellescape(v:val, 1)'), ' '))")
endif

setlocal commentstring=>\ %s
setlocal comments-=mb:* comments-=fb:-

setlocal formatlistpat=\\C^\\s*\\([\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|[-+o*>]\\s\\+\\)\\+
setlocal formatoptions+=nw

call formatprgs#undo('formatprgsMail', 'setlocal cinoptions< equalprg< commentstring< comments< formatlistpat< formatoptions< | unlet! b:formatprg_args')
