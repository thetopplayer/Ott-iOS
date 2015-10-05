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
    static private let pinName = "parseFetchOperationDefaultPin"
    
    let dataSource: ParseOperation.DataSource
    typealias FetchCompletionBlock = (results: [PFObject]?, error: NSError?) -> Void
    var completionHandler: FetchCompletionBlock?
    
    init(dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        self.dataSource = dataSource
        completionHandler = completion
        super.init()
    }
    

    var fetchedData: [PFObject]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    ParseOperation.updateCache(self.dynamicType.pinName, withObjects: data)
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
    
    static func purgeCache(sinceDate: NSDate? = nil) {
        
        if let sinceDate = sinceDate {
            
        }
        else {
            
            let _ = try? PFObject.unpinAllObjectsWithName(self.pinName)
        }
    }
}