//
//  TopicObject.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicObject: CreationObject {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func parseClassName() -> String {
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
    
    
    func addPost(post: PostObject) {
        
        let relation = relationForKey(postsKey)
        relation.addObject(post)
        incrementKey(numberOfPostsKey)
    }
    
    
    func removePost(post: PostObject) {
        
        let relation = relationForKey(postsKey)
        relation.removeObject(post)
        incrementKey(numberOfPostsKey,byAmount: -1)
    }
    
    
    func getPosts(completion: (success: Bool, posts: [PostObject]?) -> Void) {
        
    }

}

