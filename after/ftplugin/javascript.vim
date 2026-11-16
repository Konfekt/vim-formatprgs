" Other filetypes, such as javascriptreact, source this ftplugin as well.
if &filetype !=# 'javascript' | finish | endif

augroup formatprgsJavaScript
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

" Without a .clang-format file, base the style on {style} and Vim's options;
" {stdin_name} names an unsaved buffer.
function! s:ClangFormatexpr(style, stdin_name) abort
  let cfg = findfile('.clang-format', '.;')
  if empty(cfg)
    let cfg = findfile('_clang-format', '.;')
  endif
  if !empty(cfg)
    let default_style = '--style=file --fallback-style=' . a:style
  else
    let default_style =
          \ printf('--style="{BasedOnStyle: %s, ColumnLimit: %d, IndentWidth: %d, TabWidth: %d, UseTab: %s}"',
          \        a:style, &textwidth, shiftwidth(), &tabstop, (&expandtab ? 'Never' : 'ForIndentation'))
  endif
  return s:Filter('clang-format ' .
        \ get(b:, 'formatprg_args', default_style) .
        \ ' --assume-filename=' . (filereadable(expand('%')) ? s:Path() : shellescape(a:stdin_name)) .
        \ printf(' --lines=%d:%d -', v:lnum, v:lnum + v:count - 1))
endfunction

function! s:Biome(default_args) abort
  return 'biome format ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ '--stdin-file-path=' . s:Path() . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
endfunction

if s:Use('prettier')
  let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', '--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=babel')
  setlocal formatexpr=<SID>PrettierFormatexpr()
elseif s:Use('biome')
  execute 'autocmd formatprgsJavaScript BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Biome('--write --format-with-errors=true --colors=off')"
elseif s:Use('clang-format')
  setlocal formatexpr=<SID>ClangFormatexpr('Chromium','stdin.js')
endif

if exists('#formatprgsJavaScript#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsJavaScript BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg_cmd | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg b:formatprg_args | endif | execute ''silent! autocmd! formatprgsJavaScript * <buffer>'''
