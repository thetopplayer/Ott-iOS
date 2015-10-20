//
//  ParseServerOperation.swift
//  Ott
//
//  Created by Max on 10/2/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ParseServerOperation: ParseOperation {

    init(timeout: NSTimeInterval = 60) {
        
        super.init()
        
        let reachabilityCondition: ReachabilityCondition = {
            
            let host = NSURL(string: "https://api.parse.com")
            return ReachabilityCondition(host: host!)
            }()
        
        addCondition(reachabilityCondition)
        
        let timeoutObserver = TimeoutObserver(timeout: timeout)
        addObserver(timeoutObserver)
    }
}
