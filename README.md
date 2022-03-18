# Timelapse

A Raspberry Pi project to take time-lapse pictures.

This project assumes you are running the Bullseye (Spring 2022) release of Raspberry Pi or maybe later.
Note that the transition from Buster to Bullseye included a change in the camera tools from raspistill to libcamera.
This project uses libcamera.

An exhaustive description of all this and the decisions that went into it appeared on [this blog post]()

### The files in this project:

`config.txt` - libcamera-still assumes your config.txt is in `~` by default, but since this is all distributed together
the paths here point to this copy of settings so as to not conflict with an exsiting default.  Edit to taste.

`crontab` - not really a file in this project, but critically important.  Example lines included below for your copy-paste convenience.

`timelapse-camera-log` - This needs to be linked or moved to /etc/logrotate.d/timelapse-camera-log.  
This configuration file enlists logrotate so the camera-latest.log file here doesn't get crazy big.  
If you turn on ultra debug, you should probably change the rotation size from 10M to 100M.


### What's NOT in this project
(this is more of a warning than a to-do list)
- any kind of rotation of the .jpg images.  Eventually this will fill up the SD card on your Rasperry Pi. 


This is in crontab for user pi edit yours with `crontab -e`:

```
# Take a picture every minute and save it in ~pi/timelapse and log the output for troubleshooting
* * * * * libcamera-still --config /home/pi/timelapse/config.txt >> /var/log/timelapse-camera.log 2>&1
# same but two minutes
#*/2 * * * * libcamera-still --config /home/pi/timelapse/config.txt >> /var/log/timelapse-camera.log.log 2>&1
# three minutes -- but with SUPER detailed logging
#*/3 * * * * LIBCAMERA_LOG_LEVELS=RPI:0,V4L2:0 libcamera-still --config /home/pi/timelapse/config.txt >> /var/log/timelapse-camera.log.log 2>&1
#This is ULTRA SUPER LOGGING DETAIL
#* * * * * LIBCAMERA_LOG_LEVELS=RPI:0,V4L2:0 libcamera-still --config /home/pi/timelapse/config.txt >> /var/log/timelapse-camera.log.log 2>&1

# sync photos to the S3 bucket mounted on /var/s3/
# see blog post for more details
*/30 * * * * sleep 20 && rsync -avW --inplace --size-only --exclude=latest-image.jpg --include=*.mp4,*.jpg /home/pi/timelapse/images/* /var/s3/timelapse/

# generate a 15-second timelapse of the stills every 10 minutes. Look in this script for notes on FPS quality settings, etc.
*/10 * * * * /home/pi/timelapse/make-video.sh 15
# generate a 60-second timelapse of the stills every 10 minutes.
#*/10 * * * * /home/pi/timelapse/make-video.sh 60
```

When I was testing this setup, my son was doing one of those "grow your own crystals" kits, so we made this timelapse of it.  The crystals didn't work very well for some reason ... but the timelapse was fun!

https://user-images.githubusercontent.com/2963153/158958066-3b81d0d0-c903-49d4-9487-56a12aa3fdc0.mp4


