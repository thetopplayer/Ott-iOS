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
            return "numTopics"
        }
        
        static var NumberOfPosts: String {
            return "numPosts"
        }
    }
    
    
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
    
    private var documentsDirectory: String = {
        
        do {
            
            let documentURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
            return documentURL.path!
        }
        catch {
            print("error getting document directory")
            return ""
        }
    }()
    
    
    private var authoredTopicArchivePath: String {
        
        return documentsDirectory + "/authoredTopics.ott"
    }
    
    
    private func authoredTopicIDs() -> [String] {
        
        if let archive = NSArray(contentsOfFile: authoredTopicArchivePath) {
            return archive as! [String]
        }
        
        return Array<String>()
    }
    
    
    private func archiveAuthoredTopicIDs(topicIDs: NSArray) {
        
        topicIDs.writeToFile(authoredTopicArchivePath, atomically: true)
    }
    
    
    func archiveAuthoredTopicID(topicID: String) {
        
        let topicIDs = NSMutableSet()
        topicIDs.unionSet(NSSet(array: authoredTopicIDs()) as! Set<String>)
        topicIDs.addObject(topicID)
        archiveAuthoredTopicIDs(topicIDs.allObjects)
    }
    
    
    func didAuthorTopic(topic: Topic) -> Bool {
        
        if let topicID = topic.objectId {
            
            return authoredTopicIDs().contains(topicID)
        }
        
        return false
    }
    
    
    private var postedTopicArchivePath: String {
        
        return documentsDirectory + "/postedTopics.ott"
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
}

