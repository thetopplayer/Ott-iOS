//
//  FetchFolloweeTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


/**
Note that this fetches topics authored by the followees identifier in the CACHED followees

Fetching from cache returns the cached topics

Fetching from server fetches the topics of the cached followees
*/

class FetchCachedFolloweeTopicsOperation: ParseFetchOperation {
    
    override class func pinName() -> String? {
        return "followeeTopics"
    }
    
    
    override init(dataSource: ParseOperation.DataSource, completion: FetchCompletionBlock?) {
        
        super.init(dataSource: dataSource, completion: completion)
    }
    
    
    //MARK: - Execution
    
    override func execute() {
        
        if dataSource == .Cache {
            
            let query = Topic.query()!
            query.fromPinWithName(self.dynamicType.pinName())
            do {
                
                fetchedData = try query.findObjects()
                finishWithError(nil)
            }
            catch let error as NSError {
                finishWithError(error)
            }
        }
        else {
            
            let query = Follow.query()!
            query.fromPinWithName(FetchCurrentUserFolloweesOperation.pinName())
            do {
                
                if let followRelationships = try query.findObjects() as? [Follow] {
                    
                    var allTopics = [Topic]()
                    
                    for follow in followRelationships {
                        
                        let topicQuery = Topic.query()!
                        let author = follow[DataKeys.Followee]
                        topicQuery.whereKey(DataKeys.Author, equalTo: author)
                       
                        if let topics = try topicQuery.findObjects() as? [Topic] {
                            allTopics += topics
                        }
                    }
                    
                    if allTopics.count > 0 {
                        self.fetchedData = allTopics                        
                    }
                    finishWithError(nil)
                }
                
                finishWithError(nil)
            }
            catch let error as NSError {
                finishWithError(error)
            }
        }
    }
    
}

