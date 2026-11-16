" Helpers shared by the ftplugins in after/ftplugin.

" Create the buffer-local augroup {group} and undo a shell filter that failed.
function! formatprgs#init(group) abort
  execute 'augroup' a:group '| augroup END'
  execute 'autocmd!' a:group '* <buffer>'
  if exists('##ShellFilterPost')
    execute 'autocmd' a:group 'ShellFilterPost <buffer> call formatprgs#undo_failed_filter()'
  endif
endfunction

function! formatprgs#undo_failed_filter() abort
  if v:shell_error
    echohl WarningMsg
    echomsg printf('shell filter returned error %d, undoing changes', v:shell_error)
    echohl None
    silent! undo
  endif
endfunction

" Run {cmd} once the buffer is shown in a window, so that it sees the final
" 'textwidth', 'shiftwidth' and 'expandtab'; run it right away if it is shown.
function! formatprgs#on_bufwinenter(group, cmd) abort
  execute 'autocmd' a:group 'BufWinEnter <buffer> ++once' a:cmd
  if bufwinnr(bufnr('%')) != -1
    execute 'doautocmd <nomodeline>' a:group 'BufWinEnter <buffer>'
  endif
endfunction

" Append {cmd} and the removal of augroup {group} to b:undo_ftplugin.
" :autocmd would take a following '|' as part of its command, hence :execute.
function! formatprgs#undo(group, cmd) abort
  let cmd = a:cmd . printf(' | execute ''silent! autocmd! %s * <buffer>''', a:group)
  let b:undo_ftplugin = empty(get(b:, 'undo_ftplugin', ''))
        \ ? cmd : b:undo_ftplugin . ' | ' . cmd
endfunction

" Whether to use formatter {name}: the one chosen by b:formatprg if that is
" executable, otherwise any {name} found on $PATH.
function! formatprgs#use(name) abort
  let choice = get(b:, 'formatprg', '')
  return !empty(choice) && executable(choice) ? choice ==# a:name : executable(a:name)
endfunction

" The full path of the current file, escaped for a :! command.
function! formatprgs#path() abort
  return shellescape(expand('%:p'), 1)
endfunction

" Filter the whole buffer through {cmd}, keeping the view.
" While typing, leave automatic wrapping to Vim.
function! formatprgs#filter(cmd) abort
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
function! s:range() abort
  return printf(' --range-start %d --range-end %d',
        \ line2byte(v:lnum) - 1, line2byte(v:lnum + v:count) - 1)
endfunction

" Use Prettier as 'formatexpr'.
function! formatprgs#prettier_setup(default_args) abort
  let b:formatprg_cmd = 'prettier ' . get(b:, 'formatprg_args', a:default_args)
  setlocal formatexpr=formatprgs#prettier()
endfunction

function! formatprgs#prettier() abort
  return formatprgs#filter(b:formatprg_cmd .
        \ (&textwidth > 0 ? ' --print-width=' . &textwidth : '') .
        \ ' --tab-width=' . shiftwidth() .
        \ (&expandtab ? '' : ' --use-tabs') .
        \ s:range() .
        \ ' --stdin-filepath=' . formatprgs#path())
endfunction

" clang-format as 'formatexpr'. Without a .clang-format file, base the style
" on {style} and Vim's options; {stdin_name} names an unsaved buffer.
function! formatprgs#clang_format(style, stdin_name) abort
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
  return formatprgs#filter('clang-format ' .
        \ get(b:, 'formatprg_args', default_style) .
        \ ' --assume-filename=' . (filereadable(expand('%')) ? formatprgs#path() : shellescape(a:stdin_name)) .
        \ printf(' --lines=%d:%d -', v:lnum, v:lnum + v:count - 1))
endfunction

function! formatprgs#stylua() abort
  return formatprgs#filter('stylua ' .
        \ get(b:, 'formatprg_args', '') . ' ' .
        \ (&textwidth > 0 ? ' --column-width ' . &textwidth : '') .
        \ ' --indent-type ' . (&expandtab ? 'Spaces' : 'Tabs') .
        \ ' --indent-width ' . shiftwidth() .
        \ ' --stdin-filepath=' . formatprgs#path() .
        \ s:range() . ' -')
endfunction

" The functions below return values for 'formatprg'.

function! formatprgs#biome(default_args) abort
  return 'biome format ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ '--stdin-file-path=' . expand('%:p:S') . ' ' .
        \ (&textwidth > 0 ? '--line-width=' . &textwidth . ' ' : '') .
        \ '--indent-width=' . shiftwidth() . ' ' .
        \ '--indent-style=' . (&expandtab ? 'space' : 'tab')
endfunction

" Read ~/.config/uncrustify/{filetype}.cfg if present.
function! formatprgs#uncrustify(args) abort
  let cfg = (empty($XDG_CONFIG_HOME) ? expand('~/.config') : $XDG_CONFIG_HOME) .
        \ '/uncrustify/' . &filetype . '.cfg'
  return 'uncrustify ' . a:args . ' ' .
        \ (&textwidth > 0 ? ' --set code_width=' . &textwidth . ' --set cmt_width=' . &textwidth : '') .
        \ ' --set indent_columns=' . shiftwidth() . (&expandtab ? ' --set indent_with_tabs=0' : '') .
        \ (filereadable(expand('%')) ? ' --assume ' . expand('%:p:S') : '') .
        \ (filereadable(cfg) ? ' -c ' . shellescape(cfg) : '') .
        \ ' -'
endfunction

function! formatprgs#astyle(default_args) abort
  return 'astyle ' . get(b:, 'formatprg_args', a:default_args) . ' ' .
        \ (&textwidth > 0 ? ' --max-code-length=' . &textwidth : '') .
        \ ' --indent=spaces=' . shiftwidth() . (&expandtab ? ' --convert-tabs' : '') .
        \ ' -'
endfunction

" shfmt indents with tabs for --indent 0.
function! formatprgs#shfmt() abort
  return 'shfmt ' . get(b:, 'formatprg_args', '--space-redirects --case-indent --simplify') .
        \ ' --indent ' . (&expandtab ? shiftwidth() : 0)
endfunction

" {tidy} is 'tidy' or 'tidy -xml'.
" See https://stackoverflow.com/questions/7151180/use-html-tidy-to-just-indent-html-code
function! formatprgs#tidy(tidy) abort
  return a:tidy . ' ' .
        \ get(b:, 'formatprg_args', '--quiet --show-errors 0 -bare --show-body-only auto -wrap 0 -utf8') . ' ' .
        \ '-indent ' . (&expandtab ? '' : '--indent-with-tabs ') . '--indent-spaces ' . shiftwidth()
endfunction
