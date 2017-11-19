﻿nmap <Leader>r <Plug>(quickrun)
let s:hooks = neobundle#get_hooks("vim-quickrun")
function! s:hooks.on_source(bundle)
  let g:quickrun_config = {
        \   "_": {
        \     "hook/close_quickfix/enable_success" : 1,
        \     "hook/close_buffer/enable_failure" : 1,
        \     "outputter" : "multi:buffer:quickfix",
        \     "hook/neco/enable" : 1,
        \     "hook/neco/wait" : 20,
        \     "runner": "vimproc",
        \     'hook/time/enable' : 1
        \   },
        \   'tex':{
        \     'command' : 'latexmk',
        \     'cmdopt': '-pvc',
        \     'exec': ['%c %o %s']
        \   },
        \ }
endfunction
