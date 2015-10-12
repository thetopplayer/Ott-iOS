//
//  FetchCurrentUserFollowersOperation.swift
//  Ott
//
//  Created by Max on 10/2/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCurrentUserFollowersOperation: FetchOperation {
    
    override class func pinName() -> String {
        return "followers"
    }
    
    
    init(dataSource: ParseOperation.DataSource, offset: Int, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.UpdatedAt)
            query.whereKey(DataKeys.Follower, equalTo: currentUser())
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

