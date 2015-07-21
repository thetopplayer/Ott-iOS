//
//  Base.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Base: NSManagedObject, Uploadable, MKAnnotation {

    @NSManaged var comment_: String?
    @NSManaged var identifier: String?
    @NSManaged var image_: NSData?
    @NSManaged var imageURL: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var locationName: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var shouldHide: NSNumber?
    @NSManaged var timestamp: NSDate

    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        timestamp = NSDate()
    }
    
    
    var comment: String? {
        
        set {
            if let tmp = newValue?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                if tmp.characters.count > 0 {
                    comment_ = tmp
                }
            }
        }
        
        get {
            return comment_
        }
    }
    
    
    var hasComment: Bool {
        return comment_ != nil
    }
    
    

    class func ratingToText(rating: Float?) -> String {
        
        if let r = rating {
            let adjustedValue = Int(1 + floor(r * 9))
            return "\(adjustedValue)"
        }
        return "?"
    }
    
    
    
    func ratingToText() -> String {
        
        return Base.ratingToText(rating?.floatValue)
    }
    
    
    class func ratingToColor(rating: Float?) -> UIColor {
        
        if let r = rating {
            
            let color = r < 0.5 ? UIColor.redColor() : UIColor.fern()
            return color
        }
        return UIColor.darkGrayColor()
    }
    
    
    func ratingToColor() -> UIColor {
        
        return Base.ratingToColor(rating?.floatValue)
    }

    
    var image: UIImage? {
        
        if let theImage = image_ {
            return UIImage(data: theImage)
        }
        return nil
    }
    
    
    var hasImage: Bool {
        return (image_ != nil) || (imageURL != nil)
    }
    
    
    func setImage(image: UIImage?, size: CGSize?, var quality: CGFloat = 1.0) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                image_ = NSData(data: imageRep)
                print("archived image data: \(image_!.length / 1024) kb")
            }
        }
        
        if image == nil {
            return
        }
        
        if (quality < 0) || (quality > 1.0) {
            NSLog("Warning:  Image Quality must be between 0 and 1.0!  setting to 1.0")
            quality = 1.0
        }
        
        if size == nil {
            archive(image!, quality: quality)
        }
        else {
            if let resizedImage = image!.resized(toSize: size!) {
                archive(resizedImage, quality: quality)
            }
        }
    }
    
    
    var hasLocation: Bool {
        return (latitude != nil) && (longitude != nil)
    }
    
    
    var hasLocationName: Bool {
        return locationName != nil
    }
    
    
    
    //MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
    }
    
    
    var title: String? {
        return name
    }
    
    
    var subTitle: String? {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(timestamp)
    }
    
    
    
    //MARK: - Uploadable and Downloadable
    
    static let typeKey = "Type"
    static let commentKey = "com"
    static let identiferKey = "id"
    static let imageURLKey = "img-url"
    static let latitudeKey = "lat"
    static let locationNameKey = "locn"
    static let longitudeKey = "long"
    static let nameKey = "name"
    static let ratingKey = "r"
    static let timestampKey = "ts"
    
    
    func toDictionary() -> [String : String] {
        
        var result = [String : String]()
        
        result[Base.typeKey] = "Base"  // make sure to override this in subclasses
        
        if let myComment = comment {
            result[Base.commentKey] = myComment
        }
        
        if let myLat = latitude {
            result[Base.latitudeKey] = "\(myLat)"
        }
        
        if let myLocationName = locationName {
            result[Base.locationNameKey] = myLocationName
        }
        
        if let myLong = longitude {
            result[Base.longitudeKey] = "\(myLong)"
        }
        
        if let myName = name {
            result[Base.nameKey] = myName
        }
        
        if let myRating = rating {
            result[Base.ratingKey] = "\(myRating)"
        }
        
        return result
    }
}
