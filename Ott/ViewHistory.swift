//
//  ViewHistory.swift
//  Ott
//
//  Created by Max on 10/15/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/*
    This is used locally only to keep track of when the current user last viewed a topic
*/

import UIKit

class ViewHistory: DataObject, PFSubclassing {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "ViewHistory"
    }
    
    
    /** Use this to create */
    class func createForTopic(topic: Topic) -> ViewHistory {
        
        let theView = ViewHistory()
        theView.setTopic(topic)
        return theView
    }
    
    

    //MARK: - Attributes
    
    @NSManaged var viewedAt: NSDate?
    
    func setTopic(topic: Topic) {
        
        self[DataKeys.Topic] = topic
    }
    
    
    var topic: Topic? {
        
        return self[DataKeys.Topic] as? Topic
    }
}
