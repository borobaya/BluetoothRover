#!/usr/bin/env python
# -*- coding: utf-8 -*-

import zmq
import threading
import time
import os
from controller import Controller

class Server(threading.Thread):
    """Server"""
    def __init__(self, stopped):
        threading.Thread.__init__ (self)
        self.context = zmq.Context()
        self.stopped = stopped
        self.controller = Controller()

    def run(self):
        socket = self.context.socket(zmq.PAIR)
        socket.RCVTIMEO = 1000 # Set timeout on recv(), so it does not block for too long
        socket.SNDTIMEO = 1000 # Set timeout on send(), so it does not block for too long
        socket.setsockopt(zmq.LINGER, 1000) # Ensure context.term() does not hang
        socket.bind('tcp://*:5570')

        poll = zmq.Poller()
        poll.register(socket, zmq.POLLIN)

        print "Initialisation completed"

        while not self.stopped.is_set():
            sockets = dict(poll.poll(1000))
            if socket in sockets:
                if sockets[socket] == zmq.POLLIN:
                    self.handle_message(socket)

        socket.close()
        self.cleanup()
        print "Exited: Server"

    def handle_message(self, socket):
        msg = socket.recv()
        resps = self.controller.process(msg)
        for resp in resps:
            socket.send(resp)

    def cleanup(self):
        self.controller.cleanup()
        self.context.term()

def main():
    """main function"""
    if os.geteuid() != 0:
        print "Warning: Need administrator privileges to access onboard pins! Use 'sudo'."

    # Help sync multi-threading
    stopped = threading.Event()
    stopped.clear()

    # Set up processes
    server = Server(stopped)
    server.setDaemon(True)
    server.start()
    
    try:
        while threading.active_count() > 0:
            time.sleep(0.1)
    except KeyboardInterrupt:
        print "\nKeyboardInterrupt detected. Waiting for threads to finish..."
        stopped.set()
        server.join()
        print "Threads successfully ended."

if __name__ == "__main__":
    main()
