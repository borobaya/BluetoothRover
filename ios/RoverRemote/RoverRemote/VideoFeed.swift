//
//  VideoFeed.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 24/04/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

class VideoFeed : UIView, FFAVPlayerControllerDelegate {
    
//    var viewController : UIViewController!
    var playerController : FFAVPlayerController!
    var parent : UIView!
    
    convenience init(parentView : UIView) {
        self.init()
        
        self.parent = parentView
        self.frame.size = parent.frame.size
        
        self.backgroundColor = UIColor.blueColor()
        
        let width = parent.frame.width * 0.6
        
        frame = CGRect(x: 29, y: 80, width: width, height: width * 240/320)
        center.x = parent.center.x
    }
    
    func run() {
        var urlStr = "rtsp://mpv.cdn3.bigCDN.com:554/bigCDN/definst/mp4:bigbuckbunnyiphone_400.mp4"
        urlStr = "rtsp://192.168.1.82:5006/"
        let mediaURL = NSURL(string: urlStr)
        
        playerController = FFAVPlayerController()
        playerController.delegate = self
        playerController.allowBackgroundPlayback = true
        playerController.shouldAutoPlay = true
        
        let options : [NSObject:AnyObject] = [
            AVOptionNameAVProbeSize: 256*1024, // 256kb, default is 5Mb
            AVOptionNameAVAnalyzeduration: 1, // default is 5 seconds
            AVOptionNameHttpUserAgent: "Mozilla/5.0" ]
        
        playerController.openMedia(mediaURL, withOptions: options)
    }
    
    func FFAVPlayerControllerDidLoad(controller: FFAVPlayerController!, error: NSError!) {
        if (error == nil) {
            let video = playerController.drawableView()
            video.frame.size = frame.size
            video.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
            self.insertSubview(video, atIndex:0)
            
        } else {
            print("Failed to load video!")
            print(error)
            let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
            let alert = UIAlertController(title: "Failed to load video!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
