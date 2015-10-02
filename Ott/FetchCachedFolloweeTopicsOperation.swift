//
//  FetchFolloweeTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


/**
Note that this fetches topics authored by the followees identifier in the CACHED followers

Fetching from cache returns the cached topics

Fetching from server fetches the topics of the cached followees
*/

class FetchCachedFolloweeTopicsOperation: ParseOperation {
    
    static let pinName = "followeeTopics"
    
    let dataSource: ParseOperation.DataSource
    let startingAt: NSDate
    
    typealias CompletionBlock = (topics: [Topic]?, error: NSError?) -> Void
    var completionHandler: CompletionBlock?
    
    init(dataSource: ParseOperation.DataSource, startingAt: NSDate, completion: CompletionBlock?) {
        
        self.dataSource = dataSource
        self.startingAt = startingAt
        completionHandler = completion
        super.init()
    }
    
    
    var fetchedData: [Topic]? {
        
        didSet {
            
            if dataSource == .Server {
                if let data = fetchedData {
                    ParseOperation.updateCache(FetchCachedFolloweeTopicsOperation.pinName, withObjects: data)
                }
            }
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        if dataSource == .Cache {
            
            let query = Topic.query()!
            query.whereKey("updatedAt", greaterThan: startingAt)
            query.fromPinWithName(FetchCachedFolloweeTopicsOperation.pinName)
            do {
                
                fetchedData = (try query.findObjects()) as? [Topic]
                finishWithError(nil)
            }
            catch let error as NSError {
                finishWithError(error)
            }
        }
        else {
            
            let query = Follow.query()!
            query.fromPinWithName(FetchFolloweesOperation.pinName)
            do {
                
                if let followRelationships = (try query.findObjects()) as? [Follow] {
                    
                    var allTopics = [Topic]()
                    
                    for follow in followRelationships {
                        
                        let topicQuery = Topic.query()!
                        let author = follow[DataKeys.Followee]
                        topicQuery.whereKey(DataKeys.Author, equalTo: author)
                        topicQuery.whereKey("updatedAt", greaterThan: startingAt)
                       
                        if let topics = (try topicQuery.findObjects()) as? [Topic] {
                            
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
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completionHandler = completionHandler {
            completionHandler(topics: self.fetchedData, error: errors.first)
        }
    }
}

