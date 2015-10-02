//
//  FetchFolloweesOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchFolloweesOperation

class FetchFolloweesOperation: ParseOperation {

    static let pinName = "currentUserFollowees"
    
    typealias CompletionBlock = (relationships: [Follow]?, error: NSError?) -> Void
    var completionHandler: CompletionBlock?
    
    var fetchedData: [Follow]? {
        
        didSet {
            if let data = fetchedData {
                ParseOperation.updateCache(FetchFolloweesOperation.pinName, withObjects: data)
            }
        }
    }
    
    
    init(completion: CompletionBlock?) {
        
        completionHandler = completion
        super.init()
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Follow.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        query.whereKey(DataKeys.Follower, equalTo: currentUser())
        
        do {
            
            let objects = try query.findObjects()
            fetchedData = objects as? [Follow]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    

    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completionHandler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(relationships: self.fetchedData, error: errors.first)
            }
        }
    }
}

