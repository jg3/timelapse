#!/bin/bash -e

# Description: setup script for Raspberry Pi Timelapse system

# Disclaimer:  This script is provided for you to use at your own risk.
# No warranty or promise of any kind is attached.

# Set to TRUE to override built-in testing
docker_installed="auto" 



################################### Probably don't edit below here ######

TEXT () {
    # A colorful wrapper around echo
    # $1 is message part, $2 is handling
    TEXT_RESET='\e[0m'
    TEXT_RED='\e[1;31m'
    TEXT_GREEN='\e[0;32m'
    TEXT_YELLOW='\e[0;33m'
    TEXT_BLUE='\e[0;34m'
    TEXT_PURPLE='\e[0;35m'
    TEXT_CYAN='\e[0;36m'
    TEXT_WHITE='\e[1;37m'
    case $2 in
	IN_RED)
	    echo -e ${TEXT_RED}${1}${TEXT_RESET} ;;
	IN_GREEN)
	    echo -e ${TEXT_GREEN}${1}${TEXT_RESET} ;;
	IN_YELLOW)
	    echo -e ${TEXT_YELLOW}${1}${TEXT_RESET} ;;
	IN_BLUE)
	    echo -e ${TEXT_BLUE}${1}${TEXT_RESET} ;;
	IN_PURPLE)
	    echo -e ${TEXT_PURPLE}${1}${TEXT_RESET} ;;
	IN_CYAN)
	    echo -e ${TEXT_CYAN}${1}${TEXT_RESET} ;;
	IN_WHITE)
	    echo -e ${TEXT_WHITE}${1}${TEXT_RESET} ;;
	**)
	    echo -e ${TEXT_RESET}${1} ;;
    esac
}


# this test for a null value of $BASH identifies sh
# which is the most common case of not-bash
if [ -z "$BASH" ] ; then
  echo "Calling this script under sh will not work as well."
  echo "Either call as \"bash $0\" or do \"chmod u+x $0\" "
  echo "and then run it normally." 
  exit
fi

# this part is really just here for the sudo and we assume
# that sudo on your system stays cached (default 5min)
sudo echo " Beginning setup of RPI Timelapse..."

# test for, like, a camera .. i guess?
#   got one?
#	cool
#   can't find one?
#	I'm going to stop while you figure that out.

# create the file we will log to and set ownership
TEXT "Creating /var/log/timelapse-camera.log" IN_BLUE
sudo touch /var/log/timelapse-camera.log
TEXT "Setting permissions on that file." IN_BLUE
sudo chown pi:pi /var/log/timelapse-camera.log

TEXT "Checking for the presence of Docker on this system" IN_BLUE
# is docker installed?

case $docker_installed in
    TRUE) 
	;;
      **)
	## TODO  test for the presence of docker here, somehow.
	dockerhost="foo"

	case $dockerhost in
	    not-detected)
		TEXT "This Raspberry Pi does not have Docker installed." IN_YELLOW
		TEXT " please install it before proceeding (you do not" IN_YELLOW
		TEXT " have to run this script again, but Docker is a " IN_YELLOW
		TEXT " requirement for the webserver portion." IN_YELLOW
		TEXT "See: " IN_YELLOW
		TEXT " https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script" IN_BLUE
		;;
	    detected)
		TEXT "Docker was found on this system, moving right along..." IN_BLUE
		;;
	    **)
		TEXT "The test for Docker on this sytem was unsuccessful because:" IN_WHITE
		TEXT "  $dockerhost" IN_WHITE
		;;
	esac
	;;
esac

# Might as well tap that docker container build/start script now:
TEXT "Initializing webserver in Docker container" IN_BLUE
#$pwd/latest-image/dockersetup.sh

# set webserver container to start at reboot
TEXT "Setting webserver to start at boot time" IN_BLUE
sudo copy -v ./latest-image/latest-image.systemd  /etc/systemd/system/latest-image.service
sudo chmod -v /etc/systemd/system/latest-image.service +x
sudo systemctl enable latest-image --now
case $exitcode in
    0)
	TEXT "Cool, that seemed to work and you're running the webserver now" IN_BLUE
	TEXT "you should be able to access it on:" IN_BLUE
	TEXT "   http://<your_rpi_IP>:8080/" IN_CYAN

# test for fuse s3 ... prompt for configuration stuff I guess

# test for all the dumb stuff needed for making the timelapse
