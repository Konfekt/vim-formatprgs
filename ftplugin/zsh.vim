setlocal textwidth=80
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

if executable('shfmt')
  augroup vimrcFileTypeZsh
    autocmd! * <buffer>
    if exists('##ShellFilterPost')
      autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
    endif
    autocmd BufWinEnter <buffer> let &l:formatprg =
          \ 'shfmt -ln posix -sr -ci -s -i ' . &l:shiftwidth
  augroup END
endif
if executable('format_shell_cmd.py')
  " From https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_shell_cmd.py
  nnoremap <buffer> gqqq :<c-u>.!format_shell_cmd.py<cr>
endif

nnoremap <buffer> JJ    :<c-u>call <sid>ZshJoin()<cr>
nnoremap <buffer> r<CR> :<c-u>call <sid>ZshSplit()<cr>

" The rest of the file needs to be :sourced only once per session.
if exists('s:loaded_functions') || &cp | finish | endif
let s:loaded_functions = 1

" From https://github.com/ericbn/dotfiles-vim/blob/e904bba56c661bd0ff6c3f454a33285e13c9472b/after/ftplugin/zsh.vim

function s:ZshJoin()
  let v:errmsg = ""
  silent! s/\vif\s+(.*)\s*[;\n]+\s*then\n^\s*(.*)\s*\n^\s*fi/if \1 \2/
  if v:errmsg != ""
    silent! s/\vfor\s+(.{-})\s+in\s+(.*)\s*[;\n]+\s*do\n^\s*(.*)\s*\n^\s*done/for \1 (\2) \3/
  endif
  if v:errmsg != ""
    silent! s/\v(\S.*)\s*\n\s*(\S.*)\s*$/\1; \2/
  endif
endfunction
function s:ZshSplit()
  let v:errmsg = ""
  silent! s/\v^(\s*)(.*)\s+\&\&\s+(.*)\s*$/\=submatch(1)."if ".submatch(2)."; then\r".submatch(1).repeat(" ", shiftwidth()).submatch(3)."\r".submatch(1)."fi"/
  if v:errmsg != ""
    silent! s/\v^(\s*)for\s+(.{-})\s+\((.{-})\)\s+(.*)\s*$/\=submatch(1)."for ".submatch(2)." in ".submatch(3)."; do\r".submatch(1).repeat(" ", shiftwidth()).submatch(4)."\r".submatch(1)."done"/
  endif
  if v:errmsg != ""
    silent! s/\v^(\s*)(.{-})\s*;\s*/\1\2\r\1/
  endif
endfunction
