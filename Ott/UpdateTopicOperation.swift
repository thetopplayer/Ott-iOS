//
//  UpdateTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import Foundation


class UpdateTopicOperation: UpdateOperation {

    init(topic: Topic, completion: UpdateCompletionBlock?) {
        
        super.init(object: topic, completion: completion)
    }
    
    
    struct Notifications {
        
        static let DidUpdate = "didUpdateTopic"
        static let UpdateDidFail = "topicUpdateDidFail"
        static let TopicKey = "topic"
        static let ErrorKey = "error"
    }
    
    

    
    //MARK: - Execution
    
    // fully override super
    override func execute() {
        
        guard let topic = object as? Topic else {
            assert(false)
            return
        }
        
        do {
            
            let topicPinName = topic.pinName
            
            try topic.fetch()
            
//            topic.currentUserDidPostTo = currentUserDidPostToTopic(topic)
            
            if let topicPinName = topicPinName {
                topic.pinName = topicPinName
                try topic.pinWithName(topicPinName)
            }

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
                
                let userinfo: [NSObject: AnyObject] = [UpdateTopicOperation.Notifications.TopicKey: self.object]
                NSNotificationCenter.defaultCenter().postNotificationName(UpdateTopicOperation.Notifications.DidUpdate,
                    object: self,
                    userInfo: userinfo)
            }

        }
    }
}
