//
//  FetchFolloweesOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/**

either fetch all followees of the currentUser, or a singleFollowee by his handle
*/


import Foundation


//MARK: - FetchFolloweesOperation

class FetchFolloweesOperation: ParseFetchOperation {

    override class func pinName() -> String {
        return "currentUserFollowees"
    }
    
    init(dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        super.init(dataSource: dataSource, pinFetchedData: true, completion: completion)
    }
    
    
    var followeeHandle: String?
    
    init(followeeHandle: String, completion: FetchCompletionBlock?) {
        
        self.followeeHandle = followeeHandle
        super.init(dataSource: .Server, pinFetchedData: false, completion: completion)
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Follow.query()!
        query.whereKey(DataKeys.Follower, equalTo: currentUser())
        query.orderByDescending(DataKeys.UpdatedAt)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(FetchFolloweesOperation.pinName())
        }
        
        if let followeeHandle = followeeHandle {
            query.whereKey(DataKeys.FolloweeHandle, equalTo: followeeHandle)
            query.limit = 1
        }
        
        do {
            
            fetchedData = try query.findObjects()
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

