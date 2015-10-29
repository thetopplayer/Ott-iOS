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
    
    
    //MARK: - Execution
    
    override func execute() {

        do {
            
            try post.save()
            try post.fetchIfNeeded()
            try post.pinWithName(FetchCurrentUserAuthoredPostsOperation.pinName()!)
            
            uploadedObject = post
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
