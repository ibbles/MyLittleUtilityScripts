#!/bin/bash

# This script uses ffmpeg -x11grab to record a section of the screen to disk.
#
# Required Ubuntu packages:
# - ffmpeg
# - X11
# - xdotool
#
# x11grab doesn't work when using Wayland instead of X11.
# There is kmsgrab that almost works with
#    ffmpeg -f kmsgrab -i - -vf 'hwmap=derive_device=vaapi,crop=960:540:480:270,scale_vaapi=960:540:nv12' -c:v h264_vaapi output.mp4
# though may other suggestions I've seen around produces errors and no video.
# Hoever, even when I get a video file I don't get a mouse cursor.
# So I'm just using OBS Studio instead.
# More tedious, but works.

posX=""
posY=""
sizeX=""
sizeY=""

delay=5

output="output.mp4"
if [ -f "$output" ] ; then
  echo "File '$output' already exists. Remove? [y/n]"
  read doDelete
  if [ "$doDelete" == "y" ] ; then
    rm "$output"
  else
    exit 1
  fi
fi


do_exit=false

# Make sure we have the utilities we need.

if ! command -v xdotool >/dev/null ; then
    echo "xdotool not installed. Install with" >&2
    echo "  sudo apt install xdotool" >&2
    do_exit=true
fi

if ! command -v ffmpeg >/dev/null ; then
    echo "ffmpeg not installed. Install with" >&2
    echo "  sudo apt install ffmpeg" >&2
    do_exit=true
fi

if "$do_exit" == true ; then
    exit 1
fi


# Print message and wait a bit for user to read it.
function pauseWithMessage
{
  echo "$1"
  for i in `seq 1 $delay`; do
      echo -n "Pausing for $delay seconds: $(($delay-$i)) second(s)"
      echo -n $'\r'
      sleep 1
  done
  echo ""
}


# Parse a 2D point from a string, configurable separator.
function parsePoint
{
    sep=$2
    if [ -z "$sep" ] ; then
        sep=x
    fi

    first=`echo "$1" | cut -d "$sep" -f1`
    second=`echo "$1" | cut -d "$sep" -f2`

    if [ "$first" == "" ] || [ "$second" == "" ] ; then
        echo "Could not parse point from '$1' with separator '$sep'."
        exit 1
    fi
}


function getCurrentWindowPositionAndSize
{
    pauseWithMessage "Focus the window to record."
    window=`xdotool getactivewindow`
    pos=`xdotool getwindowgeometry ${window} | grep "Position:" | tr -s ' ' | cut -d ' ' -f3`
    parsePoint $pos ","
    posX=$first
    posY=$second
    size=`xdotool getwindowgeometry ${window} | grep "Geometry:" | tr -s ' ' | cut -d ' ' -f3`
    parsePoint $size "x"
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


if [ -f "$output" ] ; then
  echo "File '$output' already exists. Remove? [y/n]"
  read doDelete
  if [ "$doDelete" == "y" ] ; then
    rm "$output"
  else
    exit 1
  fi
fi

echo "Reading options."
while getopts "d:p:zus:wih" opt; do
case $opt in
    d)
      delay=$OPTARG
      echo "Delay is $delay."
      ;;
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
        echo "  -d  Set the delay for commands following it on the command line."
        echo "  -p  The screen position of the top-left corner of the record area."
        echo "      Cannot be combined with -z."
        echo "  -z  The screen position of the lower-left corner of the record area relative"
        echo "      to the lower-right corner of the screen. Cannot be combined with -p."
        echo "      Must be given after -s or -w."
        echo "  -u  Set screen position to account for Unity top panel and application dock."
        echo "  -s  The size of the record area."
        echo "  -w  Set size and position from the current window, after a short delay."
        echo "  -i  Print current window size."
        exit 0
        ;;
    ?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done
echo "Options parsed."

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

# The above uses the CPU to encode the video, since it uses '-vcodec libx264' and a bunch parameters to that.
# It makes my fans spin like crazy and I worry that it will have a negative performance impact.
# The following uses Nvidias hardware encoder instead. The '-vcodex libx264' bit has been replaced
# with a bunch of `-hwaccel` bits.
# I got the arguments from https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/.
# It talks about building ffmpeg, but on Ubuntu 20.04 I could just use the system ffmpeg.
# There are more flags on the page linked above.
#ffmpeg -f x11grab -show_region 1 -r 30 -s ${sizeX}x${sizeY} -hwaccel cuda -hwaccel_output_format cuda -i :0.0+${posX},${posY} -acodec pcm_s16le -c:v h264_nvenc -b:v 5M "${output}"



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
