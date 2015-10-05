//
//  FetchFollowersOperation.swift
//  Ott
//
//  Created by Max on 10/2/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchFollowersOperation

class FetchFollowersOperation: ParseFetchOperation {
    
    override class func pinName() -> String {
        return "currentUserFollowers"
    }
    
    
    init (dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        super.init(dataSource: dataSource, pinFetchedData: true, completion: completion)
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Follow.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Followee, equalTo: currentUser())
        
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
}

