var bleno = require('bleno');
var util = require('util');
var helper = require('./helper');
var UUID = helper.UUID;
var HardwareCharacteristic = require('./HardwareCharacteristic')
var PrimaryService = bleno.PrimaryService;

var HardwareService = function(msg, socket) {
    HardwareService.super_.call(this, {
        uuid: UUID(0),
        characteristics: []
    });

    var parts = msg.toString().split(" ");

    // Input validation has been done already
    var hardware_name = parts[0];
    var value = parseFloat(parts[1]);

    var permissions = parts[2];
    var is_writable = permissions.indexOf('write')>-1;
    var value_type = parts[3];
    var value_min = parseFloat(parts[4]);
    var value_max = parseFloat(parts[5]);

    // Create the service
    var characteristic = new HardwareCharacteristic(hardware_name, socket);
    if (is_writable) characteristic.properties.push('write');
    this.characteristics.push(characteristic);

    console.log("New hardware registered: ", hardware_name, "\n\tvalue: ", value,
        "\n\tpermissions: ", permissions, "\n\tis_writable: ", is_writable, "\n\tvalue_type: ",
        value_type, "\n\tvalue_min: ", value_min, "\n\tvalue_max: ", value_max);
};

util.inherits(HardwareService, PrimaryService);

module.exports = HardwareService;
