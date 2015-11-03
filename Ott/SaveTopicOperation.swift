//
//  SaveTopicOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class SaveTopicOperation: SaveOperation {

    let topic: Topic
    
    init(topic: Topic, completion: SaveCompletionBlock?) {
        
        self.topic = topic
        super.init(completion: completion)
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {

        logBackgroundTask()
        
        do {
            
            try topic.save()
            try topic.fetchIfNeeded()
            try topic.pinWithName(CacheManager.PinNames.UserTopics)
            
            savedObject = topic
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }

}
