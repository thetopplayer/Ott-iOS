//
//  Topic.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

class Topic: Base {
    
    @NSManaged var isLocal_: NSNumber
    @NSManaged var isTrending_: NSNumber
    @NSManaged var lastPostLocationName: String?
    @NSManaged var numberOfPosts_: NSNumber
    @NSManaged var userDidPostRating_: NSNumber
    @NSManaged var posts: Set<Post>?
    @NSManaged var author: Author
    
    
    static func create(inContext context: NSManagedObjectContext) -> Topic {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Topic", inManagedObjectContext: context) as! Topic
    }
    
    
    override func awakeFromInsert() {
        
        super.awakeFromInsert()
        userDidPostRating = false
        isLocal = false
        isTrending = false
        numberOfPosts = 0
    }
    
    
    func update(withPost aPost: Post) {
        
        var thePost: Post
        if aPost.managedObjectContext != self.managedObjectContext {
            thePost = self.managedObjectContext?.objectWithID(aPost.objectID) as! Post
        }
        else {
            thePost = aPost
        }
        
        thePost.topic = self
        
        let postRating = thePost.rating!.floatValue
        let updatedNumberOfPosts = numberOfPosts + 1
        if let ar = rating?.floatValue {
            
            var r = ar * Float(numberOfPosts)
            r += postRating
            rating = r / Float(updatedNumberOfPosts)
        }
        else {
            rating = postRating
        }

        numberOfPosts = updatedNumberOfPosts
    }
    
    
    var isLocal: Bool {
        
        get {
            return isLocal_.boolValue
        }
        
        set {
            isLocal_ = newValue
        }
    }
    
    
    var isTrending: Bool {
        
        get {
            return isTrending_.boolValue
        }
        
        set {
            isTrending_ = newValue
        }
    }
    
    
    var numberOfPosts: Int {
        
        get {
            return numberOfPosts_.integerValue
        }
        
        set {
            numberOfPosts_ = newValue
        }
    }
    
    
    var userDidPostRating: Bool {
        
        get {
            return userDidPostRating_.boolValue
        }
        
        set {
            userDidPostRating_ = newValue
        }
    }
    
    


    //MARK: - Uploadable and Downloadable
    
    static let authorIDKey = "authID"
    static let numberOfPostsKey = "post-cnt"
    
    override func toDictionary() -> [String : String] {
        
        var result = super.toDictionary()
        
        result[Base.typeKey] = "Topic"
        result[Topic.authorIDKey] = author.identifier
        return result
    }

}

