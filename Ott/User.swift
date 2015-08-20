//
//  User.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


//MARK: - Static Functions

func userWasArchived() -> Bool {
    return User.currentUser() != nil
}


var _tmpUser: User = {
    return User()
}()


func currentUser() -> User {
    
    if let user = User.currentUser() {
        return user
    }
    
    return _tmpUser
}


func fetchUserInBackground(phoneNumber phoneNumber: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.phoneNumberKey, equalTo:phoneNumber)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func fetchUserInBackground(handle handle: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.handleKey, equalTo:handle)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func confirmUniquePhoneNumber(phoneNumber phoneNumber: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.phoneNumberKey, equalTo:phoneNumber)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}


func confirmUniqueUserHandle(handle handle: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.handleKey, equalTo:handle)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}




//MARK: - User

class User: PFUser {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static override func currentUser() -> User? {
   
        return super.currentUser() as? User
    }
    

    
    
    //MARK: - Core Attributes
    
    static let phoneNumberKey = "phoneNumber"
    static let handleKey = "username"
    
    @NSManaged var phoneNumber: String?
    @NSManaged var name: String? // user's non-unique name
    
    // the user's handle is stored as his username
    // password is created by setting the handle
    var handle: String? {
        set {
            username = newValue
            password = generatedPassword()
        }
        
        get {
            return username
        }
    }
    
    
    private func generatedPassword() -> String {
        return phoneNumber! + username!
    }
    
    
    // used during signUp
    var phoneNumberValidationCode: String?
    static var defaultAvatar: UIImage = {
        
        return UIImage(named:"avatar")!
    }()
    
    
    
    //MARK: - SignUp and Login
    
    override func signUpInBackgroundWithBlock(block: PFBooleanResultBlock?) {
        
        if (username == nil) || (password == nil) {
            let userInfo = [NSLocalizedDescriptionKey : "Username or password not set."]
            let error = NSError(domain: "User", code: 1, userInfo: userInfo)
            block?(false, error)
        }
        else {
            super.signUpInBackgroundWithBlock(block)
        }
    }
    

    func loginInBackground(completion: (user: PFUser?, error: NSError?) -> Void) {
        
        if password == nil {
            password = generatedPassword()
        }
        
        User.logInWithUsernameInBackground(handle!, password: password!, block: completion)
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
    
    
    func addPost(post: Post) {
        
        let relation = relationForKey(postsKey)
        relation.addObject(post)
        incrementKey(numberOfPostsKey)

    }
    
    
    func removePost(post: Post) {
        
        let relation = relationForKey(postsKey)
        relation.removeObject(post)
        incrementKey(numberOfPostsKey, byAmount: -1)
    }

    
    func getPosts(completion: (success: Bool, posts: [Post]?) -> Void) {
        
        
    }
    
    
//    func addTopic(topic: Topic) {
//        
//        incrementKey(numberOfTopicsKey)
//        
//        // todo - add ID to recently postedtopicids
//    }
//
//    
//    func removeTopic(topic: Topic) {
//        
//        let relation = relationForKey(topicsKey)
//        relation.removeObject(topic)
//        incrementKey(numberOfPostsKey, byAmount: -1)
//    }
    

    func getTopics(completion: (success: Bool, posts: [Topic]?) -> Void) {
        
        
    }
    
    
    private var recentlyPostedTopicIDs: [String]?
    
    func didPostToTopic(topic: Topic) -> Bool {
        
        return false
    }
    
}

