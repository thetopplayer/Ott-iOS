//
//  SaveOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class SaveOperation: ParseServerOperation {

    typealias SaveCompletionBlock = (savedObject: PFObject?, error: NSError?) -> Void
    var completionHandler: SaveCompletionBlock?
    
    var savedObject: PFObject?
    
    
    init(completion: SaveCompletionBlock?) {
        
        completionHandler = completion
        super.init(timeout: 60)
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {

        logBackgroundTask()
        
        // STUB
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        clearBackgroundTask()
        
        if let completionHandler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(savedObject: self.savedObject, error: errors.first)
            }
        }
    }

}
