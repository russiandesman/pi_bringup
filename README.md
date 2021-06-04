# pi_bringup

## Why?

### Current state of art

Instructions to bring up RPi are almost always assume the following workflow:

1. Download [Raspbian]\[Raspberry Pi OS] image
1. Connect display and keyboard to Pi
1. Bring up networking using your hands and amazing vi editor right on board (or GUI if you by some reason decided to set up Pi with X)
1. Update\upgrade everything, install needed software packages, install some software by unzipping\copying
1. Debug issues
1. Disconnect keyboard and displa and start real usage of your box
1. Repeat all the above cyrcus if decide to set up another one Pi.

### So what?

What's wrong with this approach:

1. Not always comfortable to deal with editors right on board.
1. Too much wires here and there
1. Easy to miss something (error prone)
1. Difficult to reproduce the configuration

### What instead?

Do all this from the host PC.

1. Edit **`target_setup.sh`**. Put whatever you want to be done on Pi during bringup
1. Start **`prepare_image.sh`**. It will mount the stock image, arm-chroot into it, launch your target_setup.sh script as root.

The primary purpose is to bring up my raspberry pi zero w with chromecast-like way to connect to home wifi (I forked the excellent work from https://github.com/jasbur/RaspiWiFi and slightly modified it)

My fork is at https://github.com/russiandesman/RaspiWiFi

This work was inspired by set of scripts at https://gist.github.com/cinderblock/20952a653989e55f8a7770a0ca2348a8
