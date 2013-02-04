" ProportionalResizePlugin.vim: Adapt the window sizes after Vim is resized.
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

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ProportionalResize') || (v:version < 700)
    finish
endif
let g:loaded_ProportionalResize = 1

function! ProportionalResizePlugin#RecordResize()
    return [&columns, &lines]
endfunction
let g:ProportionalResize_PreviousSize = ProportionalResizePlugin#RecordResize()

function! ProportionalResizePlugin#RecordDimensions()
    let g:ProportionalResize_PreviousSize = ProportionalResizePlugin#RecordResize()
    let g:ProportionalResize_PreviousWindowDimensions = [winnr('$'), winrestcmd()]
endfunction

augroup ProportionalResize
    autocmd!
    autocmd VimEnter,GUIEnter      * call ProportionalResizePlugin#RecordDimensions()
    autocmd CursorHold,CursorHoldI * call ProportionalResizePlugin#RecordDimensions()
    autocmd VimResized             * call ProportionalResize#RecordResize()
augroup END

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
