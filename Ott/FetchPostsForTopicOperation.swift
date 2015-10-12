//
//  FetchPostsForTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import Foundation


//MARK: - FetchPostsForTopicOperation

class FetchPostsForTopicOperation: FetchOperation {
    
    init(topic: Topic, offset: Int, limit: Int, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Post.query()!
            query.skip = offset
            query.limit = limit
            query.orderByDescending(DataKeys.UpdatedAt)
            query.whereKey(DataKeys.Topic, equalTo: topic)
            return query
        }()
        
        super.init(dataSource: .Server, query: theQuery, completion: completion)
    }
    
}

