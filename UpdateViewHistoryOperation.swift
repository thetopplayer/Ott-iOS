//
//  UpdateViewHistoryOperation.swift
//  Ott
//
//  Created by Max on 9/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UpdateViewHistoryOperation: ParseOperation {

    class func pinName() -> String {
        return "viewHistory"
    }
    

    let topic: Topic
    let viewedAt: NSDate
    
    init(topic: Topic, viewedAt: NSDate) {
        
        self.topic = topic
        self.viewedAt = viewedAt
        super.init()
    }
    
    //MARK: - Execution
    
    override func execute() {
        
        logBackgroundTask()
        
        do {
            
            // if the record exists, update it, else create a new one
            
            let query = ViewHistory.query()!
            query.whereKey(DataKeys.Topic, equalTo: topic)
            query.fromPinWithName(self.dynamicType.pinName())
            query.limit = 1
            
            let results = try query.findObjects()
            if let existingHistory = results.first as? ViewHistory {
                
                existingHistory.viewedAt = viewedAt
                try existingHistory.pinWithName(self.dynamicType.pinName())
            }
            else {
                
                let vh = ViewHistory.createForTopic(topic)
                vh.viewedAt = viewedAt
                try vh.pinWithName(self.dynamicType.pinName())
            }

            
            // now update the topic
            topic.currentUserViewedAt = viewedAt
            if let topicPin = topic.pinName {
                try topic.pinWithName(topicPin)
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        clearBackgroundTask()
    }

}
