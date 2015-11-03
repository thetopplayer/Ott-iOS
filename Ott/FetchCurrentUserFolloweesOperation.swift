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
        return CacheManager.PinNames.FollowedByUser
    }
    
    
    init(dataSource: ParseOperation.DataSource, updatedSince: NSDate?, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.whereKey(DataKeys.Follower, equalTo: currentUser())
            if let updatedSince = updatedSince {
                query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: updatedSince)
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

