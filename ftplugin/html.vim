if &filetype !~# '^x\?html$' | finish | endif

augroup formatprgsHTML
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

if executable('tidy')
  " See https://stackoverflow.com/questions/7151180/use-html-tidy-to-just-indent-html-code
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'tidy ' .
        \ ((&filetype ==# 'xhtml') ? '-xml ' : '') . '-quiet ' .
        \ '--show-errors 0 -bare --show-body-only auto -wrap 0 -utf8 ' .
        \ '-indent ' . (&expandtab ? '' : '--indent-with-tabs ') . '--indent-spaces ' . shiftwidth()
        " \ (has('win32') ? ' 2>nul' : ' 2>/dev/null') .
  compiler tidy
elseif executable('html-beautify')
  " html-beautify is in js-beautify node package
  " npm -g install js-beautify
  autocmd BufWinEnter <buffer> ++once let &l:formatprg = 'html-beautify ' . (&expandtab ? '' : '--indent-with-tabs ') . '-s ' . shiftwidth() . ' -f -'
elseif executable('prettier')
  let b:prettier_config = isdirectory(expand('%:p')) ? trim(system('prettier --find-config-path ' .expand('%:p:S'))) : ''
  if v:shell_error | let b:prettier_config = '' | endif
  function! s:PrettierFormatexpr() abort
    let start = v:lnum
    let end   = v:lnum + v:count - 1
    let cmd = 'prettier --single-quote --parser=' . &filetype . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . shellescape(b:prettier_config) . ' ' : '') .
        \ '--stdin-filepath=%:S ' .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth . ' ' : '') .
        \ '--tab-width=' . shiftwidth() . ' ' .
        \ (&expandtab ? '' : '--use-tabs ') .
          \  printf(' --range-start %d --range-end %d -', start, end)
    exe start ',' end '!' cmd
  endfunction
  setlocal formatexpr=<SID>PrettierFormatexpr()
endif

" Cleanly undo buffer-local changes when leaving this filetype
let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
      \ . 'setlocal formatprg< | silent! augroup formatprgsHTML | autocmd! * <buffer> | augroup END | unlet! b:prettier_config'
