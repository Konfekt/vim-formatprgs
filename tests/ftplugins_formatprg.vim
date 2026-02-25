" Run from the repo root with:
"   vim -Nu NONE -n -es -S test_ftplugins_formatprg.vim
"
" This writes results to: ftplugin_formatprg_test.log

set nomore
set rtp^=.
filetype plugin on

let s:fts = [
      \ 'bib',
      \ 'c',
      \ 'cmake',
      \ 'css',
      \ 'html',
      \ 'xhtml',
      \ 'java',
      \ 'javascript',
      \ 'json',
      \ 'lua',
      \ 'mail',
      \ 'markdown',
      \ 'perl',
      \ 'python',
      \ 'ruby',
      \ 'sh',
      \ 'sql',
      \ 'svelte',
      \ 'tex',
      \ 'toml',
      \ 'typescript',
      \ 'vue',
      \ 'xml',
      \ 'yaml',
      \ 'zsh',
      \ ]

let s:out = []
call add(s:out, 'ftplugin formatprg/formatexpr smoke test (repo ftplugins first on rtp)')
call add(s:out, '=====================================================================')

for s:ft in s:fts
  enew
  setlocal buftype=nofile bufhidden=wipe noswapfile

  " Simulate "filetype changed in an already-visible buffer"
  setlocal filetype=__test__
  execute 'setlocal filetype=' . s:ft

  call add(s:out, printf('%-12s formatprg=%s', s:ft, string(&l:formatprg)))
  call add(s:out, printf('%-12s formatexpr=%s', '',   string(&l:formatexpr)))
endfor

call writefile(s:out, 'ftplugin_formatprg_test.log')
qa!
