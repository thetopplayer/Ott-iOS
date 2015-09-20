//
//  FetchAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


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
        
        do {
            
            let _ = try? PFObject.unpinAllObjectsWithName(cacheName)
            try PFObject.pinAll(topics, withName: cacheName)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    


    //MARK: - Execution

    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        do {
            
            let objects = try query.findObjects()
            if let topics = objects as? [Topic] {
                replaceCachedTopics(withTopics: topics)
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
    
    do {
        
        let topics = try query.findObjects()
        
        if clearCacheAfterReturning {
            let _ = try? PFObject.unpinAll(topics, withName: cacheName)
        }
        return topics as! [Topic]
    }
    catch let error as NSError {
        
        NSLog("Error getting cached topics %@", error.localizedDescription)
        return []
    }
}

