//
//  Topic.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

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
    
    
    @NSManaged var name: String?
    
    private let averageRatingKey = "aveRating"
    var averageRating: Int? {
        return self[averageRatingKey] as? Int
    }
    
    
    //MARK: - Posts
    
    private let postsKey = "posts"
    private let numberOfPostsKey = "numberPosts"
    
    var numberOfPosts: Int? {
        return self[numberOfPostsKey] as? Int
    }
    
    
    func addPost(post: Post) {
        
        let relation = relationForKey(postsKey)
        relation.addObject(post)
        incrementKey(numberOfPostsKey)
    }
    
    
    func removePost(post: Post) {
        
        let relation = relationForKey(postsKey)
        relation.removeObject(post)
        incrementKey(numberOfPostsKey,byAmount: -1)
    }
    
    
    func getPosts(completion: (success: Bool, posts: [Post]?) -> Void) {
        
    }

}

