//
//  ViewController.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 20/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    let titleLabel : UILabel! = UILabel()
    var statusLabel : UILabel!
    
    // BLE
    var centralManager : CBCentralManager!
    
    // Hardware
    var hardwareManager = HardwareManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hardwareManager.parent = self.view
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up title label
        titleLabel.text = "Raspberry Pi Rover"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: titleLabel.frame.maxY, width: self.view.frame.width, height: statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Detect orientation changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.orientationChanged),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func orientationChanged() {
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY+28)
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: titleLabel.frame.maxY, width: self.view.frame.width, height: statusLabel.bounds.height)
        
        hardwareManager.repositionUI()
    }
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
            self.statusLabel.text = "Bluetooth turned off"
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let deviceName = "BLE Rover"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            self.statusLabel.text = deviceName+" connected"
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.hardwareManager.peripheral = peripheral
            self.hardwareManager.peripheral.delegate = self.hardwareManager
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            print("Peripheral Name:", peripheral.name, "      Device Name:", nameOfDeviceFound)
            self.statusLabel.text = "Rover NOT found"
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // Restart scan
        self.statusLabel.text = "Rover disconnected"
        hardwareManager.clearAllHardware()
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // Restart scan
        self.statusLabel.text = "Rover disconnected"
        hardwareManager.clearAllHardware()
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
}
