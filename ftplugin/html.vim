if &filetype !~# 'x\?html' | finish | endif

augroup formatprgsHTML
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | execute 'echom "shell filter returned error " . v:shell_error . ", undoing changes"' | undo | endif
  endif
augroup END

if executable('tidy')
  " See https://stackoverflow.com/questions/7151180/use-html-tidy-to-just-indent-html-code
  autocmd formatprgsHTML BufWinEnter <buffer> ++once let &l:formatprg = 'tidy -xml -quiet ' .
        \ ' --show-errors 0 -bare --show-body-only auto -wrap 0 '.
        \ ' -indent ' . (&expandtab ? '' : '--indent-with-tabs') . ' --indent-spaces ' . &l:shiftwidth . 
        \ ' || exit 0'
        " \ (has('win32') ? ' 2>nul' : ' 2>/dev/null') .
  compiler tidy
elseif executable('html-beautify')
  " html-beautify is in js-beautify node package
  " npm -g install js-beautify
  autocmd formatprgsHTML BufWinEnter <buffer> ++once let &l:formatprg = 'html-beautify -s ' . &l:shiftwidth . ' -f -'
elseif executable('prettier')
  let b:prettier_config = trim(system('prettier --find-config-path ' . expand('%:p:S')))
  autocmd formatprgsHTML BufWinEnter <buffer> ++once let &l:formatprg =
        \ 'prettier --stdin-filepath=%:S --single-quote --parser=' . &filetype . ' ' .
        \ (&textwidth > 0 ? '--print-width=' . &textwidth : '') . ' ' .
        \ '--tab-width=' . &l:shiftwidth . ' ' . (&expandtab ? '' : '--use-tabs') . ' ' .
        \ (filereadable(b:prettier_config) ? '--config ' . b:prettier_config : '') . ' --'
endif

