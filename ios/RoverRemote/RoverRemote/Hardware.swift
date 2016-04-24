//
//  Hardware.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 29/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation
import CoreBluetooth


class Hardware : NSObject {
    
    let peripheral : CBPeripheral
    let hardware_name : String
    let characteristic : CBCharacteristic
    let processInfo = NSProcessInfo()
    var target_value : Int32
    var timer : NSTimer?
    
    let hardware_type : String
    let value_type : String
    var last_sent_value : Int32 = 0
    
    var notify : [(Int32) -> Void] = []
    
    init(hardware_name : String, characteristic : CBCharacteristic, peripheral : CBPeripheral) {
        self.hardware_name = hardware_name
        self.characteristic = characteristic
        self.peripheral = peripheral
        self.target_value = 0
        self.timer = nil
        
        self.hardware_type = self.hardware_name.componentsSeparatedByString("-").first!
        
        switch self.hardware_type {
        case "motor":
            self.value_type = "continuous"
        case "led":
            self.value_type = "binary"
        case "battery":
            self.value_type = "continuous"
        case "infrared":
            self.value_type = "continuous"
        default:
            self.value_type = "continuous"
        }
    }
    
    func set(value : Int32) {
        target_value = value
        if hardware_type == "motor" && abs(target_value)<30 {
            target_value = 0
        }
        
        if timer==nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.2,
                target: self,
                selector: #selector(Hardware.updateValue),
                userInfo: nil,
                repeats: true)
        }
    }
    
    func get() -> Int32 {
        // Extract value data correctly
        let data = characteristic.value
        var values : [Int32] = []
        if (data != nil) {
            let dataLength = data!.length
            values = [Int32](count:Int(dataLength/sizeof(Int32)), repeatedValue:0)
            data!.getBytes(&values, length:dataLength)
        }
        
        // Work with updated value for the hardware
        if values.count>0 {
            let value = values[0]
            return value
        }
        return 0
    }
    
    func updateValue() {
        // Check for change in value
        let value = get()
        let change = abs(target_value-value)
        if change==0 || target_value==last_sent_value {
            removeTimer()
            return
        }
        if value_type != "binary" {
            // Stops sending too many messages, i.e. when user has finger continually pressed on control
            if change < 5 {return}
            
            if abs(target_value)<10 {
                target_value = 0
            }
        }
        
        print("Changing", hardware_name, "value to:", target_value)
        
        // Send write signal
        let data = NSData(bytes: &target_value, length: 4)
        peripheral.writeValue(data, forCharacteristic: characteristic,
            type: CBCharacteristicWriteType.WithResponse)
        last_sent_value = target_value
    }
    
    func valueWasUpdated() {
        last_sent_value = get()
        
        print("Hardware:", hardware_name, "   Updated value:", last_sent_value)
        
        notifyFuncs()
    }
    
    func removeTimer() {
//        timer?.invalidate()
//        timer = nil
    }
    
    func addNotifyFunc(f : (Int32) -> Void) {
        notify.append(f)
    }
    
    func notifyFuncs() {
        let value = get()
        for f in notify {
            f(value)
        }
    }
    
}
