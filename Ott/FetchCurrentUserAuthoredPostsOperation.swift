//
//  FetchCurrentUserAuthoredPostsOperation.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCurrentUserAuthoredPostsOperation: FetchOperation {
    
    override class func pinName() -> String? {
        return "authoredPosts"
    }
    
    init(dataSource: ParseOperation.DataSource, offset: Int, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Post.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.UpdatedAt)
            query.whereKey(DataKeys.Author, equalTo: currentUser())
            return query
        }()
        
        super.init(dataSource: dataSource, query: theQuery, completion: completion)
    }
    
    
    init(dataSource: ParseOperation.DataSource, offset: Int, updatedSince: NSDate?, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Post.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.UpdatedAt)
            query.whereKey(DataKeys.Author, equalTo: currentUser())
            if let startDate = updatedSince {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
            }
            return query
            }()
        
        super.init(dataSource: dataSource, query: theQuery, completion: completion)
    }


    //MARK: - Execution

    override func execute() {
        
        logBackgroundTask()
        super.execute()
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
    }
}


