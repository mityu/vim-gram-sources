scriptversion 3
let s:cpoptions_save = &cpoptions
set cpoptions&vim

function! gram#sources#gitfiles#launch() abort
  if !s:gitfiles.init()
    return
  endif
  call gram#select(s:source)
endfunction

if !exists('s:did_init')
  let s:did_init = 1


  let s:gitfiles = {'_job_id': 0}
  const s:upper_dir = '..' .. fnamemodify(getcwd(), ':p')[-1 :]

  function! s:gitfiles.init() abort
    let self.parent_dir = expand('%:h')
    if self.parent_dir ==# ''
      let self.parent_dir = getcwd()
    endif

    let self.git_root = finddir('.git', self.parent_dir .. ';')
    if self.git_root ==# ''
      return v:false
    endif

    let self.git_root = fnamemodify(fnamemodify(self.git_root, ':h:p'), ':p')

    return v:true
  endfunction

  function! s:gitfiles.list() abort
    call self.kill()
    let self._job_id = job_start('git ls-files', {
          \ 'out_cb': self.job_callback,
          \ 'cwd': self.git_root,
          \ })
  endfunction

  function! s:gitfiles.job_callback(ch, file) abort
    let upper_depth = 0
    let base = fnamemodify(self.parent_dir, ':p')
    let file_fullpath = self.git_root .. a:file
    while stridx(file_fullpath, base) == -1
      let upper_depth += 1
      let base = simplify(base .. s:upper_dir)
    endwhile
    let file_displaypath =
          \ repeat('../', upper_depth) .. file_fullpath[strlen(base) :]
    call gram#add_items([{'word': file_fullpath, 'abbr': file_displaypath}])
  endfunction

  function! s:gitfiles.kill() abort
    try
      " FIXME: Why 'Key not present in Dictionary "_job_id"' error is raised?
      if get(self, '_job_id', 0) != 0
        call job_stop(self._job_id)
        let self._job_id = 0
      endif
    catch
      echomsg v:exception
    endtry
  endfunction


  let s:source = {'name': 'gitfiles'}
  let s:source.hook = {
        \ 'ExitPre': s:gitfiles.kill,
        \ }

  function! s:source.completefunc(input) abort
    call gram#set_items([])
    call s:gitfiles.list()
  endfunction

  function! s:source.callback(item) abort
    edit `=a:item.word`
  endfunction
endif

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
