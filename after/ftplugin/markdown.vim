if !executable('prettier') | finish | endif

call formatprgs#init('formatprgsMarkdown')

call formatprgs#prettier_setup('--log-level=error --no-color --no-error-on-unmatched-pattern --single-quote --parser=markdown')

call formatprgs#undo('formatprgsMarkdown', 'setlocal formatexpr< | unlet! b:formatprg_cmd b:formatprg_args')
