//
//  BaseObject.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/**

Abstract class at root of all data

*/

import UIKit
import MapKit


class BaseObject: PFObject {
    
    
    @NSManaged var comment: String?
        
    var identifier: String? {
        return objectId
    }
    
    
    //MARK: - Location
    
    @NSManaged var locationName: String?
    @NSManaged var geoPoint: PFGeoPoint?
    
    var location: CLLocationCoordinate2D? {
        
        get {
            var coordinate: CLLocationCoordinate2D?
            if let geoPoint = geoPoint {
                coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return coordinate
        }
        
        set {
            if let coordinate = newValue {
                geoPoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
    }
    
    
    
    //MARK: - Archival
    
    func saveNow() {
        
        super.save()
    }
    
    
    func saveWithCompletionBlock(completion: (success: Bool, error: NSError) -> Void) {
        
//        super.saveInBackgroundWithBlock(completion)
    }
    
}
