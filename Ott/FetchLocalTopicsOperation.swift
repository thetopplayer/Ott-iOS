//
//  FetchLocalTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchLocalTopicsOperation: FetchTopicsOperation {

    override class func pinName() -> String? {
        return "localTopics"
    }

    override func execute() {
        
        // purge cache before fetching from server
        if dataSource == .Server {
            
            if query!.skip == 0 {
                self.dynamicType.purgeCache()
            }
        }
        
        super.execute()
    }
}



