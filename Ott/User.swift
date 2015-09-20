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
    return User.create()
}()


func currentUser() -> User {
    
    if let user = User.currentUser() {
        return user
    }
    
    print("returning temp user")
    return _tmpUser
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
    }
    
    
    /** Use this to create */
    class func create() -> User {
        
        let user = User()
        user.numberOfTopics = 0
        user.numberOfPosts = 0
        return user
    }
    
    
    @NSManaged var name: String? // user's non-unique name
    @NSManaged var numberOfTopics: Int
    @NSManaged var numberOfPosts: Int
    @NSManaged var bio: String?
    
    static var defaultAvatar: UIImage = {
        
        return UIImage(named:"avatar")!
        }()
    
    
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
    
    
    // strip off "@" sign and convert to uppercase
    // this is to allow accurate searching and case-insensitive uniqueness
    static func usernameFromHandle(handle: String) -> String {
        return handle.stringByRemovingCharactersInString("@").uppercaseString
    }
    
    
    // the user's handle is a prettier version of the username
    var handle: String? {
        set {
            self[DataKeys.Handle] = newValue
            username = User.usernameFromHandle(newValue!)
        }
        
        get {
            return self[DataKeys.Handle] as? String
        }
    }
    
    
    
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
        
        User.logInWithUsernameInBackground(handle!, password: password!, block: completion)
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
    
    
    
    //MARK: - Followed Users
    
    private var followedUsersArchivePath: String {
        
        return documentsDirectory(withSubpath: "/followedUsers.ott")!
    }
    
    
    private func followedUserHandles() -> [String] {
        
        if let archive = NSArray(contentsOfFile: followedUsersArchivePath) {
            return archive as! [String]
        }
        
        return Array<String>()
    }
    
    
    private func archiveFollowedUserHandles(userHandles: NSArray) {
        
        userHandles.writeToFile(followedUsersArchivePath, atomically: true)
    }
    
    
    func archiveFollowedUserWithHandle(handle: String) {
        
        let userHandles = NSMutableSet()
        userHandles.unionSet(NSSet(array: followedUserHandles()) as! Set<String>)
        userHandles.addObject(handle)
        archiveFollowedUserHandles(userHandles.allObjects)
    }
    
    
    func isFollowingUserWithHandle(handle: String) -> Bool {
        
        return followedUserHandles().contains(handle)
    }
    
    
    func removeHandleFromFollowedUsersArchive(handle: String) {
        
        let userHandles = NSMutableSet()
        userHandles.unionSet(NSSet(array: followedUserHandles()) as! Set<String>)
        userHandles.removeObject(handle)
        archiveFollowedUserHandles(userHandles.allObjects)
    }
    
}

