//
//  User.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


extension DataKeys {
    
    static var PrivateData: String {
        return "privateData"
    }
    
    // the handle is the prettier version of "username" as created by the user
    static var Handle: String {
        return "handle"
    }
    
    static var NumberOfTopics: String {
        return "numberOfTopics"
    }
    
    static var PhoneNumber: String {
        return "phoneNumber"
    }
    
    static var NumberOfPosts: String {
        return "numberOfPosts"
    }
    
    static var Bio: String {
        return "bio"
    }
    
    static var Avatar: String {
        return "avatar"
    }
    
    static var BackgroundImage: String {
        return "backgroundImage"
    }
    
    static var FollowingCount: String {
        return "followingCount"
    }
    
    static var FollowersCount: String {
        return "followersCount"
    }
    
    static var LastTopicCreatedAt: String {
        return "lastTopicCreatedAt"
    }
}


//MARK: - Static Functions

func userIsLoggedIn() -> Bool {
    return User.currentUser() != nil
}


func currentUser() -> User {
    return User.currentUser()!
}



//MARK: - User

class User: PFUser {

    static let minimumHandleLength = 4
    static let minimumUserNameLength = 3

    /****/
    
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
    
    /** Use this to create */
    class func create() -> User {
        
        let user = User()
        user.numberOfTopics = 0
        user.numberOfPosts = 0
        user.followingCount = 0
        user.followersCount = 0
        user.lastTopicCreatedAt = NSDate.distantPast()
        return user
    }
    
    
    // strip off "@" sign and convert to uppercase
    // this is to allow accurate searching and case-insensitive uniqueness
    static func usernameFromHandle(handle: String) -> String {
        return handle.stringByRemovingCharactersInString("@").uppercaseString
    }
    

    @NSManaged var name: String? // user's non-unique name
    @NSManaged var handle: String?
    @NSManaged var numberOfTopics: Int
    @NSManaged var numberOfPosts: Int
    @NSManaged var bio: String?
    @NSManaged var followingCount: Int
    @NSManaged var followersCount: Int
    @NSManaged var lastTopicCreatedAt: NSDate?
    
    static var defaultAvatar: UIImage = {
        
        return UIImage(named:"avatar")!
        }()
    
    
    var avatarFile: PFFile? {
        
        return self[DataKeys.Avatar] as? PFFile
    }
    
    
    func setAvatar(avatar: UIImage?) {
        
        setImage(avatar, forKey: DataKeys.Avatar)
    }
    
    
    var backgroundImageFile: PFFile? {
        
        return self[DataKeys.BackgroundImage] as? PFFile
    }
    
    
    func setBackgroundImage(backgroundImage: UIImage?) {
        
        setImage(backgroundImage, forKey: DataKeys.BackgroundImage)
    }
    
    
    func createPrivateData() -> PrivateUserData {
        
        // create private data and set so that only the user can read & write
        let data = PrivateUserData()
        data.ACL = PFACL(user: self)
        self[DataKeys.PrivateData] = data
        
        return data
    }
    
    
    // synchronous fetch
    var privateData: PrivateUserData {
        
        get {
            let pd = self[DataKeys.PrivateData] as! PrivateUserData
            try! pd.fetchIfNeeded()
            return pd
        }
    }
    
    
    var phoneNumber: String? {
        
        get {
            return privateData.phoneNumber
        }
        
        set {
            // server side code will move this to the privateData
            self[DataKeys.PhoneNumber] = newValue
        }
    }



    //MARK: - Queries
    
    func didAuthorTopic(topic: Topic) -> Bool {
        
        let author = topic.author!
        return author.isEqual(currentUser())
    }
    

    // search cached topics authored by currentUser, returning true if a topic with this name has already been authored
    func verifyNewTopicTitle(name: String, completion: (isNew: Bool) -> Void) {
        
        let searchName = name.capitalizedString
        
        let query = Topic.query()!
        query.whereKey(DataKeys.AllCapsName, equalTo: searchName)
        query.fromPinWithName(FetchCurrentUserAuthoredTopicsOperation.pinName())
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let _ = (objects as? [Topic])?.first {
                    completion(isNew: false)
                }
                else {
                    completion(isNew: true)
                }
            }
        }
    }

    
    // as determined by only searching local cache, which should only contain posts authored by currentUser
    func didPostToTopic(topic: Topic, completion: (didPost: Bool) -> Void) {
        
        let query = Post.query()!
        query.whereKey(DataKeys.Topic, equalTo: topic)
        query.fromPinWithName(FetchCurrentUserAuthoredPostsOperation.pinName())
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {

                if let _ = (objects as? [Post])?.first {
                    completion(didPost: true)
                }
                else {
                    completion(didPost: false)
                }
            }
        }
    }
    
    
    func getFollowStatusForUserWithHandle(handle: String, completion: (following: Bool) -> Void) {
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.fromPinWithName(FetchCurrentUserFolloweesOperation.pinName())
            query.whereKey(DataKeys.FolloweeHandle, equalTo: handle)
            query.limit = 1
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            var isFollowing = false
            if let _ = objects?.first as? Follow {
                isFollowing = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(following: isFollowing)
            }
        }
    }

}

