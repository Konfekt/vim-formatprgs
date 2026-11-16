if !executable('prettier') | finish | endif

augroup formatprgsMarkdown
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

function! s:PrettierFormatexpr() abort
  return s:Filter(b:formatprg_cmd .
        \ (&textwidth > 0 ? ' --print-width=' . &textwidth : '') .
        \ ' --tab-width=' . shiftwidth() .
        \ (&expandtab ? '' : ' --use-tabs') .
        \ s:Range() .
        \ ' --stdin-filepath=' . s:Path())
endfunction

let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', '--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=markdown')
setlocal formatexpr=<SID>PrettierFormatexpr()

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatexpr< | unlet! b:formatprg_cmd b:formatprg_args | execute ''silent! autocmd! formatprgsMarkdown * <buffer>'''
