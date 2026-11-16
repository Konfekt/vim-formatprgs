" Regression tests for the ftplugins of vim-formatprgs.
"
" Run them with tests/run.sh, which starts Vim and Neovim with this file.
" Formatters are replaced by stubs that log their arguments and echo stdin.

set nomore shell=/bin/sh
let s:root = fnamemodify(expand('<sfile>:p:h'), ':h')
execute 'set runtimepath^=' . fnameescape(s:root)
execute 'set runtimepath+=' . fnameescape(s:root . '/after')
filetype plugin on

let s:tmp = resolve(tempname())
call mkdir(s:tmp, 'p')
let s:log = s:tmp . '/formatter.log'
let $FORMATPRGS_LOG = s:log
let s:real = {}
for s:name in ['jq', 'prettier', 'yapf', 'autopep8']
  let s:real[s:name] = exepath(s:name)
endfor
let s:bin_count = 0
let s:path = $PATH

" Make exactly the given formatters available on $PATH.
" A name prefixed with 'real:' links the formatter installed on the system.
function! s:Tools(...) abort
  call s:ToolList(a:000)
endfunction

function! s:ToolList(names) abort
  let s:bin_count += 1
  let dir = s:tmp . '/bin' . s:bin_count
  call mkdir(dir, 'p')
  for name in a:names
    if name =~# '^real:'
      let name = name[5:]
      if empty(get(s:real, name, ''))
        throw 'skipped: ' . name . ' is not installed'
      endif
      " Keep the original $PATH for interpreters such as node or python.
      call writefile(['#!/bin/sh',
            \ 'PATH=' . shellescape(s:path) . ' exec ' . shellescape(s:real[name]) . ' "$@"'],
            \ dir . '/' . name)
    else
      call writefile(['#!/bin/sh',
            \ 'printf "%s\n" "${0##*/} $*" >> "$FORMATPRGS_LOG"',
            \ 'exec /bin/cat'], dir . '/' . name)
    endif
    call setfperm(dir . '/' . name, 'rwxr-xr-x')
  endfor
  let $PATH = dir
  call delete(s:log)
endfunction

function! s:Log() abort
  return filereadable(s:log) ? join(readfile(s:log), "\n") : ''
endfunction

function! s:Buffer(filetype, ...) abort
  enew!
  setlocal buftype=nofile noswapfile
  call setline(1, a:0 ? a:1 : ['a', 'b', 'c'])
  execute 'setlocal filetype=' . a:filetype
endfunction

function! Test_undo_ftplugin_not_clobbered_by_runtime() abort
  call s:Tools('clang-format')
  call s:Buffer('c')
  call assert_notequal('', &l:formatexpr)
  setlocal filetype=text
  call assert_equal('', &l:formatexpr)

  call s:Tools()
  call s:Buffer('mail')
  call assert_notequal(&g:formatlistpat, &l:formatlistpat)
  setlocal filetype=text
  call assert_equal(&g:formatlistpat, &l:formatlistpat)
endfunction

function! Test_xml_formatprg_not_shadowed_by_runtime_formatexpr() abort
  call s:Tools('xmllint')
  call s:Buffer('xml', ['<a><b/></a>'])
  call assert_equal('', &l:formatexpr)
  silent normal! gggqG
  call assert_match('^xmllint ', s:Log())
endfunction

function! Test_xml_tidy_does_not_set_compiler() abort
  call s:Tools('tidy')
  call s:Buffer('xml')
  call assert_match('^tidy -xml ', &l:formatprg)
  call assert_false(exists('b:current_compiler'))
endfunction

function! Test_json_keeps_runtime_ftplugin() abort
  call s:Tools()
  call s:Buffer('json')
  " Set by Vim's own json ftplugin.
  call assert_equal('', &l:commentstring)
  call assert_notmatch('t', &l:formatoptions)
endfunction

function! Test_json_jq_indents_with_tabs() abort
  call s:Tools('real:jq')
  enew!
  setlocal buftype=nofile noexpandtab shiftwidth=4
  call setline(1, '{"a":1}')
  setlocal filetype=json
  silent normal! gggqG
  call assert_equal(['{', "\t\"a\": 1", '}'], getline(1, '$'))

  enew!
  setlocal buftype=nofile expandtab shiftwidth=8
  call setline(1, '{"a":1}')
  setlocal filetype=json
  silent normal! gggqG
  call assert_equal(['{', '       "a": 1', '}'], getline(1, '$'))
endfunction

function! Test_json_formatter_choice_is_per_buffer() abort
  call s:Tools('real:jq', 'biome')
  enew!
  let b:formatprg = 'biome'
  setlocal buftype=nofile filetype=json
  call assert_match('^biome format ', &l:formatprg)
  enew!
  setlocal buftype=nofile filetype=json
  call assert_match('^jq ', &l:formatprg)
endfunction

function! Test_json_prettier_used_and_parses_json() abort
  call s:Tools('prettier')
  call s:Buffer('json', ['{"a":1}'])
  silent normal! gggqG
  call assert_match('^prettier .*--parser=json', s:Log())
endfunction

function! Test_html_honors_b_formatprg_biome() abort
  call s:Tools('prettier', 'biome')
  enew!
  let b:formatprg = 'biome'
  setlocal buftype=nofile filetype=html
  call assert_equal('', &l:formatexpr)
  call assert_match('^biome format ', &l:formatprg)
endfunction

function! Test_xhtml_prettier_uses_html_parser() abort
  call s:Tools('prettier')
  call s:Buffer('xhtml')
  normal! gqq
  call assert_match('--parser=html ', s:Log())
endfunction

function! Test_prettier_honors_b_formatprg_args() abort
  for ft in ['javascript', 'typescript']
    call s:Tools('prettier')
    enew!
    let b:formatprg_args = '--marker'
    setlocal buftype=nofile
    execute 'setlocal filetype=' . ft
    normal! gqq
    call assert_match('^prettier --marker ', s:Log(), ft)
  endfor
endfunction

function! Test_java_uncrustify_formats_as_java() abort
  call s:Tools('uncrustify')
  call s:Buffer('java')
  call assert_match(' -l JAVA ', &l:formatprg)
endfunction

function! Test_uncrustify_config_follows_filetype() abort
  let cfg = s:tmp . '/xdg/uncrustify'
  call mkdir(cfg, 'p')
  call writefile([], cfg . '/c.cfg')
  call writefile([], cfg . '/cpp.cfg')
  let $XDG_CONFIG_HOME = s:tmp . '/xdg'
  try
    call s:Tools('uncrustify')
    call s:Buffer('c')
    call assert_match('/c\.cfg', &l:formatprg)
    call s:Buffer('cpp')
    call assert_match('/cpp\.cfg', &l:formatprg)
  finally
    unlet $XDG_CONFIG_HOME
  endtry
endfunction

function! Test_perltidy_formatprg_is_buffer_local() abort
  call s:Tools('perltidy')
  call s:Buffer('perl')
  call assert_match('^perltidy ', &l:formatprg)
  enew!
  call assert_equal('', &g:formatprg)
  call assert_equal('', &l:formatprg)
endfunction

function! Test_perltidy_ignores_clang_format_config() abort
  let dir = s:tmp . '/project'
  call mkdir(dir, 'p')
  call writefile([], dir . '/.clang-format')
  call s:Tools('clang-format', 'perltidy')
  execute 'edit! ' . fnameescape(dir . '/x.c')
  call setline(1, 'int x;')
  normal! gqq
  setlocal filetype=perl
  call assert_match('^perltidy ', &l:formatprg)
  call assert_notmatch('clang-format', &l:formatprg)
  bwipeout!
endfunction

function! Test_zsh_shfmt_indents_with_tabs() abort
  call s:Tools('shfmt')
  enew!
  setlocal buftype=nofile noexpandtab shiftwidth=4 filetype=zsh
  call assert_match('--indent 0$', &l:formatprg)
endfunction

function! Test_formatexpr_not_run_while_typing() abort
  call s:Tools('clang-format')
  call s:Buffer('c', [''])
  setlocal textwidth=20 formatoptions=t
  execute "normal! ione two three four five six seven eight\<Esc>"
  call assert_equal('', s:Log())
  call assert_true(line('$') > 1, 'Vim wraps the text itself')
endfunction

function! Test_range_offsets_are_zero_based() abort
  for [ft, tool] in [['yaml', 'prettier'], ['lua', 'stylua']]
    call s:Tools(tool)
    call s:Buffer(ft)
    2normal! gqq
    call assert_match('--range-start 2 --range-end 4', s:Log(), ft)
  endfor
endfunction

function! Test_special_characters_in_file_name() abort
  call s:Tools('prettier')
  call s:Buffer('yaml')
  execute 'file ' . fnameescape(s:tmp . '/a#b%c.yaml')
  normal! gqq
  call assert_match('a#b%c\.yaml', s:Log())
  bwipeout!
endfunction

function! Test_python_formatters_format_stdin() abort
  for tool in ['yapf', 'autopep8']
    call s:Tools('real:' . tool)
    enew!
    let b:formatprg = tool
    setlocal buftype=nofile
    call setline(1, ['def f( a ):', '    return a'])
    setlocal filetype=python
    silent normal! gggqG
    call assert_equal(['def f(a):', '    return a'], getline(1, '$'), tool)
  endfor
endfunction

function! Test_json_prettier_formats_json() abort
  call s:Tools('real:prettier')
  call s:Buffer('json', ['{"a":1}'])
  silent normal! gggqG
  call assert_equal(['{ "a": 1 }'], getline(1, '$'))
endfunction

function! Test_python_yapf_honors_b_formatprg() abort
  call s:Tools('yapf', 'yapf3')
  enew!
  let b:formatprg = 'yapf'
  setlocal buftype=nofile filetype=python
  normal! gqq
  call assert_match('^yapf ', s:Log())
endfunction

let s:filetypes = ['bib', 'c', 'cpp', 'cmake', 'css', 'haskell', 'html', 'xhtml',
      \ 'java', 'javascript', 'json', 'lua', 'mail', 'markdown', 'pandoc', 'perl',
      \ 'python', 'ruby', 'sh', 'sql', 'svelte', 'tex', 'toml', 'typescript',
      \ 'vue', 'xml', 'yaml', 'zsh']
let s:tools = ['astyle', 'bibtex-tidy', 'biome', 'black-macchiato', 'clang-format',
      \ 'cmake-format', 'html-beautify', 'jq', 'ormolu', 'par', 'perltidy',
      \ 'prettier', 'rubocop', 'ruff', 'shfmt', 'sql-formatter', 'stylua',
      \ 'tex-fmt', 'tidy', 'tombi', 'xmllint']

function! Test_every_filetype_loads_and_unloads() abort
  for tools in [[], s:tools]
    call s:ToolList(tools)
    for ft in s:filetypes
      call s:Buffer(ft)
      silent normal! gqq
      setlocal filetype=text
      call assert_equal('', &l:formatprg, ft)
      call assert_equal('', &l:formatexpr, ft)
      call assert_notmatch('formatprgs', execute('autocmd * <buffer>'), ft)
    endfor
  endfor
endfunction

" Runner
let s:results = []
let s:failed = 0
for s:test in sort(map(filter(split(execute('function /^Test_'), "\n"),
      \ 'v:val =~# ''^function Test_'''), 'matchstr(v:val, ''Test_\w\+'')'))
  let v:errors = []
  try
    call call(s:test, [])
  catch /^skipped: /
    call add(s:results, 'SKIP ' . s:test . ': ' . v:exception[9:])
    continue
  catch
    call add(v:errors, v:exception . ' @ ' . v:throwpoint)
  finally
    let $PATH = s:path
    silent! %bwipeout!
  endtry
  if empty(v:errors)
    call add(s:results, 'PASS ' . s:test)
  else
    let s:failed += 1
    call add(s:results, 'FAIL ' . s:test)
    call extend(s:results, map(copy(v:errors), '"    " . v:val'))
  endif
endfor
call add(s:results, printf('%d failed', s:failed))
call writefile(s:results, $FORMATPRGS_RESULTS)
call delete(s:tmp, 'rf')
if s:failed | cquit! | endif
qall!
