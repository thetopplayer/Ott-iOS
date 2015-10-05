//
//  RemoveFollowOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class RemoveFollowOperation: ParseServerOperation {

    let followerHandle: String
    let followeeHandle: String
    
    init(followerHandle: String, followeeHandle: String) {
        
        self.followerHandle = followerHandle
        self.followeeHandle = followeeHandle
        super.init(timeout: 30)
    }
    
    struct Notifications {
        
        static let DidRemove = "didRemoveFollow"
        static let RemovalDidFail = "followRemovalDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        let query = Follow.query()!
        query.whereKey(DataKeys.FollowerHandle, equalTo: followerHandle)
        query.whereKey(DataKeys.FolloweeHandle, equalTo: followeeHandle)
        
        do {
            
            let object = try query.getFirstObject()
            try object.delete()
            let _ = try object.unpin()  // unpin from local store, but ignore error
            let _ = try? currentUser().fetch()  // update current user
            
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
                NSNotificationCenter.defaultCenter().postNotificationName(RemoveFollowOperation.Notifications.DidRemove,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = topmostViewController() else {
                    print("ERROR deleting follow relationship")
                    return
                }
                
                controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not delete follow relationship:")
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
