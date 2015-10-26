//
//  FetchQueue.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FetchQueue: OperationQueue {

    static let sharedInstance: FetchQueue = {
        
        let queue = FetchQueue()
        queue.qualityOfService = .Utility
        return queue
    }()
}
