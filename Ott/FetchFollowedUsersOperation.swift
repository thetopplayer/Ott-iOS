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
    
    do {
        
        if let users = try query.findObjects() as? [User] {
            return users
        }
    }
    catch let error as NSError {
        NSLog("error = %@", error)
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
        
        do {
            
            try PFObject.unpinAllObjectsWithName(FetchFollowedUsersOperation.cacheName)
            try PFObject.pinAll(users, withName: FetchFollowedUsersOperation.cacheName)
        }
        catch let error as NSError {
            NSLog("error = %@", error)
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = User.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Follower, equalTo: currentUser())
        
        do {
            
            let objects = try query.findObjects()
            if let fetchedUsers = objects as? [User] {
                self.replaceCachedFollowedUsers(withUsers: fetchedUsers)
            }
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    

    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }
}
