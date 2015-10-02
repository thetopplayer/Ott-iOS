//
//  FetchLocalTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchLocalTopicsOperation

class FetchLocalTopicsOperation: ParseOperation {

    static let localRadius = Double(20)
    static let pinName = "localTopics"
    
    let location: CLLocation
    let startingAt: NSDate
    let replaceCache: Bool
    let dataSource: ParseOperation.DataSource
    
    typealias CompletionBlock = (topics: [Topic]?, error: NSError?) -> Void
    var completionHandler: CompletionBlock?
    
    init(dataSource: ParseOperation.DataSource, location: CLLocation, startingAt: NSDate, replaceCache: Bool, completion: CompletionBlock?) {
        
        self.dataSource = dataSource
        self.location = location
        self.startingAt = startingAt
        self.replaceCache = replaceCache
        completionHandler = completion
        
        super.init()
    }
    
    var fetchedData: [Topic]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                    
                    if replaceCache {
                        ParseOperation.replaceCache(FetchLocalTopicsOperation.pinName, withObjects: data)
                    }
                    else {
                        ParseOperation.updateCache(FetchLocalTopicsOperation.pinName, withObjects: data)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: FetchLocalTopicsOperation.localRadius)
        query.whereKey(DataKeys.UpdatedAt, greaterThan: startingAt)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(FetchLocalTopicsOperation.pinName)
        }
        
        do {
            fetchedData = (try query.findObjects()) as? [Topic]
            finishWithError(nil)
        }
        catch let error as NSError {
            finishWithError(error)
        }
    }
    
    
    override func finished(errors: [NSError]) {
        
        super.finished(errors)
        
        if let completion = completionHandler {
            completion(topics: fetchedData, error: errors.first)
        }
    }
}



