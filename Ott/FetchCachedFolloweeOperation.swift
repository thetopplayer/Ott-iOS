//
//  FetchCachedFolloweeOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCachedFolloweeOperation: ParseOperation {
    
    let followeeHandle: String
    
    typealias CompletionBlock = (relationship: Follow?, error: NSError?) -> Void
    var completionHandler: CompletionBlock?
    
    init(followeeHandle: String, completion: CompletionBlock?) {
        
        self.followeeHandle = followeeHandle
        completionHandler = completion
        super.init()
    }
    
    var fetchedData: Follow? = nil
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Follow.query()!
        query.whereKey(DataKeys.FolloweeHandle, equalTo: followeeHandle)
        query.fromPinWithName(FetchFolloweesOperation.pinName)
        query.limit = 1
        
        do {
            
            if let followRelationships = (try query.findObjects()) as? [Follow] {
                
                fetchedData = followRelationships.first
                finishWithError(nil)
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completionHandler = completionHandler {
            completionHandler(relationship: self.fetchedData, error: errors.first)
        }
    }
}

