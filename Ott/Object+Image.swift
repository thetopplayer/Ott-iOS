//
//  Object+Image.swift
//  Ott
//
//  Created by Max on 8/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


extension PFObject {
    
    private func defaultImageQuality() -> CGFloat {
        return CGFloat(0.8)
    }
    
    
    func setImage(image: UIImage?, forKey imageKey: String) {
        
        setImage(image, quality: defaultImageQuality(), forKey: imageKey)
    }
    
    
    func setImage(image: UIImage?, quality: CGFloat, forKey imageKey: String) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let imageFile = PFFile(name: "image.jpg", data:imageRep)
                self[imageKey] = imageFile
            }
            else {
                self[imageKey] = NSNull()
            }
        }
        
        if image == nil {
            
            self[imageKey] = NSNull()
            return
        }
        
        archive(image!, quality: quality)
    }
    
    
//    func getImage(forKey imageKey: String = DataKeys.Image, completion: ((success: Bool, image: UIImage?) -> Void)?) {
//        
////        if hasImage(forKey: imageKey) == false {
////            completion?(success: false, image: nil)
////            return
////        }
//        
//        if let imageFile = self[imageKey] as? PFFile {
//            
//            imageFile.getDataInBackgroundWithBlock {
//                
//                (imageData: NSData?, error: NSError?) -> Void in
//                if error == nil {
//                    
//                    if let imageData = imageData {
//                        let image = UIImage(data: imageData)
//                        dispatch_async(dispatch_get_main_queue()) {
//                            completion?(success: true, image: image)
//                        }
//                    }
//                }
//                else {
//                    
//                    dispatch_async(dispatch_get_main_queue()) {
//                        completion?(success: false, image: nil)
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    func hasImage() -> Bool {
//        
//        return hasImage(forKey: DataKeys.Image)
//    }
//    
//    
//    func hasImage(forKey forKey: String) -> Bool {
//        
//        if let value = self[DataKeys.hasImage(forKey: forKey)] as? Bool {
//            return value
//        }
//        
//        return false
//    }
}