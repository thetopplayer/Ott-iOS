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
    
    @NSManaged var isLocal: NSNumber
    @NSManaged var isTrending: NSNumber
    @NSManaged var lastPostLocationName: String?
    @NSManaged var numberOfPosts: NSNumber
    @NSManaged var userDidPostRating: NSNumber
    @NSManaged var posts: NSSet?
    @NSManaged var author: Author
    
    
    static func create(inContext context: NSManagedObjectContext) -> Topic {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Topic", inManagedObjectContext: context) as! Topic
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
        let updatedNumberOfPosts = numberOfPosts.integerValue + 1
        if let ar = rating?.floatValue {
            
            var r = ar * numberOfPosts.floatValue
            r += postRating
            rating = r / Float(updatedNumberOfPosts)
        }
        else {
            rating = postRating
        }

        numberOfPosts = updatedNumberOfPosts
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

