PROPORTIONAL RESIZE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

When Vim itself is resized, the rightmost and bottom windows receive or lose
the change in size; all other windows maintain their size as long as possible.
What you usually want is that _all_ window heights and widths are adapted, so
that the proportions of the windows remain constant.

This plugin defines a :ProportionalResize command that wraps Ex commands
like

    :set lines=40 columns=80
    :simalt ~m
    :Fullscreen

and scales the window sizes to the new dimensions. It also records the window
layout during brief pauses and is then able to auto-adapt after spontaneous
resizings through the mouse or window manager.

### SOURCE

- [Inspiration for this plugin](http://stackoverflow.com/questions/14649698/how-to-resize-split-windows-in-vim-proportionally)

USAGE
------------------------------------------------------------------------------

    :ProportionalResize {resize-cmd}
                            Execute {resize-cmd} (e.g. :setlocal lines=40) and
                            adapt the proportions of the current window layout to
                            the new size. So if for example you have 3 windows
                            split vertically 1:1:2, and a horizontal split 4:1,
                            the proportions will be kept instead of the rightmost
                            and bottom windows getting all the space increases.

    :NoProportionalResize {resize-cmd}
                            Execute {resize-cmd} (e.g. :setlocal lines=40) without
                            adapting the proportions of the current window layout.
                            You can wrap commands which would confuse the plugin's
                            algorithm (e.g. a rotate function that switches
                            vertical with horizontal windows), so that it won't
                            automatically adapt the window layout.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-ProportionalResize
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim ProportionalResize*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.3 or higher and the +float feature.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.000 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

The plugin can also handle spontaneous resizings (i.e. when you simply use the
mouse or your window manager's controls to resize the GVIM application / Vim
terminal window). For that, it needs to record the original window
proportions. By default, that is done whenever you pause operation
(CursorHold). If you're too impatient, you can add additional events (but
balance that with the drag on performance), e.g. WinEnter:

    let g:ProportionalResize_RecordEvents = 'CursorHold,CursorHoldI,WinEnter'

If you don't want this auto-adaptation at all, and only use the
:ProportionalResize wrapper:

    let g:ProportionalResize_RecordEvents = ''

To make the auto-adaptation react faster, the plugin decreases the
'updatetime' option temporarily while Vim is being resized. To influence the
delay, modify:

    let g:ProportionalResize_UpdateTime = 500

INTEGRATION
------------------------------------------------------------------------------

If you have any plugins or mappings that alter the size of the Vim window
(e.g. a :Fullscreen or :Maximize command) it's advisable to trigger it
through the :ProportionalResize wrapper.

TODO
------------------------------------------------------------------------------

- Adapt all tab pages, not just the current one. For :ProportionalResize, we
  can do this with :tabdo, but for the auto-adaptation, it cannot be recorded
  that easily.

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-ProportionalResize/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.02    23-Dec-2014
- Triggering a CursorHold event after resizing could abort the querying for
  the password of an encrypted file (e.g. via :tabedit encrypted.txt). Instead
  of feedkey()'ing apparently not so neutral :&lt;Esc&gt; keys, temporarily install
  additional frequent autocmds on CursorMoved[I], (Buf|Win)Leave.

##### 1.01    23-May-2014
- Add :NoProportionalResize command.
- BUG: Always restore the original 'updatetime' option value after the resize.
  Otherwise, the lower value may persist, e.g. when the "Stale window
  dimensions record" error is given.

##### 1.00    04-Mar-2013
- First published version.

##### 0.01    04-Feb-2013
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2013-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
