if !executable('tombi') | finish | endif

augroup formatprgsToml
  autocmd! * <buffer>
  if exists('##ShellFilterPost')
    autocmd ShellFilterPost <buffer> if v:shell_error | echohl WarningMsg | echomsg printf('shell filter returned error %d, undoing changes', v:shell_error) | echohl None | silent! undo | endif
  endif
augroup END

" See https://github.com/tombi-toml/tombi/pull/1044#issuecomment-3465851563
let &l:formatprg = printf('tombi format %s%s - %s',
      \ get(b:, 'formatprg_args', ''),
      \ filereadable(expand('%')) ? ' --stdin-filename ' . shellescape(expand('%:p'), 1) : '',
      \ has('win32') ? '2>nul' : '2>/dev/null')

let b:undo_ftplugin = (empty(get(b:, 'undo_ftplugin', '')) ? '' : b:undo_ftplugin . ' | ') .
      \ 'setlocal formatprg< | if &filetype !=# ''' . &filetype . ''' | unlet! b:formatprg_args | endif | execute ''silent! autocmd! formatprgsToml * <buffer>'''
