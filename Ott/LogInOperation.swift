//
//  LogInOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LogInOperation: ParseOperation {

    let handle: String
    let password: String
    
    init(handle: String, password: String) {
        
        self.handle = handle
        self.password = password
        super.init()
    }
    
    struct Notifications {
        
        static let DidLogIn = "didLogIn"
        static let LogInDidFail = "logInDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        let username = User.usernameFromHandle(handle)
        
        do {
            
            try User.logInWithUsername(username, password: password)
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
                NSNotificationCenter.defaultCenter().postNotificationName(LogInOperation.Notifications.DidLogIn,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [LogInOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(LogInOperation.Notifications.LogInDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    
}
