//
//  FetchCurrentUserAuthoredPostsOperation.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCurrentUserAuthoredPostsOperation: FetchAuthoredPostsOperation {
    
    override class func pinName() -> String? {
        return "authoredPosts"
    }
    
    init(dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        super.init(dataSource: dataSource, user: currentUser(), completion: completion)
    }
   
    
    init(dataSource: ParseOperation.DataSource, updatedSince: NSDate, completion: FetchCompletionBlock?) {
        
        super.init(dataSource: dataSource, user: currentUser(), updatedSince: updatedSince, completion: completion)
    }

    
    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        let query = Post.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        if let startDate = startDate {
            query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: startDate)
        }
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(self.dynamicType.pinName())
        }
        
        do {
            fetchedData = try query.findObjects()
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
    }
}


