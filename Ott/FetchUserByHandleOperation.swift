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

class FetchUserByHandleOperation: FetchOperation {

    init(handle: String, caseInsensitive: Bool, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = User.query()!
            query.limit = 1
            if caseInsensitive {
                let username = User.usernameFromHandle(handle)
                query.whereKey("username", equalTo: username)
            }
            else {
                query.whereKey("handle", equalTo: handle)
            }
            
            return query
        }()
        
        super.init(dataSource: .Server, query: theQuery, completion: completion)
    }
    
}
