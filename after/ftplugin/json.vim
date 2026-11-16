augroup formatprgsJSON
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

function! s:Biome(default_args) abort
  return 'biome format ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
endfunction

" see https://stackoverflow.com/questions/21413120/how-can-i-get-gg-g-in-vim-to-ignore-a-comma/21413701#21413701
setlocal cinoptions+=+0

" g:json_formatprg names a jq-compatible program to use instead of jq.
let s:jq = get(g:, 'json_formatprg', '')
if !exists('g:json_formatprg')
  for s:exe in ['jq'] + (has('win32') || !empty($WSL_DISTRO_NAME) ? ['jq.exe', 'jq-win64.exe', 'jq-win32.exe'] : [])
    if s:Use(s:exe)
      let s:jq = s:exe
      break
    endif
  endfor
  unlet! s:exe
endif

if !empty(s:jq)
  " jq cannot indent by more than 7 spaces; --tab and --indent override each other.
  execute 'autocmd formatprgsJSON BufWinEnter <buffer> ++once ' .
        \ 'let &l:formatprg = ' . string(s:jq) . " . ' ' ." .
        \ " get(b:, 'formatprg_args', '') ." .
        \ " (&expandtab ? ' --indent ' . min([shiftwidth(), 7]) : ' --tab') . ' \".\"'"
elseif s:Use('biome')
  execute 'autocmd formatprgsJSON BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Biome('--write --format-with-errors=true --colors=off')"
elseif s:Use('prettier')
  let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', '--single-quote --parser=json')
  setlocal formatexpr=<SID>PrettierFormatexpr()
elseif v:version >= 901 && !has('nvim')
  " Vim's own JSON formatter
  setlocal formatexpr=dist#json#FormatExpr()
endif
unlet s:jq

if exists('#formatprgsJSON#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsJSON BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal cinoptions< formatprg< formatexpr< | unlet! b:formatprg b:formatprg_cmd b:formatprg_args | execute ''silent! autocmd! formatprgsJSON * <buffer>'''
