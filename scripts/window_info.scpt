#!/usr/bin/env osascript
tell application "System Events"
    set frontApp to first application process whose frontmost is true
    set frontAppName to name of frontApp
    tell process frontAppName
        set frontWindow to first window whose value of attribute "AXMain" is true
        set windowPosAndSize to (position, size) of frontWindow
        set AppleScript's text item delimiters to linefeed
        # return x y width height
        return windowPosAndSize as string
    end tell
end tell
