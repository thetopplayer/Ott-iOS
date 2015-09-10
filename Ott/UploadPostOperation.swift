//
//  UploadPostOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UploadPostOperation: ParseOperation {

    let post: Post
    
    init(post: Post) {
        
        self.post = post
        super.init()
    }
    
    struct Notifications {
        
        static let DidUpload = "didUploadPost"
        static let UploadDidFail = "postUploadDidFail"
        static let PostKey = "post"
        static let ErrorKey = "error"
    }
    
    
    //MARK: - Execution
    
    override func execute() {

        logBackgroundTask()
        
        var error: NSError?
        post.save(&error)
        
        if let error = error {
            finishWithError(error)
        }
        else {
            
            guard let topicID = post.topic!.objectId else {
                assert(false)
                return
            }
            
            currentUser().archivePostedTopicID(topicID)
        }
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [UploadPostOperation.Notifications.PostKey: self.post]
                NSNotificationCenter.defaultCenter().postNotificationName(UploadPostOperation.Notifications.DidUpload,
                    object: self,
                    userInfo: userinfo)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = topmostViewController() else {
                    print("ERROR uploading post \(self.post)")
                    return
                }
                
                controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not upload post:")
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
