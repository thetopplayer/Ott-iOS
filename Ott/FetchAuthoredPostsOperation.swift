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
    
    init(dataSource: ParseOperation.DataSource, user: User, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, completion: completion)
    }
   
    
    init(dataSource: ParseOperation.DataSource, user: User, updatedSince: NSDate, completion: FetchCompletionBlock?) {
        
        self.user = user
        startDate = updatedSince
        super.init(dataSource: dataSource, completion: completion)
    }

    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        if let startDate = startDate {
            query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
        }

        do {
            fetchedData = (try query.findObjects())
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}


