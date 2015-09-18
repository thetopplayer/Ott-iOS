//
//  RemoveFollowOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class RemoveFollowOperation: ParseOperation {

    let followeeHandle: String
    
    init(followeeHandle: String) {
        
        self.followeeHandle = followeeHandle
        super.init()
    }
    
    struct Notifications {
        
        static let DidRemove = "didRemoveFollow"
        static let RemovalDidFail = "followRemovalDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        currentUser().removeHandleFromFollowedUsersArchive(followeeHandle)
        
        let query = Follow.query()!
        query.whereKey(DataKeys.FolloweeHandle, equalTo: followeeHandle)
        
        var error: NSError? = nil
        if let object = query.getFirstObject(&error) {
            
            var error: NSError? = nil
            object.delete(&error)
            finishWithError(error)
        }
        finishWithError(error)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(RemoveFollowOperation.Notifications.DidRemove,
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
                
                let userinfo: [NSObject: AnyObject] = [RemoveFollowOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(RemoveFollowOperation.Notifications.RemovalDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    

}
