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


class BaseObject: PFObject {

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
//    class func parseClassName() -> String {
//        return "BaseObject"
//    }
    
    
    @NSManaged var comment: String?
        
    var identifier: String? {
        return objectId
    }
    
    
    //MARK: - Image
    
    @NSManaged var hasImage: Bool
    private var _cachedImage: UIImage?
    private let imageKey = "image"
    
    func setImage(image: UIImage?, var quality: CGFloat = 0.8) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let filename = "image.jpeg"
                let imageFile = PFFile(name: filename, data:imageRep)
                self[imageKey] = imageFile
                hasImage = true
            }
            else {
                self[imageKey] = nil
                hasImage = false
            }
        }
        
        if image == nil {
            hasImage = false
            self[imageKey] = nil
            return
        }
        
        _cachedImage = image
        archive(image!, quality: quality)
    }
    
    
    func getImage(completion: ((success: Bool, image: UIImage?) -> Void)?) {
        
        if hasImage == false {
            dispatch_async(dispatch_get_main_queue()) {
                completion?(success: true, image: nil)
            }
        }
        else if (_cachedImage != nil) {
            
            dispatch_async(dispatch_get_main_queue()) {
                completion?(success: true, image: self._cachedImage!)
            }
        }
        else {
            
            let imageFile = self[imageKey] as! PFFile
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        self._cachedImage = UIImage(data: imageData)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion?(success: true, image: self._cachedImage)
                    }
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion?(success: false, image: nil)
                    }
                }
            }
        }
    }
    
    
    
    //MARK: - Location
    
    @NSManaged var locationName: String?
    @NSManaged var geoPoint: PFGeoPoint?
    
    var location: CLLocationCoordinate2D? {
        
        get {
            var coordinate: CLLocationCoordinate2D?
            if let geoPoint = geoPoint {
                coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return coordinate
        }
        
        set {
            if let coordinate = newValue {
                geoPoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
    }
    
    
    
    //MARK: - Archival
    
    func saveNow() {
        
        super.save()
    }
    
    
    func saveWithCompletionBlock(completion: (success: Bool, error: NSError) -> Void) {
        
//        super.saveInBackgroundWithBlock(completion)
    }
    
    

}
