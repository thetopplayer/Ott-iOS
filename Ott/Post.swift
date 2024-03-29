//
//  Post.swift
//  Ott
//
//  Created by Max on 7/21/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


extension DataKeys {
    
    static var Topic: String {
        return "topic"
    }
    
    static var TopicName: String {
        return "topicName"
    }
}


class Post: AuthoredObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Post"
    }
    
    
    /** Use this to create */
    class func createForTopic(topic: Topic) -> Post {
        
        let post = Post()
        post.setTopic(topic)
        return post
    }
    
    
    //MARK: - Attributes
    
    @NSManaged var topicName: String?
    @NSManaged var sectorID: String?
    
    func setTopic(topic: Topic) {
        
        self[DataKeys.Topic] = topic
        topicName = topic.name
    }
    
    
    var topic: Topic? {
        
        return self[DataKeys.Topic] as? Topic
    }
    
}