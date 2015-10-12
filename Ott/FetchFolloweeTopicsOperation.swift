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

class FetchFolloweeTopicsOperation: FetchTopicsOperation {
    
    override class func pinName() -> String? {
        return "followeeTopics"
    }
    
    let offset: Int
    var sinceDate: NSDate?
    
    init(dataSource: ParseOperation.DataSource, offset: Int, sinceDate: NSDate?, completion: FetchCompletionBlock?) {
        
        self.offset = offset
        self.sinceDate = sinceDate
        super.init(dataSource: dataSource, query: nil, completion: completion)
    }




    //MARK: - Execution

    override func execute() {
        
        if dataSource == .Cache {
            
            // return cached topics
            
            let query = Topic.query()!
            query.skip = offset
            query.orderByDescending(DataKeys.UpdatedAt)
            if let sinceDate = sinceDate {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: sinceDate)
            }
            
            super.execute()
        }
        else {
            
            fetchTopicsFromServer()
        }
    }
    
    
    // this is done using the user's currently cached followees
    // the fetch from each followee is limited by the fetchSince date and the default
    // fetch limit.  offset defines the offset within the followees
    
    private func fetchTopicsFromServer() {
        
        do {
            
            let query = Follow.query()!
            query.skip = offset
            query.fromPinWithName(FetchCurrentUserFolloweesOperation.pinName())
            
            if let followRelationships = try query.findObjects() as? [Follow] {
                
                var allTopics = [Topic]()
                
                for follow in followRelationships {
                    
                    let topicQuery = Topic.query()!
                    let author = follow[DataKeys.Followee]
                    topicQuery.whereKey(DataKeys.Author, equalTo: author)
                    
                    let fetchSince = sinceDate != nil ? sinceDate : NSDate().daysFrom(-7)
                    topicQuery.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: fetchSince!)
                    
                    if let data = (try topicQuery.findObjects()) as? [Topic] {
                        allTopics += data
                    }
                }
                
                sortByUpdatedAt(allTopics)
                fetchedData = allTopics
            }
            
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
}

