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


class DataKeys {
    
    static var CreatedAt: String {
        return "createdAt"
    }
    
    static var UpdatedAt: String {
        return "updatedAt"
    }
    
    static var Comment: String {
        return "comment"
    }
    
    static var Location: String {
        return "location"
    }
    
    static var LocationName: String {
        return "locationName"
    }
}


class BaseObject: PFObject {
    
    
    //MARK: - Attributes
    
    @NSManaged var comment: String?
        
    var identifier: String? {
        return objectId
    }
    
    
    @NSManaged var locationName: String?
    
    var location: CLLocation? {
        
        get {
            var clvalue: CLLocation?
            if let geoPoint = self[DataKeys.Location] {
                clvalue = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return clvalue
        }
        
        set {
            self[DataKeys.Location] = PFGeoPoint(location: newValue)
        }
    }
    
    
    //MARK: - NSObject Protocol
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let otherObject = object as? BaseObject {
            
            return otherObject.hash == hash
        }
        
        return false
    }
    
    
    override var hash: Int {
        
        if let objectId = objectId {
            return objectId.hash
        }
        
        return super.hash
    }
}
