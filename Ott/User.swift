//
//  User.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


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
    
    struct DataKeys {
        
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
    
    
    func hasAvatar() -> Bool {
        
        return hasImage()
    }
    
    
    func getAvatar(completion: ((success: Bool, image: UIImage?) -> Void)?) {
        
        getImage(completion: completion)
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


    
    //MARK: - Authored Topics
    
    private var authoredTopicArchivePath: String {
        
        return documentsDirectory() + "/authoredTopics.ott"
    }
    
    
    func authoredTopicNames() -> [String] {
        
        if let archive = NSArray(contentsOfFile: authoredTopicArchivePath) {
            return archive as! [String]
        }
        
        return Array<String>()
    }
    
    
    private func archiveAuthoredTopicNames(names: NSArray) {
        
        names.writeToFile(authoredTopicArchivePath, atomically: true)
    }
    
    
    func archiveAuthoredTopicName(name: String) {
        
        let topicNames = NSMutableSet()
        topicNames.unionSet(NSSet(array: authoredTopicNames()) as! Set<String>)
        topicNames.addObject(name)
        archiveAuthoredTopicNames(topicNames.allObjects)
    }
    
    
    func didAuthorTopic(topic: Topic) -> Bool {
        
        let topicAuthorHandle = topic.authorHandle?.capitalizedString
        return handle?.capitalizedString == topicAuthorHandle
    }
    
    
    func purgeAuthoredTopicsArchive() {
        
        archiveAuthoredTopicNames([])
    }
    

    
    //MARK: - Quick Tracking of Topics and Posts
    
    private var postedTopicArchivePath: String {
        
        return documentsDirectory(withSubpath: "/postedTopics.ott")!
    }
    
    
    private func postedTopicIDs() -> [String] {
        
        if let archive = NSArray(contentsOfFile: postedTopicArchivePath) {
            return archive as! [String]
        }
        
        return Array<String>()
    }
    
    
    private func archivePostedTopicIDs(topicIDs: NSArray) {
        
        topicIDs.writeToFile(postedTopicArchivePath, atomically: true)
    }
    
    
    func archivePostedTopicID(topicID: String) {
        
        let topicIDs = NSMutableSet()
        topicIDs.unionSet(NSSet(array: postedTopicIDs()) as! Set<String>)
        topicIDs.addObject(topicID)
        archivePostedTopicIDs(topicIDs.allObjects)
    }
    
    
    func didPostToTopic(topic: Topic) -> Bool {
        
        if let topicID = topic.objectId {
            return postedTopicIDs().contains(topicID)
        }
        
        return false
    }
    

    func purgePostedTopicArchive() {
        
        archivePostedTopicIDs([])
    }
    
    
    
    //MARK: - Followed Users
    
    private var followedUserHandlesArchivePath: String {
        
        return documentsDirectory(withSubpath: "/followedUsers.ott")!
    }
    
    
    private func followedUserHandles() -> [String] {
        
        if let archive = NSArray(contentsOfFile: followedUserHandlesArchivePath) {
            return archive as! [String]
        }
        
        return Array<String>()
    }
    
    
    private func archiveFollowedUserHandles(handles: NSArray) {
        
        handles.writeToFile(followedUserHandlesArchivePath, atomically: true)
    }
    
    
    func archiveFollowedUserHandle(handle: String) {
        
        let allHandles = NSMutableSet()
        allHandles.unionSet(NSSet(array: followedUserHandles()) as! Set<String>)
        allHandles.addObject(handle)
        archiveFollowedUserHandles(allHandles.allObjects)
    }
    
    
    func isFollowingUserWithHandle(handle: String) -> Bool {
        
        return followedUserHandles().contains(handle)
    }
    
    
    func removeHandleFromFollowedUserHandlesArchive(handle: String) {
        
        let allHandles = NSMutableSet()
        allHandles.unionSet(NSSet(array: followedUserHandles()) as! Set<String>)
        allHandles.removeObject(handle)
        archiveFollowedUserHandles(allHandles.allObjects)
    }
    
    
    func purgeFollowedUsersArchive() {
        
        archiveFollowedUserHandles([])
    }

}

