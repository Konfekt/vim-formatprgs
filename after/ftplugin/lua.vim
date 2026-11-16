if !executable('stylua') | finish | endif

augroup formatprgsLua
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" The full path of the current file, escaped for a :! command.
function! s:Path() abort
  return shellescape(expand('%:p'), 1)
endfunction

" Filter the whole buffer through {cmd}, keeping the view.
" While typing, leave automatic wrapping to Vim.
function! s:Filter(cmd) abort
  if mode() =~# '^[iR]'
    return 1
  endif
  let view = winsaveview()
  try
    silent execute '%!' . a:cmd
  finally
    call winrestview(view)
  endtry
  return 0
endfunction

" --range-start and --range-end as zero-based offsets of the first character
" of the formatted lines and of the line after them.
function! s:Range() abort
  return printf(' --range-start %d --range-end %d',
        \ line2byte(v:lnum) - 1, line2byte(v:lnum + v:count) - 1)
endfunction

function! s:StyluaFormatexpr() abort
  return s:Filter('stylua ' .
        \ get(b:, 'formatprg_args', '') . ' ' .
        \ (&textwidth > 0 ? ' --column-width ' . &textwidth : '') .
        \ ' --indent-type ' . (&expandtab ? 'Spaces' : 'Tabs') .
        \ ' --indent-width ' . shiftwidth() .
        \ ' --stdin-filepath=' . s:Path() .
        \ s:Range() . ' -')
endfunction

setlocal formatexpr=<SID>StyluaFormatexpr()

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg_args | execute ''silent! autocmd! formatprgsLua * <buffer>'''
