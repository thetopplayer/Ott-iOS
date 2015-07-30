//
//  AuthorObject.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit




//MARK: - Static Functions

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




//MARK: - AuthorObject

class AuthorObject: PFUser {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static override func currentUser() -> AuthorObject? {
   
        return super.currentUser() as? AuthorObject
    }
    
    
//    override init() {
//        
//        super.init()
//        hasAvatar = false
//    }

    
    
    //MARK: - Core Attributes
    
    static let phoneNumberKey = "phoneNumber"
    static let handleKey = "username"
    static let avatarKey = "avatar"
    
    @NSManaged var phoneNumber: String?
    @NSManaged var name: String? // user's non-unique name
    
    // the user's handle is stored as his username
    // password is created by setting the handle
    var handle: String? {
        set {
            username = newValue
            password = phoneNumber! + username!
        }
        
        get {
            return username
        }
    }
    
    // used during signUp
    var phoneNumberValidationCode: String?
    
    
    //MARK: - Avatar
    
    @NSManaged var hasAvatar: Bool
    private var _cachedImage: UIImage?
    private let avatarKey = "avatar"
    
    func setAvatar(image: UIImage?, size: CGSize?, var quality: CGFloat) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let filename = "avatar.jpg"
                let imageFile = PFFile(name: filename, data:imageRep)
                self[avatarKey] = imageFile
                hasAvatar = true
            }
            else {
                self[avatarKey] = nil
                hasAvatar = false
            }
        }
        
        if image == nil {
            hasAvatar = false
            self[avatarKey] = nil
            return
        }
        
        if (quality < 0) || (quality > 1.0) {
            NSLog("Warning:  Image Quality must be between 0 and 1.0!  setting to 1.0")
            quality = 1.0
        }
        
        if size == nil {
            archive(image!, quality: quality)
        }
        else {
            if let resizedImage = image!.resized(toSize: size!) {
                archive(resizedImage, quality: quality)
            }
        }
    }
    
    
    func getAvatar(completion: (success: Bool, image: UIImage?) -> Void) {
        
        if hasAvatar == false {
            dispatch_async(dispatch_get_main_queue()) {
                completion(success: true, image: nil)
            }
        }
        else if (_cachedImage != nil) {
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success: true, image: self._cachedImage!)
            }
        }
        else {
            
            let imageFile = PFFile()
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    self._cachedImage = UIImage(data: imageData!)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success: true, image: self._cachedImage!)
                    }
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success: false, image: nil)
                    }
                }
            }
        }
    }

    
    static var defaultAvatar: UIImage = {
        
        return UIImage(named:"avatar")!
    }()
    
    
    
    //MARK: - SignUp and Login
    
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
    
}

