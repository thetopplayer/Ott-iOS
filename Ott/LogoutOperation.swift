//
//  LogoutOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LogoutOperation: ParseServerOperation {

    
    struct Notifications {
        
        static let DidLogout = "DidLogout"
        static let LogoutDidFail = "logoutDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        FetchCurrentUserAuthoredTopicsOperation.purgeCache()
        FetchCurrentUserAuthoredPostsOperation.purgeCache()
        FetchCurrentUserFolloweesOperation.purgeCache()
        FetchFolloweeTopicsOperation.purgeCache()
        
        User.logOut()
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(LogoutOperation.Notifications.DidLogout,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [LogoutOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(LogoutOperation.Notifications.LogoutDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    
}
