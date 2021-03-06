" ProportionalResize/Record.vim: Automatically adapt the window proportions after Vim is resized.
"
" DEPENDENCIES:
"   - ProportionalResize.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.02.005	15-Dec-2014	Triggering a CursorHold event after resizing
"				could abort the querying for the password of an
"				encrypted file (e.g. via :tabedit
"				encrypted.txt). Instead of feedkey()'ing
"				apparently not so neutral :<Esc> keys,
"				temporarily install additional frequent autocmds
"				on CursorMoved[I], (Buf|Win)Leave.
"   1.01.004	16-May-2014	BUG: Always restore the original 'updatetime'
"				option value after the resize. Otherwise, the
"				lower value may persist, e.g. when the "Stale
"				window dimensions record" error is given.
"   1.00.003	04-Mar-2013	A switch of tab pages can also trigger the
"				VimResized event, e.g. when running maximized /
"				fullscreen and one tab has scrollbars on both
"				sides due to a vertical split, but the other
"				hasn't. Don't trigger the adaptation then, and
"				also don't warn about stale window dimensions
"				record.
"	002	02-Mar-2013	Expose s:RecordDimensions() for use in the
"				command wrapper.
"	001	04-Feb-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ProportionalResize#Record#RecordDimensions()
    let s:dimensions = ProportionalResize#GetDimensions()
    return s:dimensions
endfunction

function! s:AfterResize()
    if exists('s:save_updatetime')
	let &updatetime = s:save_updatetime
	unlet s:save_updatetime
    endif

    if s:dimensions.tabnr != tabpagenr()
	" A switch of tab pages can also trigger the VimResized event, e.g. when
	" running maximized / fullscreen and one tab has scrollbars on both
	" sides due to a vertical split, but the other hasn't.
	return
    endif
    if s:dimensions.winNum != winnr('$')
	call ingo#msg#ErrorMsg('Stale window dimensions record; cannot correct window sizes')
	call ProportionalResize#Record#RecordDimensions()
	return
    endif

    call ProportionalResize#AdaptWindowSizes(s:dimensions)
    call ProportionalResize#Record#RecordDimensions()
endfunction

function! s:RecordResize()
    if ! exists('s:save_updatetime') && g:ProportionalResize_UpdateTime < &updatetime
	let s:save_updatetime = &updatetime
	let &updatetime = g:ProportionalResize_UpdateTime
    endif

    " It seems that during resizing, no CursorHold events are fired. As
    " triggering a CursorHold update can badly affect Vim (we might be in the
    " middle of a query of an encryption password, for example), temporarily
    " install additional frequent autocmds instead.
    autocmd! ProportionalResize CursorHold,CursorHoldI,CursorMoved,CursorMovedI,BufLeave,WinLeave * call <SID>AfterResize() |
    \   execute 'autocmd! ProportionalResize CursorHold,CursorHoldI,CursorMoved,CursorMovedI,BufLeave,WinLeave *' |
    \   execute 'autocmd! ProportionalResize' g:ProportionalResize_RecordEvents '* call ProportionalResize#Record#RecordDimensions()'
endfunction

function! ProportionalResize#Record#InstallHooks()
    augroup ProportionalResize
	autocmd!

	if ! empty(g:ProportionalResize_RecordEvents)
	    call ProportionalResize#Record#RecordDimensions()

	    autocmd VimEnter,GUIEnter      * call ProportionalResize#Record#RecordDimensions()
	    execute 'autocmd' g:ProportionalResize_RecordEvents '* call ProportionalResize#Record#RecordDimensions()'
	    autocmd VimResized             * call <SID>RecordResize()
	endif
    augroup END
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
