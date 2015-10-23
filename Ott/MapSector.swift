//
//  MapSector.swift
//  Ott
//
//  Created by Max on 10/22/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/**

Represents a rectangle on a map with an associated topic, averageRating, and number of posts

*/


import UIKit
import MapKit



extension DataKeys {
    
    static var SectorID: String {
        return "sectorID"
    }
}



class MapSector: DataObject, PFSubclassing, MKOverlay {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "MapSector"
    }
    
    
    //MARK: - Attributes

    @NSManaged var sectorID: String
    @NSManaged var averageRating: Float
    @NSManaged var numberOfPosts: Int
    
    @NSManaged var size: Float
    @NSManaged var minLat: Double
    @NSManaged var maxLat: Double
    @NSManaged var minLong: Double
    @NSManaged var maxLong: Double
    
    
    func color() -> UIColor {
        return Rating(withFloat: averageRating / 10).color()
    }
    
    
    //MARK: - MKOverlay
    
    var title: String? {
        return "\(averageRating)"
    }
    
    
    var subTitle: String? {
        return nil
    }

    
    var coordinate: CLLocationCoordinate2D {
        
        let latitude = minLat + (maxLat - minLat) / 2
        let longitude = minLong + (maxLong - minLong) / 2
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    
    var boundingMapRect: MKMapRect {
        
        let coordinate1 = CLLocationCoordinate2DMake(minLat, minLong)
        let coordinate2 = CLLocationCoordinate2DMake(maxLat, maxLong)
        let p1 = MKMapPointForCoordinate (coordinate1)
        let p2 = MKMapPointForCoordinate (coordinate2)
        
        let mapRect = MKMapRectMake(fmin(p1.x, p2.x), fmin(p1.y, p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y))
        return mapRect
    }
    
    
    func polygon() -> MKPolygon {
        
        let coordinate1 = CLLocationCoordinate2DMake(minLat, minLong)
        let coordinate2 = CLLocationCoordinate2DMake(minLat, maxLong)
        let coordinate3 = CLLocationCoordinate2DMake(maxLat, maxLong)
        let coordinate4 = CLLocationCoordinate2DMake(maxLat, minLong)
        
        var coordinates = [coordinate1, coordinate2, coordinate3, coordinate4]
        
        let p = MKPolygon(coordinates: &coordinates, count: coordinates.count)
        return p
    }
}


