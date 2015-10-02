//
//  FetchAuthoredPostsOperation.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchAuthoredTopicsOperation

class FetchAuthoredPostsOperation: ParseOperation {
    
    let user: User
    
    typealias CompletionBlock = (posts: [Post]?, error: NSError?) -> Void
    var completionHandler: CompletionBlock?
    
    var fetchedData: [Post]?
    
    init(user: User, completion: CompletionBlock?) {
        
        self.user = user
        completionHandler = completion
        super.init()
    }
    
    

    //MARK: - Execution

    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        do {
            
            let objects = try query.findObjects()
            self.fetchedData = objects as? [Post]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completionHandler = completionHandler {
            completionHandler(posts: fetchedData, error: errors.first)
        }
        
    }
}


