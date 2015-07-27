//
//  CreationObject.swift
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

class CreationObject: BaseObject, MKAnnotation {

//    override class func initialize() {
//        struct Static {
//            static var onceToken : dispatch_once_t = 0;
//        }
//        
//        dispatch_once(&Static.onceToken) {
//            self.registerSubclass()
//        }
//    }
//    
//    override class func parseClassName() -> String {
//        return "Creation"
//    }
    
    
    @NSManaged var authorName: String?
    @NSManaged var authorHandle: String?
    @NSManaged var authorAvatarURL: String?
    
    private let authorKey = "author"
    private let ratingKey = "rating"
    
    
    var author: AuthorObject? {
        
        get {
            
            return self[authorKey] as? AuthorObject
        }
        set {
            self[authorKey] = newValue
        }

    }
    
    
    var rating: Rating? {
        
        get {
            let value = self[ratingKey] as? Int
            return Rating(withValue: value)
        }
        set {
            self[ratingKey] = newValue?.value
        }
    }
    
    
    func getAuthorAvatar(completion: (success: Bool, image: UIImage?) -> Void) {
        
    }
    
    
    
    //MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        
        return location!
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
