" ProportionalResize/Record.vim: Automatically adapt the window proportions after Vim is resized.
"
" DEPENDENCIES:
"   - ProportionalResize.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	04-Feb-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:RecordDimensions()
    let s:dimensions = ProportionalResize#GetDimensions()
endfunction

function! s:TriggerCursorHold()
    call feedkeys(":\<Esc>", 'n')
endfunction

function! s:AfterResize()
    if s:dimensions.winNum != winnr('$')
	call ingo#msg#ErrorMsg('Stale window dimensions record; cannot correct window sizes')
	call s:RecordDimensions()
	return
    endif

    call ProportionalResize#AdaptWindowSizes(s:dimensions)
    call s:RecordDimensions()

    if exists('s:save_updatetime')
	let &updatetime = s:save_updatetime
	unlet s:save_updatetime
    endif
endfunction

function! s:RecordResize()
    if ! exists('s:save_updatetime') && g:ProportionalResize_UpdateTime < &updatetime
	let s:save_updatetime = &updatetime
	let &updatetime = g:ProportionalResize_UpdateTime
    endif

    " Force another CursorHold update so that we definitely get a call back
    " after the resize. (It seems that during resizing, no CursorHold events are
    " fired.)
    call s:TriggerCursorHold()

    autocmd! ProportionalResize CursorHold,CursorHoldI * call <SID>AfterResize() |
    \   execute 'autocmd! ProportionalResize' g:ProportionalResize_RecordEvents '* call <SID>RecordDimensions()'
endfunction

function! ProportionalResize#Record#InstallHooks()
    augroup ProportionalResize
	autocmd!

	if ! empty(g:ProportionalResize_RecordEvents)
	    call s:RecordDimensions()

	    autocmd VimEnter,GUIEnter      * call <SID>RecordDimensions()
	    execute 'autocmd' g:ProportionalResize_RecordEvents '* call <SID>RecordDimensions()'
	    autocmd VimResized             * call <SID>RecordResize()
	endif
    augroup END
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
