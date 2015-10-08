//
//  FetchOperation.swift
//  Ott
//
//  Created by Max on 10/5/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/**

Abstract base class for all fetch operations.  

*/


import UIKit

class FetchOperation: ParseServerOperation {

    // pin name for caching should be unique to each subclass.  if no pin name is provided, the data is not pinned
    class func pinName() -> String? {
        return nil
    }
    
    
    let dataSource: ParseOperation.DataSource
    typealias FetchCompletionBlock = (results: [PFObject]?, error: NSError?) -> Void
    
    /// a block exectuted on the main thread when the operation is finished
    var completionHandler: FetchCompletionBlock?
    
    init(dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        self.dataSource = dataSource
        completionHandler = completion
        super.init()
    }
    

    /// if a pin name is provided, pin the data after setting.  if the data is made up of DataObjects, then also store the pinName in each.
    var fetchedData: [PFObject]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    
                    if let pinName = self.dynamicType.pinName() {
                        
                        for object in data {
                            if let fetchedDataObject = object as? DataObject {
                                fetchedDataObject.pinName = pinName
                            }
                        }
                        
                        ParseOperation.updateCache(pinName, withObjects: data)
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



extension FetchOperation {
    
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
            if let pinName = pinName() {
                let _ = try? PFObject.unpinAllObjectsWithName(pinName)
            }
        }
    }
}