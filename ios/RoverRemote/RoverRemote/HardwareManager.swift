//
//  HardwareManager.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 30/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class HardwareManager : NSObject, CBPeripheralDelegate {
    
    // BLE
    var peripheral : CBPeripheral!
    
    // Hardware
    var hardwares : [String : Hardware] = [:]
    var characteristicToHardwareName : [CBCharacteristic : String] = [:]
    
    // View
    var parent : UIView?
    
    // Control UI
    var controlWASD : ControlButtonsWASD?
    var controlJoystick : ControlJoystick?
    var controlSeparate : UIView?
    var controlSeparateList : [String : ControlHardware] = [:]
    
    // Camera Feed
    var cameraFeed : VideoFeed?
    
    func clearAllHardware() {
        for (_, hardware) in hardwares {
            hardware.removeTimer()
        }
        hardwares = [:]
        characteristicToHardwareName = [:]
        
        // Remove UI elements
        for (_, control) in controlSeparateList {
            control.removeFromSuperview()
        }
        controlSeparateList = [:]
        controlSeparate?.removeFromSuperview()
        controlSeparate = nil
        controlWASD?.removeFromSuperview()
        controlWASD = nil
        controlJoystick?.removeFromSuperview()
        controlJoystick = nil
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            // print("Service: ", service)
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            peripheral.discoverDescriptorsForCharacteristic(characteristic)
        }
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        for descriptor in characteristic.descriptors! {
            peripheral.readValueForDescriptor(descriptor)
        }
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // Get the hardware name for the characteristic value that has been updated
        var hardware_name = characteristicToHardwareName[characteristic]
        
        if hardware_name=="" || hardware_name==nil {
            // Hardware does not exist, so create it
            if (characteristic.descriptors != nil) {
                for descriptor in characteristic.descriptors! {
                    if (descriptor.value as? String != nil) {
                        let description = descriptor.value!
                        hardware_name = description.componentsSeparatedByString(" ").last!
                    }
                }
                
                if hardware_name != "" && hardware_name != nil {
                    print("Added hardware entry for", hardware_name!)
                    hardwares[hardware_name!] = Hardware(hardware_name: hardware_name!, characteristic: characteristic, peripheral: peripheral)
                    characteristicToHardwareName[characteristic] = hardware_name!
                    updateUI()
                }
            }
        }
        
        // If hardware details still could not be found, exit
        if hardware_name=="" || hardware_name==nil {
            print("Warning: Received value for unknown hardware")
            return
        }
        
        // Notify update of value
        hardwares[hardware_name!]!.valueWasUpdated()
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        if (descriptor.value as? String != nil) {
            //let description = descriptor.value!
            //let hardware_name = description.componentsSeparatedByString(" ").last!
            //print("Onboard hardware found:", hardware_name)
            
            peripheral.readValueForCharacteristic(descriptor.characteristic)
        }
    }
    
    @objc func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //print("Wrote value to characteristic")
    }
    
    func updateUI() {
        if parent==nil {
            return
        }
        
        // --
        
//        if controlSeparate == nil {
//            controlSeparate = UIView()
//            controlSeparate?.frame.origin = CGPoint(x:parent!.frame.width*0.2, y: 110)
//            parent!.addSubview(controlSeparate!)
//        }
//        
//        var y = CGFloat(0)
//        // Skip past controls already placed
//        for (hardware_name, _) in hardwares {
//            let control = controlSeparateList[hardware_name]
//            if control != nil {
//                y += control!.frame.maxY - control!.frame.minY + 20
//            }
//        }
//        // Add separate controls for each hardware
//        for (hardware_name, hardware) in hardwares {
//            var control = controlSeparateList[hardware_name]
//            
//            if control == nil {
//                control = ControlHardware()
//                control!.setup(hardware, frame: parent!.frame)
//                control!.center = CGPoint(x: control!.center.x, y: y)
//                controlSeparateList[hardware_name] = control!
//                controlSeparate!.addSubview(control!)
//                y += control!.frame.maxY - control!.frame.minY + 20
//            }
//        }
//        
//        resizeToFitSubviews(controlSeparate!)
        
        // --
        
        if hardwares["motor-0"] != nil && hardwares["motor-1"] != nil {
            if controlWASD == nil {
                // Arrows to control motors
                controlWASD = ControlButtonsWASD()
                controlWASD!.hardwareManager = self
                parent!.addSubview(controlWASD!)
            }
            
            if controlJoystick == nil {
                // Joystick
                controlJoystick = ControlJoystick()
                controlJoystick!.hardwareManager = self
                parent!.addSubview(controlJoystick!)
            }
        }
        
        // --
        
        if cameraFeed == nil {
            // Load camera feed
            cameraFeed = VideoFeed(parentView: parent!)
            parent!.insertSubview(cameraFeed!, atIndex: 0)
            cameraFeed!.run()
        }
        
        repositionUI()
    }
    
    func repositionUI() {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
//        if controlSeparate != nil {
//            controlSeparate!.center = CGPoint(x: parent!.center.x, y: controlSeparate!.center.y)
//        }
        
        if controlWASD != nil {
            if orientation.isPortrait {
                controlWASD!.center = CGPoint(x: parent!.center.x, y: parent!.center.y * 1.05)
            } else if orientation.isLandscape {
                controlWASD!.center = CGPoint(x: parent!.center.x*0.66, y: parent!.center.y*1.5)
            }
        }
        
        if controlJoystick != nil {
            if orientation.isPortrait {
                controlJoystick!.center = CGPoint(x: parent!.center.x, y: parent!.center.y*1.6)
            } else if orientation.isLandscape {
                controlJoystick!.center = CGPoint(x: parent!.center.x*1.33, y: parent!.center.y*1.5)
            }
        }
        
        if cameraFeed != nil {
            cameraFeed!.center.x = parent!.center.x
        }
    }
    
    func moveForward() {
        print("Moving forward...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(100)
        }
    }
    
    func moveBackward() {
        print("Reversing...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(-100)
        }
    }
    
    func rotateLeft() {
        print("Rotating left...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(100)
        }
    }
    
    func rotateRight() {
        print("Rotating right...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(-100)
        }
    }
    
    func stop() {
        print("Stopping...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(0)
            rightMotor?.set(0)
        }
    }
    
    func moveNE() {
        print("Moving NE...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(60)
        }
    }
    
    func moveNW() {
        print("Moving NW...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(60)
            rightMotor?.set(100)
        }
    }
    
    func moveSE() {
        print("Moving SE...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(-60)
        }
    }
    
    func moveSW() {
        print("Moving SW...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-60)
            rightMotor?.set(-100)
        }
    }
    
    func moveAtAngleWithPower(angle : Double, power : Double) {
        // print("Angle:", angle*180.0/M_PI, "   Power:", power)
        var power = power
        
        var leftMotorPower = 0.0
        var rightMotorPower = 0.0
        
        if angle >= 0 {
            // Right half
            rightMotorPower = cos(abs(angle))
            if angle <= M_PI*0.5 {
                leftMotorPower = 1
            } else {
                leftMotorPower = -1 + 2*sin(abs(angle))
            }
        }
        if angle < 0 {
            // Left half
            leftMotorPower = cos(abs(angle))
            if angle >= M_PI * -0.5 {
                rightMotorPower = 1
            } else {
                rightMotorPower = -1 + 2*sin(abs(angle))
            }
        }
        
        // Normalize power
        let maxPower = max(abs(leftMotorPower), abs(rightMotorPower))
        leftMotorPower /= maxPower
        rightMotorPower /= maxPower
        
        // print("left:", leftMotorPower, "    right:", rightMotorPower)
        
        power += 0.5
        if power>1 {
            power = 1
        }
        leftMotorPower *= 100 * power
        rightMotorPower *= 100 * power
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(Int32(leftMotorPower))
            rightMotor?.set(Int32(rightMotorPower))
        }
    }
    
}