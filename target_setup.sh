#!/bin/bash

echo "+target_setup.sh------------------------"

uname -a # just because we can

# you are root here, no need to sudo
# also it is safe to echo "something" > protected.file
# as there is no pitfall with this as with sudo.

# make sure you call this script with /usr/bin/env -i /target_setup.sh
# otherwise LC_* environment variables will be taken from host
# which might be not what you want
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

apt update
apt upgrade -y

/tmp/files_to_install/RaspiWiFi/initial_setup_silent.py 

df -h # to know how many space left

echo "-target_setup.sh------------------------"
