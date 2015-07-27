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
//        return "Base"
//    }
    
    
    @NSManaged var comment: String?
        
    var identifier: String? {
        return objectId
    }
    
    //MARK: - Image
    
    @NSManaged var hasImage: Bool
    private var _image: UIImage?
    @NSManaged var imageFile: PFFile?
    
    
    func setImage(image: UIImage?, size: CGSize?, var quality: CGFloat) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let filename = "image.jpeg"
                imageFile = PFFile(name: filename, data:imageRep)
                hasImage = true
//                print("archived image data: \(image_!.length / 1024) kb")
            }
        }
        
        if image == nil {
            hasImage = false
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
    
    
    func getImage(completion: (success: Bool, image: UIImage?) -> Void) {
        
        if (_image != nil) {
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success: true, image: self._image!)
            }
        }
        else {
            
            let imageFile = PFFile()
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    let image = UIImage(data: imageData!)
                    completion(success: true, image: image)
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(success: false, image: nil)
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
