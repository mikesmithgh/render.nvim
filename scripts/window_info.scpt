#!/usr/bin/env osascript
tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set frontAppName to name of frontApp
	tell process frontAppName
		set frontWindow to first window whose value of attribute "AXMain" is true
		set {xPos, yPos} to position of frontWindow
		set {width, height} to size of frontWindow

    set toolbarWidth to 0
    set toolbarHeight to 0
    set scrollbarWidth to 0
    set scrollbarHeight to 0
    try
		  set {toolbarWidth, toolbarHeight} to value of attribute "AXSize" of value of attribute "AXTitleUIElement" of frontWindow
      set height to height - toolbarHeight - 12 # magic number, don't know why
      set yPos to yPos + toolbarHeight + 12 # magic number, don't know why
    on error
      set yPos to yPos + toolbarHeight
    end try
    try
      set {scrollbarWidth, scrollbarHeight} to size of first scroll bar of scroll area 1 of splitter group 1 of group 1 of frontWindow
      set width to width - scrollbarWidth - 7 # magic number, don't know why
    on error
    end try
    set xPos to xPos + scrollbarWidth / 2

    set AppleScript's text item delimiters to linefeed
    # return x y width height
    return (xPos, yPos, width, height) as string
	end tell
end tell




