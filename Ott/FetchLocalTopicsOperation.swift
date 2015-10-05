//
//  FetchLocalTopicsOperation.swift
//  Ott
//
//  Created by Max on 9/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


//MARK: - FetchLocalTopicsOperation

class FetchLocalTopicsOperation: ParseFetchOperation {

    static private let pinName = "localTopics"

    static let localRadius = Double(20)
    let location: CLLocation
    
    init(dataSource: ParseOperation.DataSource, location: CLLocation, completion: FetchCompletionBlock?) {
        
        self.location = location
        super.init(dataSource: dataSource, completion: completion)
    }
    
    var fetchedData: [Topic]? {
        
        didSet {
            
            if let data = fetchedData {
                
                if dataSource == .Server {
                     ParseOperation.updateCache(FetchLocalTopicsOperation.pinName, withObjects: data)
                }
            }
        }
    }
    
    
    
    //MARK: - Execution
    
    override func execute() {
        
        let query = Topic.query()!
        query.orderByDescending(DataKeys.CreatedAt)
        query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: FetchLocalTopicsOperation.localRadius)
        
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
}



