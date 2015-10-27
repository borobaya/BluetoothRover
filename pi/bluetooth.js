
var HardwareService = require('./HardwareService')

var servicesHardware = {}
var services = [];
var serviceUuids = [];

// ---------------------------------------------------------------------------------------------
// Setup link to python
// https://github.com/JustinTulloss/zeromq.node

// Create a socket
var zmq = require('zmq');
socket = zmq.socket('pair');

// Register to monitoring events
socket.on('connect', function(fd, ep) {console.log('connect, endpoint:', ep);});
socket.on('connect_delay', function(fd, ep) {console.log('connect_delay, endpoint:', ep);});
socket.on('connect_retry', function(fd, ep) {console.log('connect_retry, endpoint:', ep);});
socket.on('listen', function(fd, ep) {console.log('listen, endpoint:', ep);});
socket.on('bind_error', function(fd, ep) {console.log('bind_error, endpoint:', ep);});
socket.on('accept', function(fd, ep) {console.log('accept, endpoint:', ep);});
socket.on('accept_error', function(fd, ep) {console.log('accept_error, endpoint:', ep);});
socket.on('close', function(fd, ep) {console.log('close, endpoint:', ep);});
socket.on('close_error', function(fd, ep) {console.log('close_error, endpoint:', ep);});
socket.on('disconnect', function(fd, ep) {console.log('disconnect, endpoint:', ep);});

// Handle monitor error
socket.on('monitor_error', function(err) {
    console.log('Error in monitoring: %s, will restart monitoring in 5 seconds', err);
    setTimeout(function() { socket.monitor(500, 0); }, 5000);
});

// Call monitor, check for events every 500ms and get all available events.
// console.log('Start monitoring...');
// socket.monitor(500, 0);

// Handle what happens when a message is received
socket.on('message', function(msg){
    var parts = msg.toString().split(" ");

    if (parts.length<2) return;
    var hardware_name = parts[0];

    // Find and update hardware BLE characteristic value...
    var service = servicesHardware[hardware_name];
    if (service) {
        // Hardware value updated
        var value = parseFloat(parts[1]);
        console.log(hardware_name, "| value =", value);

        var characteristic = service.characteristics[0];
        characteristic.value = value;
        characteristic.onNotify();
    } else if (parts.length>=6) {
        // New hardware detected
        service = new HardwareService(msg, this);

        // Add to global list variables
        services.push( service );
        serviceUuids.push( service.uuid );
        servicesHardware[hardware_name] = service;
    } else {
        // Not enough information to create entry for unknown hardware
        // Request full details
        console.log("Not enough information to create entry for unknown hardware ("+
            hardware_name+"). Requesting full details.");
        socket.send("describe "+hardware_name);
    }
});

// Connect
socket.connect("tcp://localhost:5570")
socket.send("describe *")

// ---------------------------------------------------------------------------------------------
// Setup Bluetooth

// Import and get classes
var bleno = require('bleno');
var bluetooth_device_name = 'BLE Rover';

// Handle Events
bleno.on('stateChange', function(state) {console.log("BLE state change: ", state);});
bleno.on('advertisingStart', function(error) {
    if (error) {
        console.log("Error on advertisingStart: ", error);
    } else {
        console.log("BLE advertising started successfully.");
    }
});
bleno.on('advertisingStop', function(error) {
    if (error) {
        console.log("Error on advertisingStop: ", error);
    } else {
        console.log("BLE advertising stopped successfully.");
    }
});
bleno.on('servicesSet', function(error) {
    if (error) {
        console.log("Error on servicesSet: ", error);
    } else {
        console.log("BLE services set successfully.");
    }
});
bleno.on('accept', function(clientAddress) {console.log("Accepted client at address: ", clientAddress);});
bleno.on('disconnect', function(clientAddress) {console.log("Disconnected client at address: ", clientAddress);});
bleno.on('rssiUpdate', function(rssi) {console.log("RSSI updated: ", rssi);});

function startServices() {
    if (bleno.state=="poweredOn") {
        // Start advertising services
        console.log("Starting BLE services...");
        bleno.setServices(services);
        bleno.startAdvertising(bluetooth_device_name, serviceUuids);
    } else {
        // If BLE has not been powered on, wait and try again
        setTimeout(startServices, 1000);
    }
}

// Inform user in case Bluetooth is not powered on at the start
if (bleno.state!="poweredOn") {
    console.log("Bluetooth must be powered on to start. State is: ", bleno.state);
    console.log("Waiting for Bluetooth LE to be powered on...");
}
// Wait for python data to be registered before advertising
setTimeout(startServices, 1000);

