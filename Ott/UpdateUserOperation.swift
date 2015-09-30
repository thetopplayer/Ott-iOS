//
//  UpdateUserOperation.swift
//  Ott
//
//  Created by Max on 9/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UpdateUserOperation: ParseOperation {

    typealias CompletionBlock = (success: Bool, error: NSError?) -> Void
    
    var completionHandler: CompletionBlock?
    
    init(completion: CompletionBlock?) {
        
        completionHandler = completion
        super.init()
    }
    
    struct Notifications {
        
        static let DidUpdate = "didUpdateUser"
        static let UpdateDidFail = "userUpdateDidFail"
        static let ErrorKey = "error"
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        do {
            
            try currentUser().save()
            try currentUser().fetch() // refresh locally cached user
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
                
                if let completion = self.completionHandler {
                    completion(success: true, error: nil)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(UpdateUserOperation.Notifications.DidUpdate,
                    object: self)
            }
        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let completion = self.completionHandler {
                    completion(success: false, error: errors.first!)
                }
                else {
                    
                    if let controller = topmostViewController() {
                            controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not update user:")
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [UpdateUserOperation.Notifications.ErrorKey: errors.first!]
                
                NSNotificationCenter.defaultCenter().postNotificationName(UpdateUserOperation.Notifications.UpdateDidFail,
                    object: self,
                    userInfo: userinfo)
            }
        }
    }
}
