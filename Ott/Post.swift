//
//  Post.swift
//  Ott
//
//  Created by Max on 7/21/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class Post: Creation, PFSubclassing {
    
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
    
    
    @NSManaged var topicName: String?
    
    
    func setTopic(topic: Topic) {
        
        let topicKey = "topic"        
        self[topicKey] = topic
    }
}