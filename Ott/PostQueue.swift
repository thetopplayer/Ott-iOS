//
//  PostQueue.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PostQueue: OperationQueue {

    static let sharedInstance: PostQueue = {
        
        let queue = PostQueue()
        queue.qualityOfService = .Background
        return queue
    }()
}
