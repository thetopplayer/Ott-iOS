//
//  FetchPostsForTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchPostsForTopicOperation

class FetchPostsForTopicOperation: ParseOperation {
    
    let topic: Topic
    let postedSince: NSDate?
    
    init(topic: Topic, postedSince: NSDate? = nil) {
        
        self.topic = topic
        self.postedSince = postedSince
        super.init()
    }
    
    
    //MARK: - Caching
    
    static func cacheNameForTopic(topic: Topic) -> String? {
        return topic.objectId
    }
    
    private func replaceCachedPosts(withPosts posts: [Post]) {
        
        guard let cacheName = FetchPostsForTopicOperation.cacheNameForTopic(topic) else {
            return
        }
        
        do {
            
            let _ = try? PFObject.unpinAllObjectsWithName(cacheName)
            try PFObject.pinAll(posts, withName: cacheName)
        }
        catch let error as NSError {
            
            NSLog("error in replaceCachedPosts = %@", error)
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Topic, equalTo: topic)
        if let minDate = postedSince {
            query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: minDate)
        }
        
        do {
            
            let objects = try query.findObjects()
            if let fetchedPosts = objects as? [Post] {
                self.replaceCachedPosts(withPosts: fetchedPosts)
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
func cachedPostsForTopic(topic: Topic, clearCacheAfterReturning: Bool = true) -> [Post] {
    
    guard let cacheName = FetchPostsForTopicOperation.cacheNameForTopic(topic) else {
        return []
    }
    
    let query = Post.query()!
    query.orderByDescending(DataKeys.UpdatedAt)
    query.fromPinWithName(cacheName)
    
    do {
        
        let posts = try query.findObjects()
        if clearCacheAfterReturning {
            let _ = try? PFObject.unpinAll(posts, withName: cacheName)
        }
        
        return posts as! [Post]
    }
    catch let error as NSError {
        NSLog("error in cachedPostsForTopic = %@", error)
        return []
    }
}


