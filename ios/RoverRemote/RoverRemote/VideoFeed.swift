//
//  VideoFeed.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 24/04/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

class VideoFeed : UIView, FFAVPlayerControllerDelegate {
    
    var viewController : UIViewController!
    var playerController : FFAVPlayerController!
    
    convenience init(viewController : UIViewController) {
        self.init()
        
        self.frame.size = viewController.view.frame.size
        self.viewController = viewController
        
        self.backgroundColor = UIColor.blueColor()
        
        frame = CGRect(x: 29, y: 80, width: 300, height: 200)
        center.x = viewController.view.center.x
    }
    
    func run() {
        
        let urlStr = "rtsp://mpv.cdn3.bigCDN.com:554/bigCDN/definst/mp4:bigbuckbunnyiphone_400.mp4"
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
            print(error.description)
            print(error)
            let alert = UIAlertController(title: "Failed to load video!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
