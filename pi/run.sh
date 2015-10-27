#!/bin/sh
tmux new-session -d 'sudo python start.py'
tmux split-window -h 'sudo node bluetooth.js'
