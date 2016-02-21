# BluetoothRover

Quick notes on how to get the code to work (more for me at this early stage of development).

## Rasberry Pi

`git clone https://github.com/momiah/BluetoothRover.git`

### To auto-start the services on boot-up

1. Create a shell script 'run.sh' in the home directory:

  `nano run.sh`

  Paste in:

  ```bash
  #!/bin/sh
  cd /home/pi/Desktop/test
  sh run.sh
  ```

2. Then edit /etc/rc.local

  `sudo nano /etc/rc.local`

  Add before 'exit 0':

  `sh /home/pi/run.sh &`
