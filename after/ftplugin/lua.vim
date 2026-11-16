if !executable('stylua') | finish | endif

call formatprgs#init('formatprgsLua')

setlocal formatexpr=formatprgs#stylua()

call formatprgs#undo('formatprgsLua', 'setlocal formatprg< formatexpr< | unlet! b:formatprg_args')
