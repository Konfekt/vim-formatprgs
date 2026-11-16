if !executable('prettier') | finish | endif

call formatprgs#init('formatprgsYaml')

call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=' . &filetype)

call formatprgs#undo('formatprgsYaml', 'setlocal formatexpr< | unlet! b:formatprg_cmd b:formatprg_args')
