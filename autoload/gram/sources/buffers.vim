let s:cpoptions_save = &cpoptions
set cpoptions&vim

let s:source = {'name': 'buffers'}

function! s:source.completefunc(input) abort
  let buflist = split(execute('ls'), "\n")
  let items = []

  for buf in buflist
    let bufnr = str2nr(matchstr(buf, '^\s*\zs\d\+\ze'))
    call add(items, {
          \ 'word': buf,
          \ 'abbr': buf,
          \ 'user_data': bufnr,
          \ })
  endfor
  call gram#set_items(items)
endfunction

function! s:source.callback(selected_item) abort
  execute a:selected_item.user_data 'buffer'
endfunction

function! s:source.previewfunc(item) abort
  call gram#show_preview(getbufline(a:item.user_data, 1, 8))
endfunction

function! gram#sources#buffers#launch() abort
  call gram#select(s:source)
endfunction

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
