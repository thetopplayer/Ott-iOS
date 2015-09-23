//
//  FetchTopicOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation



//MARK: - FetchTopicOperation

class FetchTopicOperation: ParseOperation {

    let topic: Topic
    
    init(topic: Topic) {
        
        self.topic = topic
        super.init()
    }
    
    
    struct Notifications {
        
        static let DidFetch = "didFetchTopic"
        static let FetchDidFail = "topicFetchDidFail"
        static let TopicKey = "topic"
        static let ErrorKey = "error"
    }

    
    //MARK: - Execution
    
    override func execute() {
        
        do {
            try topic.fetch()
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        if errors.count == 0 {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let userinfo: [NSObject: AnyObject] = [FetchTopicOperation.Notifications.TopicKey: self.topic]
                NSNotificationCenter.defaultCenter().postNotificationName(FetchTopicOperation.Notifications.DidFetch,
                    object: self,
                    userInfo: userinfo)
            }

        }
        else if UIApplication.sharedApplication().applicationState == .Active {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                guard let controller = topmostViewController() else {
                    print("ERROR fetching topic \(self.topic)")
                    return
                }
                
                controller.presentOKAlertWithError(errors.first!)
            }
            
        }
    }
}
