//
//  Post.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation
import CoreData

class Post: Base {

    @NSManaged var topic: Topic?
    @NSManaged var author: Author
    
    
    static func create(inContext context: NSManagedObjectContext) -> Post {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context) as! Post
    }


    
    //MARK: - Uploadable and Downloadable
    
    static let authorIDKey = "authID"
    
    override func toDictionary() -> [String : String] {
        
        var result = super.toDictionary()
        
        result[Base.typeKey] = "Post"
        result[Post.authorIDKey] = author.identifier
        return result
    }

}
