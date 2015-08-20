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


class BaseObject: PFObject, CachableImage {
    
    
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
    
    
    //MARK: - CachableImage
    
    // need to do all this (rather than simply declaring a var in the protocol) because of apparent swift 2.0 bugs when trying to set the var in the image code
    
    private var _cachedImage: UIImage?
    var cachedImage: UIImage? {
        return _cachedImage
    }
    
    func setCachedImage(image: UIImage?) {
        _cachedImage = image
    }
}
