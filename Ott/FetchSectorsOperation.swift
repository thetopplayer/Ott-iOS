//
//  FetchSectorsOperation.swift
//  Ott
//
//  Created by Max on 10/23/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/*

*/

import UIKit
import MapKit

class FetchSectorsOperation: FetchOperation {

    convenience init(topic: Topic, offset: Int, limit: Int, completion: FetchCompletionBlock?) {
        
        self.init(topic: topic, offset: offset, limit: limit, region: nil, sectorSize: 0, completion: completion)
    }
    
    
    init(topic: Topic, offset: Int, limit: Int, region: MKCoordinateRegion?, sectorSize: Int?, completion: FetchCompletionBlock?) {
        
        let theQuery: PFQuery = {
            
            let query = MapSector.query()!
            query.skip = offset
            query.limit = limit
            query.whereKey(DataKeys.Topic, equalTo: topic)
            query.whereKey(DataKeys.SectorSize, equalTo: sectorSize!)
            return query
        }()
        
        if let region = region {
            
            let latitudeDelta = region.span.latitudeDelta / 2.0
            let longitudeDelta = region.span.longitudeDelta / 2.0
            
            let minLat = region.center.latitude - latitudeDelta
            let minLong = region.center.longitude - longitudeDelta
            let maxLat = region.center.latitude + latitudeDelta
            let maxLong = region.center.longitude + longitudeDelta
            
            theQuery.whereKey(DataKeys.MinLat, greaterThanOrEqualTo: minLat)
            theQuery.whereKey(DataKeys.MaxLat, lessThanOrEqualTo: maxLat)
            theQuery.whereKey(DataKeys.MinLong, greaterThanOrEqualTo: minLong)
            theQuery.whereKey(DataKeys.MaxLong, lessThanOrEqualTo: maxLong)
        }
        
        super.init(dataSource: .Server, query: theQuery, completion: completion)
    }
    
}
