//
//  FetchAuthoredPostsOperation.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchAuthoredTopicsOperation

class FetchAuthoredPostsOperation: ParseFetchOperation {
    
    static private let pinName = "authoredPosts"
    
    let user: User
    
    init(dataSource: ParseOperation.DataSource, user: User, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, completion: completion)
    }
    
    
    var fetchedData: [Post]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    ParseOperation.updateCache(FetchAuthoredPostsOperation.pinName, withObjects: data)
                }
            }
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(FetchAuthoredPostsOperation.pinName)
        }
        
        do {
            
            self.fetchedData = (try query.findObjects()) as? [Post]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}


