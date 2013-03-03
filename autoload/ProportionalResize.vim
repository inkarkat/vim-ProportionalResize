" ProportionalResize.vim: Adapt the window proportions after Vim is resized.
"
" DEPENDENCIES:
"   - ProportionalResize/Record.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	02-Mar-2013	FIX: In the command wrapper, must record the
"				previous dimensions (before and after), not just
"				get them. Otherwise, one may still get the
"				"stale window dimensions" error, because the
"				wrapped resizing command still triggers the
"				VimResized event, and therefore our autocmds.
"				With the dimensions properly recorded, that will
"				then be a no-op because there's no change in
"				dimensions.
"	001	04-Feb-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ProportionalResize#GetDimensions()
    return {
    \   'columns': &columns,
    \   'lines': &lines,
    \   'winNum': winnr('$'),
    \   'winrestCommands': winrestcmd()
    \}
endfunction

function! s:Scale( command, scaleFactor, isVertical )
    let l:isVerticalCommand = (a:command =~# '^vert')
    if l:isVerticalCommand && a:isVertical || ! l:isVerticalCommand && ! a:isVertical
	return substitute(a:command, '\d\+$', '\=float2nr(round(str2nr(submatch(0)) * a:scaleFactor))', '')
    else
	return a:command
    endif
endfunction
function! ProportionalResize#AdaptWindowSizes( previousDimensions )
    let l:currentDimensions = ProportionalResize#GetDimensions()
    if l:currentDimensions.columns == a:previousDimensions.columns && l:currentDimensions.lines == a:previousDimensions.lines
    \   || winnr('$') == 1
	" Nothing to do.
	return
    endif

    let l:columnsScaleFactor = 1.0 * l:currentDimensions.columns / a:previousDimensions.columns
    let l:linesScaleFactor   = 1.0 * l:currentDimensions.lines / a:previousDimensions.lines

"****D echomsg '**** scaling' string(l:linesScaleFactor) 'vert' string(l:columnsScaleFactor)
"****D echomsg '****' string(a:previousDimensions)

    let l:winrestCommands = split(a:previousDimensions.winrestCommands, '|')
    if l:currentDimensions.columns != a:previousDimensions.columns
	call map(l:winrestCommands, 's:Scale(v:val, l:columnsScaleFactor, 1)')
    endif
    if l:currentDimensions.lines != a:previousDimensions.lines
	call map(l:winrestCommands, 's:Scale(v:val, l:linesScaleFactor, 0)')
    endif
    execute join(l:winrestCommands, '|')
"****D echomsg '####' join(l:winrestCommands, '|')
endfunction

function! ProportionalResize#CommandWrapper( resizeCommand )
    let l:previousDimensions = ProportionalResize#Record#RecordDimensions()
    try
	execute a:resizeCommand
	call ProportionalResize#AdaptWindowSizes(l:previousDimensions)
	call ProportionalResize#Record#RecordDimensions()
    catch /^Vim\%((\a\+)\)\=:E/
	call ingo#msg#VimExceptionMsg()
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
