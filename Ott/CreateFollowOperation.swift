//
//  CreateFollowOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class CreateFollowOperation: ParseOperation {

    let followeeHandle: String
    
    init(followeeHandle: String) {
        
        self.followeeHandle = followeeHandle
        super.init()
    }
    
    struct Notifications {
        
        static let DidCreate = "didCreateFollow"
        static let CreationDidFail = "followCreationDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        var error: NSError?
        let follow = Follow()
        follow.followerHandle = currentUser().handle
        follow.followeeHandle = followeeHandle
        
        follow.save(&error)
        
        if let error = error {
            finishWithError(error)
        }
        
        currentUser().archiveFollowedUserWithHandle(followeeHandle)
        
        // refresh user data
        currentUser().fetch(&error)
        if let error = error {
            finishWithError(error)
        }
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(CreateFollowOperation.Notifications.DidCreate,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = topmostViewController() else {
                    print("ERROR creating follow relationship")
                    return
                }
                
                controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not create follow relationship:")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [CreateFollowOperation.Notifications.ErrorKey: errors]
                NSNotificationCenter.defaultCenter().postNotificationName(CreateFollowOperation.Notifications.CreationDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    

}
