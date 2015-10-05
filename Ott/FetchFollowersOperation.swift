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
    
    static private let pinName = "currentUserFollowers"
    
    var fetchedData: [Follow]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    ParseOperation.updateCache(FetchFollowersOperation.pinName, withObjects: data)
                }
            }
        }
    }
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Follow.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Followee, equalTo: currentUser())
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(FetchFollowersOperation.pinName)
        }
        
        do {
            
            fetchedData = (try query.findObjects()) as? [Follow]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

