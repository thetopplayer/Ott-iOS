//
//  Author.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


//MARK: - Static Functions

func userWasArchived() -> Bool {
    return Author.currentUser() != nil
}


var _tmpUser: Author = {
    return Author()
}()


func currentUser() -> Author {
    
    if let user = Author.currentUser() {
        return user
    }
    
    return _tmpUser
}


func fetchUserInBackground(phoneNumber phoneNumber: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = Author.query()!
    query.whereKey(Author.phoneNumberKey, equalTo:phoneNumber)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func fetchUserInBackground(handle handle: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = Author.query()!
    query.whereKey(Author.handleKey, equalTo:handle)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func confirmUniquePhoneNumber(phoneNumber phoneNumber: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = Author.query()!
    query.whereKey(Author.phoneNumberKey, equalTo:phoneNumber)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}


func confirmUniqueUserHandle(handle handle: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = Author.query()!
    query.whereKey(Author.handleKey, equalTo:handle)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}




//MARK: - Author

class Author: PFUser {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static override func currentUser() -> Author? {
   
        return super.currentUser() as? Author
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
    
    
    //MARK: - Avatar
    
    @NSManaged var hasAvatar: Bool
    private var _cachedImage: UIImage?
    private let avatarKey = "avatar"
    
    func clearAvatar() {
        
        hasAvatar = false
        _cachedImage = nil
    }
    
    
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
            _cachedImage = image
            archive(image!, quality: quality)
        }
        else {
            if let resizedImage = image!.resized(toSize: size!) {
                _cachedImage = resizedImage
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
                completion(success: true, image: self._cachedImage)
            }
        }
        else {
            
            let imageFile = self[avatarKey] as! PFFile
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        self._cachedImage = UIImage(data: imageData)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success: true, image: self._cachedImage)
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
        
        if password == nil {
            password = generatedPassword()
        }
        
        Author.logInWithUsernameInBackground(handle!, password: password!, block: completion)
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
    
    
    func addTopic(topic: Topic) {
        
        incrementKey(numberOfTopicsKey)
        
        // todo - add ID to recently postedtopicids
    }

    
    func removeTopic(topic: Topic) {
        
        let relation = relationForKey(topicsKey)
        relation.removeObject(topic)
        incrementKey(numberOfPostsKey, byAmount: -1)
    }
    

    func getTopics(completion: (success: Bool, posts: [Topic]?) -> Void) {
        
        
    }
    
    
    private var recentlyPostedTopicIDs: [String]?
    
    func didPostToTopic(topic: Topic) -> Bool {
        
        return false
    }
    
}

