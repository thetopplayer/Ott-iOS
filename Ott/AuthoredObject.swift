//
//  AuthoredObject.swift
//  Ott
//
//  Created by Max on 7/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

/**

Abstract

*/


import UIKit
import MapKit


extension DataKeys {
   
    static var Author: String {
        return "author"
    }
    
    static var AuthorName: String {
        return "authorName"
    }
    
    static var AuthorHandle: String {
        return "authorHandle"
    }
    
    static var AuthorBio: String {
        return "authorBio"
    }
    
    static var AuthorAvatar: String {
        return "authorAvatar"
    }
    
    static var Comment: String {
        return "comment"
    }
    
    
    static var Image: String {
        return "image"
    }

    
    static var Location: String {
        return "location"
    }
    
    static var LocationName: String {
        return "locationName"
    }
    
    static var Rating: String {
        return "rating"
    }
}


class AuthoredObject: DataObject, MKAnnotation {

    
    //MARK: - Attributes

    @NSManaged var author: User?
    @NSManaged var authorName: String?
    @NSManaged var authorHandle: String?
    @NSManaged var authorBio: String?
    @NSManaged var comment: String?
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
    

    var rating: Rating? {
        
        get {
            let value = self[DataKeys.Rating] as? Int
            return Rating(withValue: value)
        }
        set {
            self[DataKeys.Rating] = newValue?.value
        }
    }
    
    
    var imageFile: PFFile? {
        
        return self[DataKeys.Image] as? PFFile
    }
    
    
    func setImage(image: UIImage?) {
        
        setImage(image, forKey: DataKeys.Image)
    }

    
    var authorAvatarFile: PFFile? {
        
        return self[DataKeys.AuthorAvatar] as? PFFile
    }
    
    
    func setAuthorAvatar(avatar: UIImage?) {
        
        setImage(avatar, forKey: DataKeys.AuthorAvatar)
    }
    
    
    
    //MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        
        return location!.coordinate
    }
    
    
    var title: String? {
        return comment
    }
    
    
    var subTitle: String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(createdAt!)
    }
    
}
