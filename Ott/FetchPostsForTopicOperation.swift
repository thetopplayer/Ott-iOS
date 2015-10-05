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
        super.init(dataSource: .Server, pinFetchedData: false, completion: completion)
    }
    


    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Topic, equalTo: topic)
        
        do {
            
            fetchedData = try query.findObjects()
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

