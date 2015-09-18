//
//  FetchUserByHandleOperation.swift
//  Ott
//
//  Created by Max on 9/17/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

typealias UserCompletionBlock = (user: User?, error: NSError?) -> Void

class FetchUserByHandleOperation: ParseOperation {

    let handle: String
    let fetchCompletionBlock: UserCompletionBlock?
    var user: User?
    
    
    init(handle: String, completion: UserCompletionBlock? = nil) {
        
        self.handle = handle
        fetchCompletionBlock = completion
        super.init()
    }
    
    
    struct Notifications {
        
        static let DidFetch = "didFetchUser"
        static let FetchDidFail = "userFetchDidFail"
        static let TopicKey = "user"
        static let ErrorKey = "error"
    }
    
    
    //MARK: - Execution
    
    override func execute() {
        
        var error: NSError? = nil
        
        let query = User.query()!
        query.whereKey(User.DataKeys.Handle, equalTo: handle)
        query.limit = 1
        if let results = query.findObjects(&error) as? [User] {
            user = results.first
        }
        
        finishWithError(error)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        dispatch_async(dispatch_get_main_queue()) {
            fetchCompletionBlock?(user: user, error: errors.first!)
        }
    }
}
