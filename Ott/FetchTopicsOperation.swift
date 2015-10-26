//
//  FetchTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/***

Abstract class used to fetch topics

*/

import Foundation


class FetchTopicsOperation: FetchOperation {
    

    /// fully override super in order to check each topic downloaded from the server to see if the current user posted to them
    override func execute() {
        
        guard let query = query else {
            
            assert(false)
            return
        }
        
        if dataSource == .Cache {
            
            if let pinName = self.dynamicType.pinName() {
                query.fromPinWithName(pinName)
            }
        }
        
        do {
            
            if let data = (try query.findObjects()) as? [Topic] {
                
                if dataSource == .Server {
//                    for topic in data {
//                        topic.currentUserDidPostTo = currentUserDidPostToTopic(topic)
//                        topic.currentUserViewedAt = currentUserLastViewedTopic(topic)
//                    }
                }
                fetchedData = data
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
}

