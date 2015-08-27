//
//  Topic.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit


extension DataKeys {
    
    static var AverageRating: String {
        return "averageRating"
    }
    
    static var Posts: String {
        return "posts"
    }
    
    static var NumberOfPosts: String {
        return "numberOfPosts"
    }
    
    static var LastPostLocationName: String {
        return "lastPostLocationName"
    }
}


class Topic: Creation, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "Topic"
    }
    
    /** Use this to create */
    class func createWithAuthor(author: User) -> Topic {
        
        let topic = Topic()
        topic.setAuthor(author)
        topic.numberOfPosts = 0
        topic.averageRating = 0
        topic.lastPostLocationName = ""

        return topic
    }
    
    
    //MARK: - Attributes
    
    @NSManaged var name: String?
    @NSManaged var numberOfPosts: Int
    @NSManaged var averageRating: Float
    @NSManaged var lastPostLocationName: String?

    
    
    //MARK: - Queries
    
    class func fetchTopicWithIdentifier(identifier: String, completion: PFObjectResultBlock) {
        
        Topic.query()!.getObjectInBackgroundWithId(identifier, block: completion)
    }
}

