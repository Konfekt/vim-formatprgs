" Also sourced for XHTML by Vim's xhtml ftplugin.
augroup formatprgsXML
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" Whether to use formatter {name}: the one chosen by b:formatprg if that is
" executable, otherwise any {name} found on $PATH.
function! s:Use(name) abort
  let choice = get(b:, 'formatprg', '')
  return !empty(choice) && executable(choice) ? choice ==# a:name : executable(a:name)
endfunction

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

" {tidy} is 'tidy' or 'tidy -xml'.
" See https://stackoverflow.com/questions/7151180/use-html-tidy-to-just-indent-html-code
function! s:Tidy(tidy) abort
  return a:tidy . ' ' .
        \ get(b:, 'formatprg_args', '--quiet --show-errors 0 -bare --show-body-only auto -wrap 0 -utf8') . ' ' .
        \ '-indent ' . (&expandtab ? '' : '--indent-with-tabs ') . '--indent-spaces ' . shiftwidth()
endfunction

if s:Use('xmllint')
  " Vim's xml ftplugin sets 'formatexpr', which takes precedence.
  setlocal formatexpr=
  execute 'autocmd formatprgsXML BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = (has('win32')" .
        \ " ? 'cmd /c \"set XMLLINT_INDENT=' . shiftwidth() . '&&' : 'XMLLINT_INDENT=' . shiftwidth()) ." .
        \ " ' xmllint --output - ' . get(b:, 'formatprg_args', '--format --recover --encode UTF-8 --nonet') ." .
        \ " (has('win32') ? '\"' : '')"
elseif s:Use('tidy')
  setlocal formatexpr=
  execute 'autocmd formatprgsXML BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Tidy('tidy -xml')"
elseif s:Use('prettier')
  let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', '--log-level=error --no-color --no-error-on-unmatched-pattern --parser=' . &filetype)
  setlocal formatexpr=<SID>PrettierFormatexpr()
endif

if exists('#formatprgsXML#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsXML BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args | execute ''silent! autocmd! formatprgsXML * <buffer>'''
