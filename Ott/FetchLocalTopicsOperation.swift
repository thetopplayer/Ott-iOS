//
//  FetchLocalTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


class FetchLocalTopicsOperation: FetchTopicsOperation {

    override class func pinName() -> String? {
        return "localTopics"
    }

    static let localRadius = Double(20)
    let location: CLLocation
    
    init(dataSource: ParseOperation.DataSource, location: CLLocation, completion: FetchCompletionBlock?) {
        
        self.location = location
        super.init(dataSource: dataSource, completion: completion)
    }
    
    // ignore location if simply fetching from cache
    override func query() -> PFQuery {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.UpdatedAt)
        
        if dataSource == .Cache {
            query.fromPinWithName(self.dynamicType.pinName())
        }
        else {
            
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: FetchLocalTopicsOperation.localRadius)
        }
        
        return query
    }
    
    
    override func execute() {
        
        // purge cache before fetching from server
        if dataSource == .Server {
            self.dynamicType.purgeCache()
        }
        
        super.execute()
    }
}



