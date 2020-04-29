Some video conferencing systems allow you to share a window instead of the whole
desktop. This is useful since it makes the things being shown not tiny. However,
menus and such often don't show up when recording a single application because
menus are their own windows. We can work around this by first capturing a
subsection of the desktop as a video stream that is played in a media player and
then share the media player window.


We use VLC for the desktop capturing part.

First install the `vlc-plugin-access-extra` debian package so that screen
capturing works. Otherwise I get `VLC is unable to open the MRL
‘screen://'”/”open of `screen://’ failed”` from VLC.

Then do Media → Open Capture Device...
Select Capture mode `Desktop`.
Chose a desired framerate.
Add whatever is needed to make the Edit Options contain someting along the lines of

`:screen-fps=10.000000 :live-caching=300 :screen-width=1920 :screen-height=1080`

VLC cannot capture the mouse pointer on Linux. :(




Another alternative is to pipe the `ffmpeg -f x11grab` command into VLC.

`ffmpeg -f x11grab -r 30 -s 1920x1080 -i :0.0+0,0 -acodec pcm_s16le -vcodec libx264 -preset medium -threads 0 -pix_fmt yuv420p  -f matroska - | vlc -`

This has a 5 s latency. :(


We can also pipe into ffplay:

`ffmpeg -f x11grab -r 30 -s 1920x1080 -i :0.0+0,0 -an  -vcodec libx264 -preset ultrafast -tune zerolatency -f matroska - | ffplay -`

This has a little lower latency, but I guess that has more to do with the the preset/tune parameters than vlc/ffplay.

This is usable.
