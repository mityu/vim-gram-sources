scriptversion 3

const s:plugin_top = expand('<sfile>:p:h:h:h:h')
let s:listfile_script_path = '/script/listfiles.vim'
if has('win32')
  let s:listfile_script_path = substitute(s:listfile_script_path, '/', '\\', 'g')
endif

const s:cmd = [
  \ exepath(v:progpath),
  \ '-u', 'NONE', '-i', 'NONE', '-n', '-N', '-e', '-s',
  \ '-S', s:plugin_top .. s:listfile_script_path,
  \ ]
let s:job_id = v:null
let s:session_id = 0
let s:search_directory = ''
let s:source = {'name': 'file_rec'}

function! s:source.callback(item) abort
  edit `=a:item.user_data`
endfunction

function! s:source.completefunc(_) abort
  if s:search_directory ==# ''
    let s:search_directory = getcwd(winnr())
  endif
  let s:search_directory = fnamemodify(s:search_directory, ':p')
  call s:kill()
  call gram#set_items([])
  let s:job_id = job_start(s:cmd, {
  \ 'out_cb': function('s:out_cb', [s:search_directory, s:session_id]),
  \ 'close_cb': {-> s:kill()},
  \ 'cwd': s:search_directory,
  \ 'env': {'VIM_GRAM_FILE_REC_IGNORE_FILES': string(['.git', '.DS_Store'])},
  \ })
endfunction

function! s:out_cb(cwd, session_id, _, path) abort
  if s:session_id == a:session_id
    let fullpath = a:cwd .. a:path
    call gram#add_items([{'word': a:path, 'user_data': fullpath}])
  endif
endfunction

function! s:kill() abort
  if s:job_id != v:null && job_status(s:job_id) == 'run'
    call job_stop(s:job_id)
  endif
  let s:session_id += 1
endfunction

function! gram#sources#file_rec#launch(cwd = '') abort
  let s:search_directory = a:cwd
  call gram#select(s:source)
endfunction
