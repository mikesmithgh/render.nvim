#!/bin/sh

trap_int() {
    exit 0
}

trap trap_int INT

delay=0
video=0
video_length=0
for arg in "$@"; do
  case $arg in
    "-T"*) 
      delay=$(echo "$arg" | cut -c 3-)
      ;;
    "-v") 
      video=1
      ;;
    "-V"*) 
      video_length=$(echo "$arg" | cut -c 3-)
      ;;
  esac 
done

sleep "$delay"
if [ $video = 1 ]; then
  if [ "$video_length" = 0 ]; then
    tail -f /dev/null
  else
    sleep "$video_length"
  fi
fi
