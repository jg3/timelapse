#!/bin/bash 
set -e

# we're going to make a time-lapse video in mp4 format out of the series of
# still photos stored in the IMAGES directory.  QUALITY sets frames per second.
# The max length of the timelapse (in seconds) is given on the command line
# or we'll try for 15 seconds based on the quality set. Length 0 uses all photos.
DEBUG=TRUE
IMAGES=/home/pi/timelapse/images
TMP=/tmp

### NOTE, this process takes about 4x to 6x the length of the resulting
###	  video to run, so if you're creating a 5 minute video don't call
###	  this from cron every 10 minutes.

# QUALITY is the number of pictures to show per second.  Higher = smoother.
# 6 is a little choppy, 24 is very smooth, 30 is about the highest to go.
QUALITY=12

############################## Maybe don't edit below this line ######



debecho () {
  if [ ! -z "$DEBUG" ]; then
     echo "$1" >&2
     #         ^^^ to stderr
  fi
}

debecho " ===> DEBUG: $DEBUG"
debecho " ===> \$1: $1"
debecho " ===> QUALITY: $QUALITY"

if [[ $1 -eq 0 ]]; then
	# set to zero, use all frames.
	TIME=0
	debecho " ---> Option 0: Generating video of up to with all available frames at $QUALITY frames/sec";
elif [[ $1 -gt 0 ]]; then
	# set to something, use that 
	TIME=$1
	debecho " ---> Option set to $TIME "
	debecho " ---> Generating video of up to $TIME seconds with $FRAMES frames at $QUALITY frames/sec";
else
	# nothing was set, default to 15s
	TIME=15
	debecho " ---> No option set, defauilting to 15s. "
	debecho " ---> Generating video of up to $TIME seconds with $FRAMES frames at $QUALITY frames/sec";
fi
debecho " ===> TIME: $TIME"

FRAMES=$((TIME*QUALITY))
debecho " ===> FRAMES: $FRAMES"

# using full paths in here because that's what cron liked
# call this from cron every ten minutes or:
# */10 * * * * /path/to/this_file.sh >> /var/log/this_file.log

# this is to give the last camera process a chance to complete..
# If running interactively, don't do anything
case $- in
    *i*) sleep 8;;
      *) ;;
esac

# make a list of the files we need
# it is okay to me that latest-image.jpg is a dupe
if [ "$TIME" -gt 0 ]; then
    ls -1 $IMAGES/*.jpg | tail -$FRAMES > $TMP/stills.txt ;
else
    ls -1 $IMAGES/*.jpg > $TMP/stills.txt ;
fi

wc -l $TMP/stills.txt

debecho " =============================================================== "
# make an .avi of based on the still photos
# there are a lot of mencoder options, some poorly documented
mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=1.33:vbitrate=8000000 \
    -vf scale=2592:1944 -o $TMP/timelapse.avi \
    -mf type=jpeg:fps=${QUALITY} mf://@${TMP}/stills.txt 

debecho " =============================================================== "
# make that .avi into an .mp4
ffmpeg -y -i $TMP/timelapse.avi $TMP/timelapse.mp4
mv $TMP/timelapse.mp4 $IMAGES/timelapse.mp4

# clean up intermediate files
rm $TMP/stills.txt $TMP/timelapse.avi
