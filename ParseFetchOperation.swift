//
//  ParseFetchOperation.swift
//  Ott
//
//  Created by Max on 10/5/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/**

Abstract base class for all fetch operations.  

*/


import UIKit

class ParseFetchOperation: ParseServerOperation {

    // pin name for caching should be unique to each subclass
    class func pinName() -> String {
        assert(false)
        return ""
    }
    
    
    /// whether data fetched to server is pinned
    var pinFetchedData: Bool
    
    
    let dataSource: ParseOperation.DataSource
    typealias FetchCompletionBlock = (results: [PFObject]?, error: NSError?) -> Void
    
    /// a block exectuted on the main thread when the operation is finished
    var completionHandler: FetchCompletionBlock?
    
    init(dataSource: ParseOperation.DataSource, pinFetchedData: Bool, completion: FetchCompletionBlock?) {
        
        self.dataSource = dataSource
        self.pinFetchedData = pinFetchedData
        completionHandler = completion
        super.init()
    }
    

    var fetchedData: [PFObject]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    if pinFetchedData {
                        ParseOperation.updateCache(self.dynamicType.pinName(), withObjects: data)
                    }
                }
            }
        }
    }

    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completionHandler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(results: self.fetchedData, error: errors.first)
            }
        }
    }
    
}



extension ParseFetchOperation {
    
    class func purgeCache(priorTo: NSDate? = nil) {
        
        if let priorToDate = priorTo {
            
            do {
                let query = PFObject.query()!
                query.whereKey(DataKeys.UpdatedAt, lessThan: priorToDate)
                let objects = try query.findObjects()
                
                try PFObject.unpinAll(objects)
            }
            catch let error as NSError {
                
                NSLog("error purging cache in \(self.dynamicType): \(error)")
            }
        }
        else {
            let _ = try? PFObject.unpinAllObjectsWithName(self.pinName())
        }
    }
}