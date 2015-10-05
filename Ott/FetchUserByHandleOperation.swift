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

class FetchUserByHandleOperation: ParseFetchOperation {

    let searchByUsername: Bool
    let handle: String

    init(handle: String, caseInsensitive: Bool, completion: FetchCompletionBlock?) {
        
        self.handle = handle
        searchByUsername = caseInsensitive
        super.init(dataSource: .Server, completion: completion)
    }
    
    struct Notifications {
        
        static let DidFetch = "didFetchUser"
        static let FetchDidFail = "userFetchDidFail"
        static let TopicKey = "user"
        static let ErrorKey = "error"
    }
    
    
    var fetchedData: [User]?
    
    

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
            
            fetchedData = (try query.findObjects()) as? [User]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
}
