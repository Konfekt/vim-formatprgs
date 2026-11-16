augroup formatprgsJava
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

" Read ~/.config/uncrustify/{filetype}.cfg if present.
function! s:Uncrustify(args) abort
  let cfg = (empty($XDG_CONFIG_HOME) ? expand('~/.config') : $XDG_CONFIG_HOME) .
        \ '/uncrustify/' . &filetype . '.cfg'
  return 'uncrustify ' . a:args . ' ' .
        \ (&textwidth > 0 ? ' --set code_width=' . &textwidth . ' --set cmt_width=' . &textwidth : '') .
        \ ' --set indent_columns=' . shiftwidth() . (&expandtab ? ' --set indent_with_tabs=0' : '') .
        \ (filereadable(expand('%')) ? ' --assume ' . expand('%:p:S') : '') .
        \ (filereadable(cfg) ? ' -c ' . shellescape(cfg) : '') .
        \ ' -'
endfunction

function! s:Astyle(default_args) abort
  return 'astyle ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ (&textwidth > 0 ? ' --max-code-length=' . &textwidth : '') .
        \ ' --indent=spaces=' . shiftwidth() . (&expandtab ? ' --convert-tabs' : '') .
        \ ' -'
endfunction

if s:Use('clang-format')
  setlocal formatexpr=<SID>ClangFormatexpr('Google','stdin.java')
elseif s:Use('uncrustify')
  execute 'autocmd formatprgsJava BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Uncrustify(get(b:, 'formatprg_args', '-q -l JAVA'))"
elseif s:Use('astyle')
  execute 'autocmd formatprgsJava BufWinEnter <buffer> ++once ' .
        \ "let &l:formatprg = <SID>Astyle('--quiet --mode=java --style=google --pad-oper --pad-header --unpad-paren --align-pointer=name --align-reference=name --add-brackets --suffix=none')"
endif

if exists('#formatprgsJava#BufWinEnter#<buffer>') && bufwinnr(bufnr('%')) != -1
  doautocmd <nomodeline> formatprgsJava BufWinEnter <buffer>
endif

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< formatexpr< | unlet! b:formatprg b:formatprg_args | execute ''silent! autocmd! formatprgsJava * <buffer>'''
