//
//  TopicOperationProtocol.swift
//  Ott
//
//  Created by Max on 10/12/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

protocol TopicOperationProtocol {
    
    
}


extension TopicOperationProtocol {
    
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
    
    
//    func currentUserLastViewedTopic(topic: Topic) -> NSDate? {
//        
//        let query: PFQuery = {
//            
//            let query = ViewHistory.query()!
//            query.fromPinWithName(UpdateViewHistoryOperation.pinName())
//            query.limit = 1
//            
//            return query
//            }()
//        
//        query.whereKey(DataKeys.Topic, equalTo: topic)
//        if let views = try? query.findObjects() {
//            
//            if let theView = views.first as? ViewHistory {
//                return theView.viewedAt
//            }
//            return nil
//        }
//        
//        return nil
//    }
}