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
    
    print("returning temp user")
    return _tmpUser
}


func fetchUserInBackground(phoneNumber phoneNumber: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.DataKeys.PhoneNumber, equalTo:phoneNumber)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func fetchUserInBackground(handle handle: String, completion: (object: PFObject?, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.DataKeys.Handle, equalTo:handle)
    query.getFirstObjectInBackgroundWithBlock(completion)
}


func confirmUniquePhoneNumber(phoneNumber phoneNumber: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.DataKeys.PhoneNumber, equalTo:phoneNumber)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
}


func confirmUniqueUserHandle(handle handle: String, completion: (isUnique: Bool, error: NSError?) -> Void) {
    
    let query = User.query()!
    query.whereKey(User.DataKeys.Handle, equalTo:handle)
    query.countObjectsInBackgroundWithBlock {
        
        (count: Int32, error: NSError?) -> Void in
        completion(isUnique: count == 0, error: error)
    }
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
        
        static var PhoneNumber: String {
            return "phoneNumber"
        }
        
        static var Handle: String {
            return "username"
        }
        
        static var NumberOfTopics: String {
            return "numberOfTopics"
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
    
    
    @NSManaged var phoneNumber: String?
    @NSManaged var name: String? // user's non-unique name
    @NSManaged var numberOfTopics: Int
    @NSManaged var numberOfPosts: Int
    @NSManaged var bio: String?
    
    
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

