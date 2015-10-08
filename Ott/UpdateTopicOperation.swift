//
//  UpdateTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import Foundation


class UpdateTopicOperation: FetchTopicsOperation {

    
    let topic: Topic
    
    init(topic: Topic, completion: FetchCompletionBlock?) {
        
        self.topic = topic
        super.init(dataSource: .Server, completion: completion)
    }
    
    
    struct Notifications {
        
        static let DidUpdate = "didUpdateTopic"
        static let UpdateDidFail = "topicUpdateDidFail"
        static let TopicKey = "topic"
        static let ErrorKey = "error"
    }
    
    

    
    //MARK: - Execution
    
    override func execute() {
        
        do {
            
            let topicPinName = topic.pinName
            
            try topic.fetch()
            
            if let topicPinName = topicPinName {
                topic.pinName = topicPinName
            }
            topic.currentUserDidPostTo = currentUserDidPostToTopic(topic)
            
            fetchedData = [topic]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [UpdateTopicOperation.Notifications.TopicKey: self.topic]
                NSNotificationCenter.defaultCenter().postNotificationName(UpdateTopicOperation.Notifications.DidUpdate,
                    object: self,
                    userInfo: userinfo)
            }

        }
    }
}
