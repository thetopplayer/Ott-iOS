//
//  UploadTopicOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UploadTopicOperation: ParseServerOperation {

    let topic: Topic
    
    init(topic: Topic) {
        
        self.topic = topic
        super.init(timeout: 60)
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
        
        do {
            
            try topic.save()
            try topic.pinWithName(FetchCurrentUserAuthoredTopicsOperation.pinName()!)  // store in local cache
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                print("topic saved = \(self.topic)")
                
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
                
                controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not upload topic:")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [UploadTopicOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(UploadTopicOperation.Notifications.UploadDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    
}
