//
//  FetchUserByHandleOperation.swift
//  Ott
//
//  Created by Max on 9/17/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/*

Searches for a user with a handle, allowing a case-insensitve search (i.e., by 
username)

*/

import UIKit

typealias UserCompletionBlock = (user: User?, error: NSError?) -> Void

class FetchUserByHandleOperation: ParseOperation {

    let searchByUsername: Bool
    let handle: String
    let fetchCompletionBlock: UserCompletionBlock?
    var user: User? = nil
    
    
    init(handle: String, caseInsensitive: Bool, completion: UserCompletionBlock? = nil) {
        
        self.handle = handle
        searchByUsername = caseInsensitive
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

        do {
            
            let query = User.query()!
            query.limit = 1
            if searchByUsername {
                let username = User.usernameFromHandle(handle)
                query.whereKey("username", equalTo: username)
            }
            else {
                query.whereKey("handle", equalTo: handle)
            }
            
            let results = try query.findObjects()
            if results.count > 0 {
                user = results.first! as? User
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        dispatch_async(dispatch_get_main_queue()) {
            fetchCompletionBlock?(user: user, error: errors.first)
        }
    }
}
