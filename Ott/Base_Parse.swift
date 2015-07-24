//
//  Base_Parse.swift
//  Ott
//
//  Created by Max on 7/21/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit


class Base_Parse: BaseArchiver {
    
    static let className = "Base"
    static let commentAttribute = "comment"
    static let imageAttribute = "image"
    static let imageURLAttribute = "imageURL"
    static let locationNameAttribute = "imageURL"
    static let latitudeAttribute = "lat"
    static let longitudeAttribute = "long"
    static let nameAttribute = "name"
    static let ratingAttribute = "rating"

    
    let parseObject: PFObject
    
    init() {
        parseObject = PFObject(className: Base_Parse.className)
    }
    
    
    func save() {
        parseObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")}
    }

    
    
    //MARK: - Attributes
    
    var identifier: String? {
        
        return parseObject.objectId
    }
    
    
    var name: String? {
        
        set {
            parseObject[Base_Parse.nameAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.nameAttribute] as? String
        }
    }
    
    
    var comment: String? {
        
        set {
            parseObject[Base_Parse.commentAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.commentAttribute] as? String
        }
    }
    
    
    var imageData: NSData? {
        
        return nil
    }
    
    
    var imageURL: String? {
        
        set {
            parseObject[Base_Parse.imageURLAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.imageURLAttribute] as? String
        }
    }
    
    
    func setImage(image: UIImage?, size: CGSize?, var quality: CGFloat) {
    
        /*
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
*/
    }
    
    
    var latitude: CLLocationDegrees? {
        
        set {
            parseObject[Base_Parse.latitudeAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.latitudeAttribute] as? CLLocationDegrees
        }
    }
    
    
    var longitude: CLLocationDegrees? {
        
        set {
            parseObject[Base_Parse.longitudeAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.longitudeAttribute] as? CLLocationDegrees
        }
    }
    
    
    var locationName: String? {
        
        set {
            parseObject[Base_Parse.locationNameAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.locationNameAttribute] as? String
        }
    }
    
    
    var rating: Float? {
        
        set {
            parseObject[Base_Parse.ratingAttribute] = newValue
        }
        
        get {
            return parseObject[Base_Parse.ratingAttribute] as? Float
        }
    }
    
    
    var createdAt: NSDate? {
        
        return parseObject.createdAt
    }
    
    
    var updatedAt: NSDate? {
        
        return parseObject.updatedAt
    }
    
}
