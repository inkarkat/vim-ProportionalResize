" ProportionalResize.vim: Adapt the window sizes after Vim is resized.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	04-Feb-2013	file creation

function! ProportionalResize#RecordResize()
    autocmd! ProportionalResize CursorHold,CursorHoldI * call ProportionalResize#AdaptWindowSizes() | autocmd! ProportionalResize CursorHold,CursorHoldI * call ProportionalResize#RecordDimensions()
endfunction
function! s:Scale( command, scaleFactor, isVertical )
    let l:isVerticalCommand = (a:command =~# '^vert')
    if l:isVerticalCommand && a:isVertical || ! l:isVerticalCommand && ! a:isVertical
	return substitute(a:command, '\d\+$', '\=float2nr(round(str2nr(submatch(0)) * a:scaleFactor))', '')
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

echomsg '**** scaling' string(l:linesScaleFactor) 'vert' string(l:columnsScaleFactor)
echomsg '****' string(g:ProportionalResize_PreviousWindowDimensions)

    if g:ProportionalResize_PreviousWindowDimensions[0] != winnr('$')
	call ingo#msg#ErrorMsg('Stale window dimensions record; cannot correct window sizes')
	call ProportionalResize#RecordDimensions()
	return
    endif

    let l:winrestCommands = split(g:ProportionalResize_PreviousWindowDimensions[1], '|')
    if l:currentSize[0] != g:ProportionalResize_PreviousSize[0]
	call map(l:winrestCommands, 's:Scale(v:val, l:columnsScaleFactor, 1)')
    endif
    if l:currentSize[1] != g:ProportionalResize_PreviousSize[1]
	call map(l:winrestCommands, 's:Scale(v:val, l:linesScaleFactor, 0)')
    endif
    execute join(l:winrestCommands, '|')
echomsg '####' join(l:winrestCommands, '|')

    call ProportionalResize#RecordDimensions()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
