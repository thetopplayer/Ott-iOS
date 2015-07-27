//
//  AuthorObject.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


func currentUser() -> AuthorObject {
    return AuthorObject.currentUser()
}



class AuthorObject: PFUser {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static var _currentUser: AuthorObject?
    static override func currentUser() -> AuthorObject {
        
        if _currentUser != nil {
            return _currentUser!
        }
        
        _currentUser = super.currentUser() as? AuthorObject
        if _currentUser != nil {
            return _currentUser!
        }

        _currentUser = AuthorObject()
        return _currentUser!
    }
    
    
    
    
    //MARK: - Attributes
    
    @NSManaged var phoneNumber: String?
    @NSManaged var name: String?
    
    var handle: String? {
        return username
    }

    
    //MARK: - Posts and Topics
    
    private let postsKey = "posts"
    private let numberOfPostsKey = "numberPosts"
    private let topicsKey = "topics"
    private let numberOfTopicsKey = "numberTopics"
    
    var numberOfPosts: Int? {
        return self[numberOfPostsKey] as? Int
    }
    
    
    var numberOfTopics: Int? {
        return self[numberOfTopicsKey] as? Int
    }
    
    
    func addPost(post: PostObject) {
        
        let relation = relationForKey(postsKey)
        relation.addObject(post)
        incrementKey(numberOfPostsKey)

    }
    
    func removePost(post: PostObject) {
        
        let relation = relationForKey(postsKey)
        relation.removeObject(post)
        incrementKey(numberOfPostsKey, byAmount: -1)
    }

    
    func getPosts(completion: (success: Bool, posts: [PostObject]?) -> Void) {
        
        
    }
    
    
    func addTopic(topic: TopicObject) {
        
        let relation = relationForKey(topicsKey)
        relation.addObject(topic)
        incrementKey(numberOfTopicsKey)
        
        // todo - add ID to recently postedtopicids
    }

    
    func removeTopic(topic: TopicObject) {
        
        let relation = relationForKey(topicsKey)
        relation.removeObject(topic)
        incrementKey(numberOfPostsKey, byAmount: -1)
    }
    

    func getTopics(completion: (success: Bool, posts: [TopicObject]?) -> Void) {
        
        
    }
    
    
    private var recentlyPostedTopicIDs: [String]?
    
    func didPostToTopic(topic: TopicObject) -> Bool {
        
        return false
    }
    

    
    func setAvatar(image: UIImage?) -> Void {
        
    }
    
    
    func getAvatar(completion: (success: Bool, image: UIImage?) -> Void) {
        
        
    }
}

