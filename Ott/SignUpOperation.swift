//
//  SignUpOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class SignUpOperation: ParseOperation {

    let phoneNumber: String
    let handle: String
    let userName: String
    
    init(phoneNumber: String, handle: String, userName: String) {
        
        self.phoneNumber = phoneNumber
        self.handle = handle
        self.userName = userName
        super.init()
    }
    
    struct Notifications {
        
        static let DidSignUp = "didSignUp"
        static let SignUpDidFail = "signUpDidFail"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        let theUser = User.create()
        theUser.handle = handle
        theUser.name = userName
        theUser.password = String.randomOfLength(12)
        
        var error: NSError? = nil
        theUser.signUp(&error)
        
        if let error = error {
            finishWithError(error)
        }
        
        // now that the user is created, we can set the access control and personal information
        
        theUser.ACL = PFACL(user: theUser)
        theUser.phoneNumber = phoneNumber
        theUser.save(&error)
        
        if let error = error {
            finishWithError(error)
        }
        
        // refresh locally cached user
        theUser.fetch(&error)
        finishWithError(error)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(SignUpOperation.Notifications.DidSignUp,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [SignUpOperation.Notifications.ErrorKey: errors.first!]
                NSNotificationCenter.defaultCenter().postNotificationName(CreateFollowOperation.Notifications.CreationDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
    
}
