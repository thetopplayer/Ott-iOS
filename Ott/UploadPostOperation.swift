//
//  UploadPostOperation.swift
//  Ott
//
//  Created by Max on 9/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UploadPostOperation: UploadOperation {

    let post: Post
    let topic: Topic
    
    init(post: Post, topic: Topic, completion: UploadCompletionBlock?) {
        
        self.post = post
        self.topic = topic
        super.init(completion: completion)
    }
    
    
//    struct Notifications {
//        
//        static let DidUpload = "didUploadPost"
//        static let UploadDidFail = "postUploadDidFail"
//        static let PostKey = "post"
//        static let ErrorKey = "error"
//    }
    
    
    //MARK: - Execution
    
    override func execute() {

        do {
            
//            let topicPinName = post.topic!.pinName
            
//            let params = ["post": post, "topic": topic]
            
//            let results = try PFCloud.callFunction("savePostForTopic", withParameters: params)
//            print("upload results = \(results)")
            
            try post.save()
            try post.fetchIfNeeded()
            try post.pinWithName(FetchCurrentUserAuthoredPostsOperation.pinName()!)
            
            uploadedObject = post
            
//            // update and re-pin the post's topic
//            let topic = post.topic!
//            try post.topic!.fetchIfNeeded()
//            
//            topic.currentUserDidPostTo = true
//            if let topicPinName = topicPinName {
//                topic.pinName = topicPinName
//                try topic.pinWithName(topicPinName)
//            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }        
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
//        if errors.count == 0 {
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                
//                let userinfo: [NSObject: AnyObject] = [UploadPostOperation.Notifications.PostKey: self.post]
//                NSNotificationCenter.defaultCenter().postNotificationName(UploadPostOperation.Notifications.DidUpload,
//                    object: self,
//                    userInfo: userinfo)
//            }
//        }
//        else if UIApplication.sharedApplication().applicationState == .Active {
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                
//                guard let controller = topmostViewController() else {
//                    print("ERROR uploading post \(self.post)")
//                    return
//                }
//                
//                controller.presentOKAlertWithError(errors.first!, messagePreamble: "Could not upload post:")
//            }
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                
//                let userinfo: [NSObject: AnyObject] = [UploadPostOperation.Notifications.ErrorKey: errors.first!]
//                NSNotificationCenter.defaultCenter().postNotificationName(UploadPostOperation.Notifications.UploadDidFail,
//                    object: self,
//                    userInfo: userinfo)
//            }
//        }
    }

}
