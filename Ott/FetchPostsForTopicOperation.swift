//
//  FetchPostsForTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import Foundation


//MARK: - FetchPostsForTopicOperation

class FetchPostsForTopicOperation: ParseFetchOperation {
    
    let topic: Topic
    
    init(topic: Topic, completion: FetchCompletionBlock?) {
        
        self.topic = topic
        super.init(dataSource: .Server, completion: completion)
    }
    
    var fetchedData: [Post]?
    
    

    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Topic, equalTo: topic)
        query.cachePolicy = .CacheElseNetwork
        
        do {
            
            fetchedData = (try query.findObjects()) as? [Post]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

