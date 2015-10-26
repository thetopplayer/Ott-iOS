//
//  MaintenanceQueue.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class MaintenanceQueue: OperationQueue {
    
    static let sharedInstance: MaintenanceQueue = {
       
        let queue = MaintenanceQueue()
        queue.qualityOfService = .Background
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
