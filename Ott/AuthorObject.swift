//
//  AuthorObject.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


func userWasArchived() -> Bool {
    return AuthorObject.currentUser() != nil
}


var _tmpUser: AuthorObject = {
    return AuthorObject()
}()


func currentUser() -> AuthorObject {
    
    if let user = AuthorObject.currentUser() {
        return user
    }
    
    return _tmpUser
}


func fetchUserInBackground(phoneNumber phoneNumber: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = AuthorObject.query()!
    query.whereKey(AuthorObject.phoneNumberKey, equalTo:phoneNumber)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func fetchUserInBackground(handle handle: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = AuthorObject.query()!
    query.whereKey(AuthorObject.handleKey, equalTo:handle)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func confirmUniquePhoneNumber(phoneNumber phoneNumber: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = AuthorObject.query()!
    query.whereKey(AuthorObject.phoneNumberKey, equalTo:phoneNumber)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}


func confirmUniqueUserHandle(handle handle: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = AuthorObject.query()!
    query.whereKey(AuthorObject.handleKey, equalTo:handle)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
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
    
//    static var _currentUser: AuthorObject?
    static override func currentUser() -> AuthorObject? {
   
        return super.currentUser() as? AuthorObject
        
//        if _currentUser != nil {
//            return _currentUser!
//        }
//        
//        _currentUser = super.currentUser() as? AuthorObject
//        if _currentUser != nil {
//            print("current user was archived")
//            return _currentUser!
//        }
//
//        _currentUser = AuthorObject()
//        return _currentUser!
    }
    
    
    
    //MARK: - Attributes
    
    static let phoneNumberKey = "phoneNumber"
    static let handleKey = "username"
    
    @NSManaged var phoneNumber: String?
    @NSManaged var name: String?
    
    // the user's handle is stored as his username
    var handle: String? {
        set {
            username = newValue
            password = phoneNumber! + username!
        }
        
        get {
            return username
        }
    }
    
    
    func signupInBackground(completion: (succeeded: Bool, error: NSError?) -> Void) {
        
        if (username == nil) || (password == nil) {
            let userInfo = [NSLocalizedDescriptionKey : "Username or password not set."]
            let error = NSError(domain: "User", code: 1, userInfo: userInfo)
            completion(succeeded: false, error: error)
        }
        else {
            signUpInBackgroundWithBlock(completion)
        }
    }
    
    
    func loginInBackground(completion: (user: PFUser?, error: NSError?) -> Void) {
        
        AuthorObject.logInWithUsernameInBackground(handle!, password: password!, block: completion)
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

