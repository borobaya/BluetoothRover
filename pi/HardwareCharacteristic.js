var bleno = require('bleno');
var util = require('util');
var Characteristic = bleno.Characteristic;
var Descriptor = bleno.Descriptor;

// Create Characteristic class, which contains hardware data
var HardwareCharacteristic = function(hardware_name, socket) {
    HardwareCharacteristic.super_.call(this, {
        uuid: '2AAE', //'2A8A', //'2A6E', // 32-bit signed integer
        properties: [ 'read', 'notify', 'indicate' ],
        value: null,
        descriptors: []
    });

    this.socket = socket;
    this.hardware_name = hardware_name;
    this._updateValueCallback = null;
    this.valueUpdated = function () {
        if (this._updateValueCallback) {
            var _value = new Buffer(4); // 32-bits == 4 bytes
            _value.writeInt32LE(this.value, 0);
            this._updateValueCallback(_value);
        }
    }

    this.descriptors.push(new Descriptor({
        uuid: '2901',
        value: 'This is ' + this.hardware_name
    }));
};

util.inherits(HardwareCharacteristic, Characteristic);

HardwareCharacteristic.prototype.onReadRequest = function(offset, callback) {
    if ((this.value==null)||isNaN(this.value)) this.value = 0.0;
    console.log("ReadRequest | value =", this.value);
    try {
        var _value = new Buffer(4); // 32-bits == 4 bytes
        _value.writeInt32LE(this.value, 0);
        callback(Characteristic.RESULT_SUCCESS, _value);
    } catch (err) {
        callback(Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH, new Buffer(0));
    }
};
HardwareCharacteristic.prototype.onWriteRequest = function(data, offset, withoutResponse, callback) {
    console.log("WriteRequest | new value =", data);
    try {
        // this.value = data.readInt32LE(0);
        // if (this._updateValueCallback) {
        //     this._updateValueCallback(data);
        // }

        var value = data.readInt32LE(0);
        this.socket.send("set "+this.hardware_name+" "+value.toString());

        callback(Characteristic.RESULT_SUCCESS);
    } catch (err) {
        callback(Characteristic.RESULT_INVALID_ATTRIBUTE_LENGTH);
    }
};
HardwareCharacteristic.prototype.onSubscribe = function(maxValueSize, updateValueCallback) {
    console.log("onSubscribe |", maxValueSize, "|", updateValueCallback)
    this._updateValueCallback = updateValueCallback;
};
HardwareCharacteristic.prototype.onUnsubscribe = function() {
    console.log("onUnsubscribe |")
    this._updateValueCallback = null;
};
HardwareCharacteristic.prototype.onNotify = function() {
    console.log("onNotify |")
    // if (this._updateValueCallback) {
    //     console.log("point 1")
    //     var _value = new Buffer(4); // 32-bits == 4 bytes
    //     try {
    //         console.log("point 2", this==this._updateValueCallback)
    //         _value.writeInt32LE(this.value, 0);
    //         this._updateValueCallback(_value);
    //     } catch (err) {
    //         console.log("point 3 err")
    //     }
    // }
};

module.exports = HardwareCharacteristic;
