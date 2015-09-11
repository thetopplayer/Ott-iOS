//
//  FetchLocalTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - Utility Methods

// note that this query is synchronous
// todo:  handle error
func cachedLocalTopics() -> [Topic] {
    
    let query = Topic.query()!
    query.orderByDescending(DataKeys.UpdatedAt)
    query.fromPinWithName(FetchLocalTopicsOperation.cacheName)
    
    var error: NSError?
    if let topics = query.findObjects(&error) as? [Topic] {
        
        print("returning \(topics.count) cached local topics")
        return topics
    }
    
    return []
}



//MARK: - FetchLocalTopicsOperation

class FetchLocalTopicsOperation: ParseOperation {

    static let localRadius = Double(20)
    static let cacheName = "localTopicsCache"
    
    let location: CLLocation
    let updateOnly: Bool
    
    
    init(location: CLLocation, updateOnly: Bool = false) {
        
        self.location = location
        self.updateOnly = updateOnly
        
        super.init()
    }
    
    
    //MARK: - Caching
    
    private func replaceCachedTopics(withTopics newTopics: [Topic]) {
        
        PFObject.unpinAllObjectsWithName(FetchLocalTopicsOperation.cacheName)
        PFObject.pinAll(newTopics, withName: FetchLocalTopicsOperation.cacheName)
    }
    
    
    private func updateCachedTopics(withTopics newTopics: [Topic]) {
        
        let existingObjects = cachedLocalTopics()
        PFObject.unpinAllObjectsWithName(FetchLocalTopicsOperation.cacheName)
        
        let allTopics = Set(newTopics).union(Set(existingObjects))
        PFObject.pinAll(Array(allTopics), withName: FetchLocalTopicsOperation.cacheName)
    }
    
    
    private let lastUpdatedKey = "localTopicsLastUpdated"
    private var defaultFetchSinceDate: NSDate {
        let weekAgo = NSDate().daysFrom(-7)
        return weekAgo
    }
    
    private var lastUpdated: NSDate {
        
        get {
            if updateOnly {
                if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedKey) as? NSDate {
                    return date
                }
             }
            return defaultFetchSinceDate
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedKey)
        }
    }
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: FetchLocalTopicsOperation.localRadius)
        
        let updateDate = updateOnly ? lastUpdated : defaultFetchSinceDate
        query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: updateDate)
        
        var error: NSError?
        let objects = query.findObjects(&error)
        
        if error != nil {
            
            finishWithError(error)
        }
        else if let topics = objects as? [Topic] {
            
            if let mostRecentTopicUpdate = topics.first?.updatedAt {
                
                self.lastUpdated = mostRecentTopicUpdate
                
                if updateOnly {
                    self.updateCachedTopics(withTopics: topics)
                }
                else {
                    self.replaceCachedTopics(withTopics: topics)
                }
            }
        }
        
        finishWithError(nil)
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
    }
}