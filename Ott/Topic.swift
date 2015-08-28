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
    
    static var Posts: String {
        return "posts"
    }
    
    static var NumberOfPosts: String {
        return "numberOfPosts"
    }
    
    static var LastPostLocation: String {
        return "lastPostLocation"
    }
    
    static var LastPostLocationName: String {
        return "lastPostLocationName"
    }
}


class Topic: Creation, PFSubclassing {
    
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
    class func createWithAuthor(author: User) -> Topic {
        
        let topic = Topic()
        topic.setAuthor(author)
        topic.numberOfPosts = 0
        topic.averageRating = 0
        topic.lastPostLocationName = ""
        
        return topic
    }
    
    
    //MARK: - Attributes
    
    @NSManaged var name: String?
    @NSManaged var numberOfPosts: Int
    @NSManaged var averageRating: Float
    @NSManaged var lastPostLocationName: String?

    // because Parse only allows one geoPoint per record, use this to store
    // additional location information
    struct LocationCoordinates {
        
        let _myLocation: CLLocation
        
        init(withLocation: CLLocation) {
            _myLocation = withLocation
        }
        
        init(withCoordinateArray coordinateArray: [CLLocationDegrees]) {
            _myLocation = CLLocation(latitude: coordinateArray.first!, longitude: coordinateArray.last!)
        }
        
        func toArray() -> [CLLocationDegrees] {
            return [location().coordinate.latitude, location().coordinate.longitude]
        }
        
        func location() -> CLLocation {
            return _myLocation
        }
    }
    
    
    var lastPostLocation: CLLocation? {
        
        get {
            var clvalue: CLLocation?
            if let coordinateArray = self[DataKeys.LastPostLocation] as? [CLLocationDegrees] {
                let theLoc = LocationCoordinates(withCoordinateArray: coordinateArray)
                clvalue = theLoc.location()
            }
            return clvalue
        }
        
        set {
            if let theLoc = newValue {
                self[DataKeys.LastPostLocation] = LocationCoordinates(withLocation: theLoc).toArray()
            }
            else {
                self[DataKeys.LastPostLocation] = NSNull()
            }
        }
    }

    
    //MARK: - Queries
    
    class func fetchTopicWithIdentifier(identifier: String, completion: PFObjectResultBlock) {
        
        Topic.query()!.getObjectInBackgroundWithId(identifier, block: completion)
    }
}

