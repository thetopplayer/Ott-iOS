//
//  FetchAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchAuthoredTopicsOperation

class FetchAuthoredTopicsOperation: ParseFetchOperation {
    
    override class func pinName() -> String {
        return "authoredTopics"
    }
    
    let user: User
    
    init(dataSource: ParseOperation.DataSource, user: User, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, pinFetchedData: true, completion: completion)
    }
    
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(self.dynamicType.pinName())
        }
        
        do {
            
            self.fetchedData = (try query.findObjects())
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }

}

