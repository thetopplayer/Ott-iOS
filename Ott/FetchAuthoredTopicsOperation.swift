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
    
    static private let pinName = "authoredTopics"
    
    let user: User
    
    init(dataSource: ParseOperation.DataSource, user: User, completion: FetchCompletionBlock?) {
        
        self.user = user
        super.init(dataSource: dataSource, completion: completion)
    }
    
    
    var fetchedData: [Topic]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    ParseOperation.updateCache(FetchAuthoredTopicsOperation.pinName, withObjects: data)
                }
            }
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Author, equalTo: user)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(FetchAuthoredTopicsOperation.pinName)
        }
        
        do {
            
            self.fetchedData = (try query.findObjects()) as? [Topic]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }

}

