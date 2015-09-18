//
//  FetchFollowedUsersOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

//MARK: - Utility Methods

// note that this query is synchronous
// todo:  handle error
func cachedFolowedUsers() -> [User] {
    
    let query = User.query()!
    query.orderByDescending(DataKeys.UpdatedAt)
    query.fromPinWithName(FetchFollowedUsersOperation.cacheName)
    
    var error: NSError?
    if let users = query.findObjects(&error) as? [User] {
        return users
    }
    
    return []
}




//MARK: - FetchFollowedUsersOperation

class FetchFollowedUsersOperation: ParseOperation {
    
    override init() {
        
        super.init()
    }
    
    
    //MARK: - Caching
    
    static let cacheName = "followedUsers"
    
    private func replaceCachedFollowedUsers(withUsers users: [User]) {
        
        PFObject.unpinAllObjectsWithName(FetchFollowedUsersOperation.cacheName)
        PFObject.pinAll(users, withName: FetchFollowedUsersOperation.cacheName)
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = User.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Follower, equalTo: currentUser())
        
        var error: NSError?
        let objects = query.findObjects(&error)
        
        if error != nil {
            finishWithError(error)
        }
        else if let fetchedUsers = objects as? [User] {
            self.replaceCachedFollowedUsers(withUsers: fetchedUsers)
        }
        
        finishWithError(nil)
    }
    

    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }
}
