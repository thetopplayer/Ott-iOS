//
//  FetchAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchAuthoredTopicsOperation

class FetchAuthoredTopicsOperation: FetchTopicsOperation {
    
    let user: User
    var startDate: NSDate? = nil
    
    init(dataSource: ParseOperation.DataSource, query: PFQuery, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, offset: offset, limit: limit, completion: completion)
    }
    
    
    init(dataSource: ParseOperation.DataSource, query: PFQuery, updatedSince: NSDate, completion: FetchCompletionBlock?) {
        
        self.user = user
        startDate = updatedSince
        super.init(dataSource: dataSource, offset: offset, limit: limit, completion: completion)
    }
    

//    override func query() -> PFQuery {
//        
//        let query = Topic.query()!
//        query.orderByDescending(DataKeys.CreatedAt)
//        query.whereKey(DataKeys.Author, equalTo: user)
//        if let startDate = startDate {
//            query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
//        }
//        
//        if dataSource == .Cache {
//            query.fromPinWithName(self.dynamicType.pinName())
//        }
//        
//        return query
//    }
}

