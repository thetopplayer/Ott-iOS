//
//  FetchPostsForTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

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
    
    var error: NSError?
    if let posts = query.findObjects(&error) as? [Post] {
        
        if clearCacheAfterReturning {
            PFObject.unpinAll(posts, withName: cacheName)
        }
        
        return posts
    }
    
    return []
}




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
        
        PFObject.unpinAllObjectsWithName(cacheName)
        PFObject.pinAll(posts, withName: cacheName)
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Topic, equalTo: topic)
        if let minDate = postedSince {
            query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: minDate)
        }
        
        var error: NSError?
        let objects = query.findObjects(&error)
        
        if error == nil {
            if let fetchedPosts = objects as? [Post] {
                self.replaceCachedPosts(withPosts: fetchedPosts)
            }
        }

        finishWithError(error)
    }
    

    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }
}
