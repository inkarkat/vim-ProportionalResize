" ProportionalResize.vim: summary
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	04-Feb-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ProportionalResize') || (v:version < 700)
    finish
endif
let g:loaded_ProportionalResize = 1

function! ProportionalResize#GetSize()
    return [&columns, &lines]
endfunction
let g:ProportionalResize_PreviousSize = ProportionalResize#GetSize()
function! ProportionalResize#Record()
    autocmd ProportionalResize CursorHold,CursorHoldI * call ProportionalResize#AdaptWindowSizes() | autocmd! ProportionalResize CursorHold,CursorHoldI
endfunction
function! s:Scale( command, scaleFactor, isVertical )
    let l:isVerticalCommand = (a:command =~# '^vert')
    if l:isVerticalCommand && a:isVertical || ! l:isVerticalCommand && ! a:isVertical
	return substitute(a:command, '\d\+$', '\=float2nr(round(submatch(0) * a:scaleFactor))', '')
    else
	return a:command
    endif
endfunction
function! ProportionalResize#AdaptWindowSizes()
    let l:currentSize = ProportionalResize#GetSize()
    if l:currentSize == g:ProportionalResize_PreviousSize || winnr('$') == 1
	" Nothing to do.
	return
    endif

    let l:columnsScaleFactor = 1.0 * l:currentSize[0] / g:ProportionalResize_PreviousSize[0]
    let l:linesScaleFactor   = 1.0 * l:currentSize[1] / g:ProportionalResize_PreviousSize[1]

    " Force another CursorHold update even when the user doesn't move the cursor
    " before the next resize.
    call setpos('.', getpos('.'))

echomsg '*** scaling' string(l:columnsScaleFactor) string(l:linesScaleFactor)
echomsg '****' winrestcmd()

    let l:winrestCommands = split(winrestcmd(), '|')
    if l:currentSize[0] != g:ProportionalResize_PreviousSize[0]
	call map(l:winrestCommands, 's:Scale(v:val, l:columnsScaleFactor, 1)')
    endif
    if l:currentSize[1] != g:ProportionalResize_PreviousSize[1]
	call map(l:winrestCommands, 's:Scale(v:val, l:linesScaleFactor, 0)')
    endif
    execute join(l:winrestCommands, '|')
echomsg '####' join(l:winrestCommands, '|')

    let g:ProportionalResize_PreviousSize = l:currentSize
endfunction
augroup ProportionalResize
    autocmd! VimEnter,GUIEnter * let g:ProportionalResize_PreviousSize = ProportionalResize#GetSize()
    autocmd! VimResized * call ProportionalResize#Record()
augroup END
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
