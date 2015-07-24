//
//  Author.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

class Author_CoreData: BaseObject {

    @NSManaged var isUser: NSNumber
    @NSManaged var numberOfPosts: NSNumber?
    @NSManaged var numberOfTopics: NSNumber?
    @NSManaged var handle: String
    @NSManaged var phone: String?
    @NSManaged var lastContentIdentifier: NSNumber?
    @NSManaged var posts: Set<Post>?
    @NSManaged var topics: Set<Topic>?
    
    
    //MARK: - Lifecycle
    
    static func create(inContext context: NSManagedObjectContext) -> Author {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Author", inManagedObjectContext: context) as! Author
    }
    
    
    override func awakeFromInsert() {
        
        super.awakeFromInsert()
        isUser = false
        handle = "@anonymous"
        name = "Anonymous"
    }
    
    
    
    //MARK: - User
    
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
                        result.lastContentIdentifier = 0
                        result.numberOfPosts = 0
                        result.numberOfTopics = 0
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
    
    
    
    //MARK: - Content
    
    func update(withPost aPost: Post) {
        
        var thePost: Post
        if aPost.managedObjectContext != self.managedObjectContext {
            thePost = self.managedObjectContext?.objectWithID(aPost.objectID) as! Post
        }
        else {
            thePost = aPost
        }
        
        thePost.author = self
        numberOfPosts = (numberOfPosts?.integerValue)! + 1
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
        numberOfTopics = (numberOfTopics?.integerValue)! + 1
    }
    
    
    func newContentIdentifier() -> String {
        
        lastContentIdentifier = (lastContentIdentifier?.integerValue)! + 1
        return handle + ".\(lastContentIdentifier)"
    }
    
    

    
    //MARK: - Uploadable and Downloadable
    
    override func toDictionary() -> [String : String] {
        
        return super.toDictionary()
    }
}

