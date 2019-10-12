scriptversion 3
let s:cpoptions_save = &cpoptions
set cpoptions&vim

let s:source = {'name': 'lines'}

function! s:source.callback(item) abort
  call cursor(a:item.user_data, 0)
endfunction

function! gram#sources#lines#launch() abort
  let line_formatter = '%' .. len(string(line('$'))) .. 'd'
  let source = deepcopy(s:source)
  let source.items = map(getline(1, '$'), {idx, text-> {
        \ 'word': text,
        \ 'abbr': printf(line_formatter, idx + 1) .. ' ' .. text,
        \ 'user_data': idx + 1
        \ }})
  call gram#select(source)
endfunction

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
