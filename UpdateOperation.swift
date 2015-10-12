//
//  UpdateOperation.swift
//  Ott
//
//  Created by Max on 10/12/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UpdateOperation: ParseServerOperation {

    let object: PFObject
    
    typealias UpdateCompletionBlock = (updatedObject: PFObject?, error: NSError?) -> Void
    var completionHandler: UpdateCompletionBlock?
    
    
    init(object: PFObject, completion: UpdateCompletionBlock?) {
        
        self.object = object
        completionHandler = completion
        super.init()
    }
    
    
    override func execute() {

        do {
            try object.fetch()
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
                completionHandler(updatedObject: self.object, error: errors.first)
            }
        }
    }
    
    
    override func cancelWithError(error: NSError?) {
        
        super.cancelWithError(error)
        dispatch_async(dispatch_get_main_queue()) {
            
            print("operation canceled: \(self.dynamicType)")
            self.completionHandler?(updatedObject: nil, error: error)
        }
    }
}
