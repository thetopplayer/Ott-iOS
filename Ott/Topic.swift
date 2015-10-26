//
//  Topic.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit


extension DataKeys {
    
    static var AverageRating: String {
        return "averageRating"
    }
    
    static var Bounds: String {
        return "bounds"
    }
    
    static var Posts: String {
        return "posts"
    }
    
    static var Name: String {
        return "name"
    }
    
    static var AllCapsName: String {
        return "acName"
    }
    
    static var LastPostLocation: String {
        return "lastPostLocation"
    }
    
    static var LastPostLocationName: String {
        return "lastPostLocationName"
    }
    
    static var CurrentUserDidPostTo: String {
        return "currentUserDidPostTo"
    }
}


class Topic: AuthoredObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "Topic"
    }
    
    
    /** Use this to create */
    class func create() -> Topic {
        
        let topic = Topic()
        topic.numberOfPosts = 0
        topic.averageRating = 0
        topic.currentUserDidPostTo = true
        return topic
    }
    
    
    //MARK: - Attributes
    
    static var maximumNameLength: Int = 100
    
    var name: String? {
        
        set {
            
            if let theName = newValue {
                
                let trimmedName = theName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                let truncatedName = trimmedName.length > self.dynamicType.maximumNameLength ? trimmedName.substring(startingAt: 0, length: self.dynamicType.maximumNameLength) : trimmedName
                
                self[DataKeys.Name] = truncatedName
                self[DataKeys.AllCapsName] = truncatedName.uppercaseString
            }
        }
        
        get {
            return self[DataKeys.Name] as? String
        }
    }
    
    @NSManaged var numberOfPosts: Int
    @NSManaged var averageRating: Float
    @NSManaged var bounds: [Double]?
    @NSManaged var lastPostLocationName: String?
    @NSManaged var lastPostDate: NSDate?

    // used internally
    var currentUserDidPostTo: Bool? {
        
        get {
            return self[DataKeys.CurrentUserDidPostTo] as? Bool
        }
        
        set {
            self[DataKeys.CurrentUserDidPostTo] = newValue
        }
    }
    
    
    // because Parse only allows one geoPoint per record, use this to store
    // additional location information
//    struct LocationCoordinates {
//        
//        let _myLocation: CLLocation
//        
//        init(withLocation: CLLocation) {
//            _myLocation = withLocation
//        }
//        
//        init(withCoordinateArray coordinateArray: [CLLocationDegrees]) {
//            _myLocation = CLLocation(latitude: coordinateArray.first!, longitude: coordinateArray.last!)
//        }
//        
//        func toArray() -> [CLLocationDegrees] {
//            return [location().coordinate.latitude, location().coordinate.longitude]
//        }
//        
//        func location() -> CLLocation {
//            return _myLocation
//        }
//    }
//
//    
//    var lastPostLocation: CLLocation? {
//        
//        get {
//            var clvalue: CLLocation?
//            if let coordinateArray = self[DataKeys.LastPostLocation] as? [CLLocationDegrees] {
//                let theLoc = LocationCoordinates(withCoordinateArray: coordinateArray)
//                clvalue = theLoc.location()
//            }
//            return clvalue
//        }
//        
//        set {
//            if let theLoc = newValue {
//                self[DataKeys.LastPostLocation] = LocationCoordinates(withLocation: theLoc).toArray()
//            }
//            else {
//                self[DataKeys.LastPostLocation] = NSNull()
//            }
//        }
//    }
//
}


