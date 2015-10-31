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


typealias SectorSize = Int

extension DataKeys {
    
    static var SectorID: String {
        return "sectorID"
    }
    
    static var SectorSize: String {
        return "size"
    }
    
    static var SectorActualSize: String {
        return "actualSize"
    }
    
    static var MinLat: String {
        return "minLat"
    }
    
    static var MaxLat: String {
        return "maxLat"
    }
    
    static var MinLong: String {
        return "minLong"
    }
    
    static var MaxLong: String {
        return "maxLong"
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
    
    
    
    //MARK: - Sizes
    
    static let sizes: [SectorSize] = [0, 1, 2, 3, 4, 5]
    
    class func actualSizeForSize(size: SectorSize) -> Double {
        
        let actualSizes = [0.05, 0.1, 0.2, 0.4, 1.6, 6.4]
        
        if size < 0 || size >= actualSizes.count {
            assert(false)
        }
        
        return actualSizes[size]
    }
    
    
    
    //MARK: - Attributes

    @NSManaged var sectorID: String
    @NSManaged var averageRating: Float
    @NSManaged var numberOfPosts: Int
    
    @NSManaged var size: Int
    @NSManaged var actualSize: Double
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


