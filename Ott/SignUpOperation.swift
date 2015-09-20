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
    let nickname: String
    
    init(phoneNumber: String, handle: String, nickname: String) {
        
        self.phoneNumber = phoneNumber
        self.handle = handle
        self.nickname = nickname
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
        theUser.name = nickname
        theUser.password = String.randomOfLength(12)
        
        do {
            
            try theUser.signUp()
            
            // now that the user is created, we can set the access control
            let publicReadACL = PFACL(user: theUser)
            publicReadACL.setPublicReadAccess(true)
            theUser.ACL = publicReadACL
            
            // create private data record for personal information
            let privateData = theUser.createPrivateData()
            privateData.phoneNumber = phoneNumber
            
            try theUser.save()
            try theUser.fetch() // refresh locally cached user
            
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
