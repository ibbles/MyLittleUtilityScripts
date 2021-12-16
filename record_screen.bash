#!/bin/bash

# This script uses ffmpeg -x11grab to record a section of the screen to disk.
#
# Required Ubuntu packages:
# - ffmpeg

posX=""
posY=""
sizeX=""
sizeY=""

output="output.mp4"


function pauseWithMessage
{
  ## Print message and wait a bit for user to read it.
  echo "$1"
  for i in `seq 1 5`; do
      echo -n "Pausing for 5 seconds: $((5-$i)) second(s)"
      echo -n $'\r'
      sleep 1
  done
  echo ""
}


function parsePoint
{
    sep=$2
    if [ -z "$sep" ] ; then
        sep=x
    fi
    ## Point arguments are X/Y coordinates separated by a 'x'.
    first=`echo "$1" | cut -d "$sep" -f1`
    second=`echo "$1" | cut -d "$sep" -f2`

    if [ "$first" == "" ] || [ "$second" == "" ] ; then
        echo "Could not parse point from '$1'."
        exit 1
    fi
}


function getCurrentWindowPositionAndSize
{
    pauseWithMessage "Focus the window to record."
    window=`xdotool getactivewindow`
    pos=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3`
    # posX=`echo $pos | cut -d ',' -f1`
    # posY=`echo $pso | cud -d ',' -f2`
    parsePoint $pos ","
    posX=$first
    posY=$second
    size=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3`
    parsePoint $size
    sizeX=$first
    sizeY=$second
}




function getMousePoint
{
  pauseWithMessage "$1"

  ## Get the position.
  POS=`xdotool getmouselocation`

  ## The output is space separated.
  X=`echo $POS | cut -d\  -f1`
  Y=`echo $POS | cut -d\  -f2`

  ## Strip header from each entry in the output.
  X=${X:2}
  Y=${Y:2}
}






echo "Reading options."
while getopts "p:zus:wih" opt; do
  case $opt in
    p)
      parsePoint "$OPTARG"
      posX=$first
      posY=$second
      echo "Position $posX x $posY read from command line arguments."
      ;;
    z)
      parsePoint $(xdpyinfo  | grep -oP 'dimensions:\s+\K\S+')
      screen_width=$first
      screen_height=$second
      posX=$(($screen_width - $sizeX))
      posY=$(($screen_height - $sizeY))
      ;;
    u)
      posX=75
      posY=30
      ;;
    s)
      parsePoint "$OPTARG"
      sizeX=$first
      sizeY=$second
      echo "Size $sizeX x $sizeY read from command line arguments."
      ;;
    w)
        getCurrentWindowPositionAndSize
        ;;
    i)
        getCurrentWindowPositionAndSize
        echo "Window is ${sizeX}x${sizeY}."
        exit 0
        ;;
    h)
        echo "Usage: $0 [-p XPOSxYPOS]|[-z] [-s WIDTHxHEIGHT] [-w]"
        echo "  -p  The screen position of the top-left corner of the record area."
        echo "      Cannot be combined with -z."
        echo "  -z  The screen position of the lower-left corner of the record area relative"
        echo "      to the lower-right corner of the screen. Cannot be combined with -p."
        echo "      Must be given after -s or -w."
        echo "  -u  Set screen position to account for Unity top panel and application dock."
        echo "  -s  The size of the record area."
        echo "  -w  Set size and position from the current window, after a short delay."
        exit 0
        ;;
    ?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done
echo "Options parsed."


if [ -f "$output" ] ; then
  echo "File '$output' already exists. Remove? [y/n]"
  read doDelete
  if [ "$doDelete" == "y" ] ; then
    rm "$output"
  else
    exit 1
  fi
fi

if [ "$posX" == "" ] ; then
  getMousePoint "Please position your mouse in the top left corner of the capture area."
  posX="$X"
  posY="$Y"
  echo "Position $posX x $posY read from mouse."
fi

if [ "$sizeX" == "" ] ; then
  getMousePoint "Please position your mouse in the bottom right corner of the capture area."
  endPosX="$X"
  endPosY="$Y"
  sizeX=$(($endPosX - $posX))
  sizeY=$(($endPosY - $posY))
  echo "Size $sizeX x $sizeY read from mouse."
fi




echo "Clamping size $sizeX x $sizeY."

## Ensure that the size is positive and multiple of two in both directions.
sizeX=${sizeX#-}
sizeX=$(($sizeX / 2 * 2))
sizeY=${sizeY#-}
sizeY=$(($sizeY / 2 * 2))

echo "Capturing ${sizeX} by ${sizeY} at position ${posX} ${posY} to ${output}."


pauseWithMessage "Video capture starting in..."


# The recording command is sometimes called avconv and sometimes ffmpeg. I have
# not yet found any way to determine when it's gonna be which. Seems to change
# every fifth reboot or so. Just swap here whenever it doesn't work.

#avconv -f x11grab -r 30 -s "$sizeX"x"$sizeY" -i :0.0+"$posX","$posY" -c:v    libx264 "$output"

# There has been reports that files generated with this don't work on iPads.
#ffmpeg -f x11grab -r 30 -s ${sizeX}x${sizeY} -i :0.0+${posX},${posY} -acodec pcm_s16le -vcodec libx264 -preset medium -threads 0 -vf format=yuv420p "${output}"

# This one is supposed to work on iPads. 'format=' has been changed to 'pix_fmt'
# It does not record audio. Look into "-f pulse -ac 2 -i default" for this.
# See https://trac.ffmpeg.org/wiki/Capture/Desktop
ffmpeg -f x11grab -show_region 1 -r 30 -s ${sizeX}x${sizeY} -i :0.0+${posX},${posY} -acodec pcm_s16le -vcodec libx264 -preset medium -threads 0 -pix_fmt yuv420p "${output}"


# Possible presets: ultrafast superfast veryfast faster fast medium slow slower veryslow




## Never tried this one. There may be other things to write after -pre.
#avconv -f x11grab -r 30 -s 1280x720          -i :0.0+0,0             -vcodec libx264 -pre lossless_ultrafast -threads 0 "$output"

# Suggestions for -pre:
# ➤find /usr/share/avconv/libx264-* -exec basename '{}' ';'
#     libx264-baseline.avpreset
#     libx264-fast.avpreset
#     libx264-fast_firstpass.avpreset
#     libx264-faster.avpreset
#     libx264-faster_firstpass.avpreset
#     libx264-ipod320.avpreset
#     libx264-ipod640.avpreset
#     libx264-lossless_fast.avpreset
#     libx264-lossless_max.avpreset
#     libx264-lossless_medium.avpreset
#     libx264-lossless_slow.avpreset
#     libx264-lossless_slower.avpreset
#     libx264-lossless_ultrafast.avpreset
#     libx264-main.avpreset
#     libx264-medium.avpreset
#     libx264-medium_firstpass.avpreset
#     libx264-placebo.avpreset
#     libx264-placebo_firstpass.avpreset
#     libx264-slow.avpreset
#     libx264-slow_firstpass.avpreset
#     libx264-slower.avpreset
#     libx264-slower_firstpass.avpreset
#     libx264-superfast.avpreset
#     libx264-superfast_firstpass.avpreset
#     libx264-ultrafast.avpreset
#     libx264-ultrafast_firstpass.avpreset
#     libx264-veryfast.avpreset
#     libx264-veryfast_firstpass.avpreset
#     libx264-veryslow.avpreset
#     libx264-veryslow_firstpass.avpreset


echo "NOTE: You can perform basic cuts to the video using: "
echo " ffmpeg -ss <start time> -i ~/output.mkv -c copy -map 0 output-cut.mkv"
echo "    add the -t <duration> parameter if needed."
echo "    add the -to <end time> parameter if needed."
echo "    Times are expressed in the hh:mm:ss.msec format."
