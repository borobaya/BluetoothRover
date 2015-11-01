//
//  ControlJoystick.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 31/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

class ControlJoystick : UIView {
    
    var hardwareManager : HardwareManager! // Make sure to assign this straight after initialization
    var location = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let width = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        // Set bounds of view so that touch events are received correctly
        self.bounds = CGRect(x: 0, y: 0, width: width*0.3, height: width*0.3)
        self.backgroundColor = UIColor.blackColor()
        
        let background = UIImageView(image: UIImage(named: "JoystickBackground"))
        background.bounds.size = self.bounds.size
        background.frame.origin = CGPoint(x: 0, y: 0)
        self.addSubview(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        location = touch.locationInView(self)
        location.x -= self.bounds.width/2
        location.y -= self.bounds.height/2
        location.x /= self.bounds.width/2
        location.y /= self.bounds.height/2
        // print("touchesBegan", location)
        
        updateMotors()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        location = touch.locationInView(self)
        location.x -= self.bounds.width/2
        location.y -= self.bounds.height/2
        location.x /= self.bounds.width/2
        location.y /= self.bounds.height/2
        // print("touchesMoved", location)
        
        updateMotors()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        location = CGPoint(x: 0, y: 0)
        hardwareManager.stop()
    }
    
    func getAngleAndPower() -> (Double, Double) {
        // Calculate angle
        var angle : Double
        if location.x != 0 {
            angle = Double(atan(location.y/location.x))
            if location.x>0 {
                angle += M_PI*0.5
            }
            else {
                angle -= M_PI*0.5
            }
        } else if location.y<0 {
            angle = 0
        } else {
            angle = M_PI
        }
        
        // Calculate power to move with
        let power = sqrt(location.x*location.x + location.y*location.y)
        
        return (angle, Double(power))
    }
    
    func updateMotors() {
        let (angle, power) = getAngleAndPower()
        hardwareManager.moveAtAngleWithPower(angle, power: power)
    }
    
}

