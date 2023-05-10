#!/usr/bin/env osascript
# return x y width height of frontmost window
tell application "System Events"
  set targetProcess to first application process whose frontmost is true
  set targetWindow to first window of targetProcess
  set windowPosAndSize to (position, size) of targetWindow
  set AppleScript's text item delimiters to linefeed
end tell
return windowPosAndSize as string

