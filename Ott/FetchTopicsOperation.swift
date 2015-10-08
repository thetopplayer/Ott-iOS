//
//  FetchTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/***

Abstract class used to fetch topics

*/

import Foundation


class FetchTopicsOperation: FetchOperation {
    

    //MARK: - User Did Post
        
    /// searches locally cached posts
    func currentUserDidPostToTopic(topic: Topic) -> Bool {

        let postQuery: PFQuery = {
            
            let query = Post.query()!
            query.fromPinWithName(FetchCurrentUserAuthoredPostsOperation.pinName()!)
            query.limit = 1
            
            return query
            }()
        
        postQuery.whereKey(DataKeys.Topic, equalTo: topic)
        if let posts = try? postQuery.findObjects() {
            return posts.count > 0
        }
        
        return false
    }
    
    
    //MARK: - Execution
    
    /// this should be overridden by subclasses
    func query() -> PFQuery {
        assert(false)
    }

    
    override func execute() {
        
        do {
            
            if let data = (try query().findObjects()) as? [Topic] {
                
                if dataSource == .Server {
                    for topic in data {
                        topic.currentUserDidPostTo = currentUserDidPostToTopic(topic)
                    }
                }
                fetchedData = data
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

