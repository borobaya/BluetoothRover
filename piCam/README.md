
TO MAKE CAMERA STREAMING WORK:
==============================

At the Raspberry Pi:

# Load the module
sudo modprobe bcm2835-v4l2

# Control the viewfinder
v4l2-ctl --overlay=1 # enable viewfinder

# Set options for a better video
v4l2-ctl --set-ctrl brightness=70
v4l2-ctl --set-ctrl contrast=40
v4l2-ctl --set-ctrl saturation=20
#v4l2-ctl --set-ctrl video_bitrate=25000


# Not necessary with '--x11-display :0'
#Load D-bus Session Daemon:
export DISPLAY=:0
startx&

# To run:
cvlc v4l2:///dev/video0 --v4l2-width 320 --v4l2-height 240 --v4l2-fps 15 --v4l2-chroma h264 --sout '#rtp{sdp=rtsp://:5006/}'

# --network-caching 1 --sout-mux-caching 1 --file-caching 1


In VLC Player:

rtsp://IP_ADDRESS:5006/




