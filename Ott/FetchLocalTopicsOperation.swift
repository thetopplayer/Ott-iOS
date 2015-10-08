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
    
    
    override func query() -> PFQuery {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: FetchLocalTopicsOperation.localRadius)
        
        if dataSource == ParseOperation.DataSource.Cache {
            query.fromPinWithName(self.dynamicType.pinName())
        }
        
        return query
    }
}



