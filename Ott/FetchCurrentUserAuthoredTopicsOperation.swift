//
//  FetchCurrentUserAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCurrentUserAuthoredTopicsOperation: FetchOperation {
    
    override class func pinName() -> String? {
        return CacheManager.PinNames.UserTopics
    }
    
    
    init(dataSource: ParseOperation.DataSource, offset: Int, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
           
            let query = Topic.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Author, equalTo: currentUser())
            return query
        }()
        
        super.init(dataSource: dataSource, query: theQuery, completion: completion)
    }
    
    
    init(dataSource: ParseOperation.DataSource, offset: Int, updatedSince: NSDate?, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Topic.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Author, equalTo: currentUser())
            if let updatedSince = updatedSince {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: updatedSince)
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

