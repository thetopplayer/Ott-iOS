//
//  Author.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

class Author: Base {

    @NSManaged var isUser: NSNumber?
    @NSManaged var numberOfPosts: NSNumber
    @NSManaged var numberOfTopics: NSNumber
    @NSManaged var handle: String?
    @NSManaged var numberOfReceivedPosts: NSNumber
    @NSManaged var avatar: NSData?
    @NSManaged var posts: NSSet?
    @NSManaged var topics: NSSet?
    
    
    static func create(inContext context: NSManagedObjectContext) -> Author {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Author", inManagedObjectContext: context) as! Author
    }
    
    /**
        Returns Author record for user, creating new one if it does not exist
    */
    static func user(inContext context: NSManagedObjectContext) -> Author {
        
        var user:Author?
        
        func createUser(inContext context: NSManagedObjectContext) -> Author {
            
            var createdUser: Author?
            context.performBlockAndWait { () -> Void in
                
                if let result = NSEntityDescription.insertNewObjectForEntityForName("Author",
                    inManagedObjectContext: context) as? Author {
                        
                        result.isUser = true
                        createdUser = result
                }
            }
            
            return createdUser!
        }
        
        context.performBlockAndWait { () -> Void in
            
            let fetchRequest = NSFetchRequest(entityName: "Author")
            fetchRequest.predicate = NSPredicate(format: "isUser = true")
            
            do {
                
                let results = try context.executeFetchRequest(fetchRequest)
                if results.count > 0 {
                    user = results.last as? Author
                }
                else {
                    user = createUser(inContext: context)
                 }
            } catch {
                
                abort()
            }
            
        }
        
        return user!
    }
    
    
    func update(withPost aPost: Post) {
        
        var thePost: Post
        if aPost.managedObjectContext != self.managedObjectContext {
            thePost = self.managedObjectContext?.objectWithID(aPost.objectID) as! Post
        }
        else {
            thePost = aPost
        }
        
        thePost.author = self
        numberOfPosts = numberOfPosts.integerValue + 1
    }
    
    
    func update(withTopic aTopic: Topic) {
        
        var theTopic: Topic
        if aTopic.managedObjectContext != self.managedObjectContext {
            theTopic = self.managedObjectContext?.objectWithID(aTopic.objectID) as! Topic
        }
        else {
            theTopic = aTopic
        }
        
        theTopic.author = self
        numberOfTopics = numberOfTopics.integerValue + 1
    }
    
    
    
    
    //MARK: - Uploadable and Downloadable
    
    override func toDictionary() -> [String : String] {
        
        return super.toDictionary()
    }
}

