//
//  FetchCurrentUserFolloweesOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import Foundation

class FetchCurrentUserFolloweesOperation: FetchOperation {

    override class func pinName() -> String? {
        return "followees"
    }
    
    
    
    convenience init(dataSource: ParseOperation.DataSource, offset: Int, completion: FetchCompletionBlock?) {
    
        self.init(dataSource: dataSource, offset: offset, updatedSince: nil, completion: completion)
    }
    
    
    init(dataSource: ParseOperation.DataSource, offset: Int, updatedSince: NSDate?, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Follower, equalTo: currentUser())
            if let startDate = updatedSince {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
            }
            
            return query
            }()
        
        super.init(dataSource: dataSource, query: theQuery, completion: completion)
    }
    
    
    override func execute() {
        
        logBackgroundTask()
        super.execute()
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
    }
}

