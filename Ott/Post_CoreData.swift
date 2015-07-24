//
//  Post_CoreData.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation
import CoreData

class Post_CoreData: Base_CoreData {

    @NSManaged var topic: Topic?
    @NSManaged var author: Author
    
    
    static func create(inContext context: NSManagedObjectContext) -> Post {
        
        return NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context) as! Post
    }


    
    //MARK: - Uploadable and Downloadable
    
    static let authorIDKey = "authID"
    
    override func toDictionary() -> [String : String] {
        
        var result = super.toDictionary()
        
        result[BaseObject.typeKey] = "Post"
        result[Post.authorIDKey] = author.identifier
        return result
    }

}
