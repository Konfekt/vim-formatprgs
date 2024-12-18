augroup vimrcFileTypeMail
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

" Though par\ 80p2dh formats paragraphs to 80 columns, with 2 spaces of hanging
" indent, but par does not detect indentet lists, so use it as &equalprg for =
if empty(&l:equalprg) && executable('par')
  autocmd vimrcFileTypeMail BufWinEnter <buffer> ++once
        \ let s:tw = &textwidth > 0 ? string(&textwidth) : 80|
        \ let &l:equalprg = escape('par e g ' . s:tw . 'p w' . s:tw . ' rTbgqR B=.,?_A_a_0 Q=_s>', ';:?>|')|
        \ unlet s:tw
endif

setlocal commentstring=>\ %s
setlocal comments-=mb:*
setlocal comments-=fb:-

setlocal formatlistpat=\\C^\\s*[\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|^\\s*[-+*o–•]\\s\\+
setlocal formatoptions+=n
setlocal formatoptions+=w
