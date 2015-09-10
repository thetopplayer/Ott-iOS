//
//  UploadTopicOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UploadTopicOperation: ParseOperation {

    let topic: Topic
    
    init(topic: Topic) {
        
        self.topic = topic
        super.init()
    }
    
    struct Notifications {
        
        static let DidUpload = "didUploadTopic"
        static let UploadDidFail = "topicUploadDidFail"
        static let TopicKey = "topic"
        static let ErrorKey = "error"
    }
    
    
    //MARK: - Execution
    
    override func execute() {

        logBackgroundTask()
        
        var error: NSError?
        topic.save(&error)
        
        if let error = error {
            finishWithError(error)
        }
        else {
            currentUser().archiveAuthoredTopicName(topic.name!)
        }
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(UploadTopicOperation.Notifications.DidUpload,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = topmostViewController() else {
                    print("ERROR uploading topic \(self.topic)")
                    return
                }
                
                controller.presentOKAlertWithError(errors.first!)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [UploadPostOperation.Notifications.ErrorKey: errors]
                NSNotificationCenter.defaultCenter().postNotificationName(UploadPostOperation.Notifications.UploadDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    
}
