//
//  FetchCurrentUserAuthoredTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchCurrentUserAuthoredTopicsOperation: FetchAuthoredTopicsOperation {
    
    override class func pinName() -> String? {
        return "authoredTopics"
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
        
        do {
            
            if let data = (try query().findObjects()) as? [Topic] {
                
                if dataSource == .Server {
                    for topic in data {
                        topic.currentUserDidPostTo = true  // for my own topics, flag as true
                    }
                }
                fetchedData = data
            }
            
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

