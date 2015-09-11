//
//  FetchAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

//MARK: - Utility Methods

// note that this query is synchronous
// todo:  handle error
func cachedTopicsAuthoredByUser(user: User, clearCacheAfterReturning: Bool = true) -> [Topic] {
    
    guard let cacheName = FetchAuthoredTopicsOperation.cacheNameForTopicsAuthoredByUser(user) else {
        return []
    }
    
    let query = Topic.query()!
    query.orderByDescending(DataKeys.UpdatedAt)
    query.fromPinWithName(cacheName)
    
    var error: NSError?
    if let topics = query.findObjects(&error) as? [Topic] {
        
        if clearCacheAfterReturning {
            PFObject.unpinAll(topics, withName: cacheName)
        }
        
        return topics
    }
    
    return []
}




//MARK: - FetchAuthoredTopicsOperation

class FetchAuthoredTopicsOperation: ParseOperation {
    
    let user: User
    
    init(user: User) {
        
        self.user = user
        super.init()
    }
    
    
    //MARK: - Caching
    
    static func cacheNameForTopicsAuthoredByUser(user: User) -> String? {
        return user.objectId
    }
    
    private func replaceCachedTopics(withTopics topics: [Topic]) {
        
        guard let cacheName = FetchAuthoredTopicsOperation.cacheNameForTopicsAuthoredByUser(user) else {
            return
        }
        
        PFObject.unpinAllObjectsWithName(cacheName)
        PFObject.pinAll(topics, withName: cacheName)
    }
    


    //MARK: - Execution

    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        var error: NSError?
        let objects = query.findObjects(&error)
        
        if error != nil {
            finishWithError(error)
        }
        else if let topics = objects as? [Topic] {
            replaceCachedTopics(withTopics: topics)
        }
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }
}
