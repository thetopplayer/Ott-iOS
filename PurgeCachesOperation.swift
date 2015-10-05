//
//  PurgeCachesOperation.swift
//  Ott
//
//  Created by Max on 10/2/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PurgeCachesOperation: ParseOperation {

    
    override func execute() {
        
        logBackgroundTask()
        
        PFObject.unpinAllObjectsWithName(FetchAuthoredTopicsOperation.pinName)
        PFObject.unpinAllObjectsWithName(FetchAuthoredPostsOperation.pinName)
        PFObject.unpinAllObjectsWithName(FetchLocalTopicsOperation.pinName)
        PFObject.unpinAllObjectsWithName(FetchCachedFolloweeTopicsOperation.pinName)
        PFObject.unpinAllObjectsWithName(FetchFolloweesOperation.pinName)
    }
    
    
    override func finished(errors: [NSError]) {

        clearBackgroundTask()
    }
}
