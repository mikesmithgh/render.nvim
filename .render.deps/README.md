# 📸 render.nvim dependencies
This folder contains dependencies that are downloaded during runtime.

- [pdubs](https://github.com/mikesmithgh/pdubs)
  - Binary command-line utility that is used to identify macos window information

# TODO: move this information to a better place
# supported flags
y = yes
* = can support, need to implement
? = can support, may not implement
~ = support different impl

  y -c         force screen capture to go to the clipboard
  y -D<display> screen capture or record from the display specified. -D 1 is main display, -D 2 secondary, etc.
  y -o         in window capture mode, do not capture the shadow of the window
  y -t<format> image format to create, default is png (other options include pdf, jpg, tiff and other formats)
  y -T<seconds> take the picture after a delay of <seconds>, default is 5
  y -x         do not play sounds
  y -l<windowid> capture this windowsid
  y -R<x,y,w,h> capture screen rect
  y -v        capture video recording of the screen
  ~ -V<seconds> limits video capture to specified seconds
  y -k        show clicks in video recording mode
  y -u        present UI after screencapture is complete. files passed to command line will be ignored

  ? -g        captures audio during a video recording using default input.


## could not figure out what commands did
  -S         in window capture mode, capture the screen not the window
  -a         do not include windows attached to selected windows
  -r         do not add dpi meta data to image

# original help

screencapture: illegal option -- -
usage: screencapture [-icMPmwsWxSCUtoa] [files]
  -c         force screen capture to go to the clipboard
  -b         capture Touch Bar - non-interactive modes only
  -C         capture the cursor as well as the screen. only in non-interactive modes
  -d         display errors to the user graphically
  -i         capture screen interactively, by selection or window
               control key - causes screenshot to go to clipboard
               space key   - toggle between mouse selection and
                             window selection modes
               escape key  - cancels interactive screenshot
  -m         only capture the main monitor, undefined if -i is set
  -D<display> screen capture or record from the display specified. -D 1 is main display, -D 2 secondary, etc.
  -o         in window capture mode, do not capture the shadow of the window
  -p         screen capture will use the default settings for capture. The files argument will be ignored
  -M         screen capture output will go to a new Mail message
  -P         screen capture output will open in Preview or QuickTime Player if video
  -I         screen capture output will open in Messages
  -B<bundleid> screen capture output will open in app with bundleid
  -s         only allow mouse selection mode
  -S         in window capture mode, capture the screen not the window
  -J<style>  sets the starting of interfactive capture
               selection       - captures screen in selection mode
               window          - captures screen in window mode
               video           - records screen in selection mode
  -t<format> image format to create, default is png (other options include pdf, jpg, tiff and other formats)
  -T<seconds> take the picture after a delay of <seconds>, default is 5
  -w         only allow window selection mode
  -W         start interaction in window selection mode
  -x         do not play sounds
  -a         do not include windows attached to selected windows
  -r         do not add dpi meta data to image
  -l<windowid> capture this windowsid
  -R<x,y,w,h> capture screen rect
  -v        capture video recording of the screen
  -V<seconds> limits video capture to specified seconds
  -g        captures audio during a video recording using default input.
  -G<id>    captures audio during a video recording using audio id specified.
  -k        show clicks in video recording mode
  -U        Show interactive toolbar in interactive mode
  -u        present UI after screencapture is complete. files passed to command line will be ignored
  files   where to save the screen capture, 1 file per screen
