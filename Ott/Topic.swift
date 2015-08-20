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
        return "aveRating"
    }
    
    static var Posts: String {
        return "posts"
    }
    
    static var NumberOfPosts: String {
        return "numPosts"
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
        
        return topic
    }
    
    
    
    //MARK: - Queries
    
    class func fetchTopicWithIdentifier(identifier: String, completion: PFObjectResultBlock) {
        
        Topic.query()!.getObjectInBackgroundWithId(identifier, block: completion)
    }
    
    
    class func fetchTopicsNearLocation(location: CLLocation, withinMiles: Double, completion: PFArrayResultBlock) {
        
        let geoPoint = PFGeoPoint(location: location)
        
        let query = Topic.query()!
        query.whereKey(DataKeys.Location, nearGeoPoint: geoPoint, withinMiles: withinMiles)
        query.findObjectsInBackgroundWithBlock(completion)
    }
    
    
    class func fetchTrendingTopics(completion: PFBooleanResultBlock) {
        
    }
    
    
    class func fetchTopicsWithUser(user: User, completion: PFBooleanResultBlock) {
        
    }
    
    

    //MARK: - Attributes
    
    @NSManaged var name: String?
    
    var averageRating: Int? {
        
        set {
            if let val = newValue {
                self[DataKeys.AverageRating] = val
            }
        }
        
        get {
            return self[DataKeys.AverageRating] as? Int
        }
    }
    
    
    @NSManaged var numberOfPosts: Int
//    var numberOfPosts: Int? {
//        return self[DataKeys.NumberOfPosts] as? Int
//    }
    
    
    func addPost(post: Post) {
        
        let relation = relationForKey(DataKeys.Posts)
        relation.addObject(post)
        incrementKey(DataKeys.NumberOfPosts)
    }
    
    
    func removePost(post: Post) {
        
        let relation = relationForKey(DataKeys.Posts)
        relation.removeObject(post)
        incrementKey(DataKeys.NumberOfPosts,byAmount: -1)
    }
    
    
    func getPosts(completion: (success: Bool, posts: [Post]?) -> Void) {
        
    }

}

