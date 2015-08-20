//
//  Creation.swift
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
    
    static var Rating: String {
        return "rating"
    }
}


class Creation: BaseObject, MKAnnotation {

    
    //MARK: - Attributes

    @NSManaged var authorName: String?
    @NSManaged var authorHandle: String?
    
    func setAuthor(author: User) {
        
        self[DataKeys.Author] = author
        authorName = author.name
        authorHandle = author.handle
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
