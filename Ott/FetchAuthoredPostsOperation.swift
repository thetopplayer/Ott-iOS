//
//  FetchAuthoredPostsOperation.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchAuthoredPostsOperation: FetchOperation {
    
    let user: User
    var startDate: NSDate? = nil
    
    init(dataSource: ParseOperation.DataSource, offset: Int, limit: Int, user: User, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, offset: offset, limit: limit, completion: completion)
    }
   
    
    init(dataSource: ParseOperation.DataSource, offset: Int, limit: Int, user: User, updatedSince: NSDate, completion: FetchCompletionBlock?) {
        
        self.user = user
        startDate = updatedSince
        super.init(dataSource: dataSource, offset: offset, limit: limit, completion: completion)
    }

    
    
    //MARK: - Execution
    
    func query() -> PFQuery {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        if let startDate = startDate {
            query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
        }
     
        return query
    }
}


