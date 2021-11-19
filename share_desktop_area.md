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



There is also a Python script on StackOverflow by Mark Setchell that pipes ffmpeg to a OpenCV window.
See https://stackoverflow.com/questions/60264704/i-want-to-display-mouse-pointer-in-my-recording

It's written for OSX but I got the FFMPEG command to run on my machine. Something like.

`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf -f rawvideo pipe:1`

Maybe this can be piped to VLC.


`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f rawvideo pipe:1 | vlc -`

Does not work. ffmpeg seems to be doing its thing, but VLC never displays a picture. Maybe it doesn't support `rawvideo`?
Replacing with matroska:


`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f matroska pipe:1 | vlc -`

```
mkv demux error: cannot find any cluster or chapter, damaged file ?
```

Perhaps the `pipe:1` doesn't work. Previous commands have used `-` instead. Trying.

`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f matroska - | vlc -`

Still getting `mkv demux error: cannot find any cluster or chapter, damaged file ?`

Why is it different when running on the command line compared to from the Python script?

Is it VLC's fault? Should I use ffplay instead?

`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f matroska - | ffplay -`

Got an image, but performance is very bad. Several seconds of latency.

Testing with rawvideo instead of matroska.


`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f rawvideo - | ffplay -`

That didn't work at all: `pipe:: Invalid data found when processing input`.


It seems just running the Python script is by far the best approach. Its full ffmpeg command line is


`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f rawvideo pipe:1`

I consider this to be equivalent to my experiments.


`ffmpeg -f x11grab -r 20 -s 1920x1080 -i :0.0+0,0 -vf scale=w=1920:h=1080 -f matroska - | ffplay -`

This has been implemented in `share_desktop_area.py`.
