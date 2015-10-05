//
//  UploadPostOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UploadPostOperation: ParseServerOperation {

    let post: Post
    
    init(post: Post) {
        
        self.post = post
        super.init(timeout: 60)
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
        
        do {
            
            try post.save()
            currentUser().archivePostedTopicID(post.topic!.objectId!)
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }        
    }
    
    
    override func finished(errors: [NSError]) {
        
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
                
                let userinfo: [NSObject: AnyObject] = [UploadPostOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(UploadPostOperation.Notifications.UploadDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }

}
