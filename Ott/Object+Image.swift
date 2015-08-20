//
//  Object+Image.swift
//  Ott
//
//  Created by Max on 8/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


extension DataKeys {
    
    static var Image: String {
        return "image"
    }
    
    static var HasImage: String {
        return "hasImage"
    }
}


protocol CachableImage {
    
    var cachedImage: UIImage? {get}
    func setCachedImage(image: UIImage?)
    
    func setObject(object: AnyObject?, forKeyedSubscript: String)
    func objectForKeyedSubscript(key: String) -> AnyObject?
}


extension CachableImage {
    
    func setImage(image: UIImage?, var quality: CGFloat = 0.8) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let filename = "image.jpeg"
                let imageFile = PFFile(name: filename, data:imageRep)
                self.setObject(imageFile, forKeyedSubscript: DataKeys.Image)
                self.setObject(true, forKeyedSubscript: DataKeys.HasImage)
            }
            else {
                self.setObject(NSNull(), forKeyedSubscript: DataKeys.Image)
                self.setObject(false, forKeyedSubscript: DataKeys.HasImage)
            }
        }
        
        if image == nil {
            
            self.setObject(NSNull(), forKeyedSubscript: DataKeys.Image)
            self.setObject(false, forKeyedSubscript: DataKeys.HasImage)
            return
        }
        
        archive(image!, quality: quality)
    }
    
    
    func getImage(completion: ((success: Bool, image: UIImage?) -> Void)?) {
        
        if hasImage == false {
            completion?(success: false, image: nil)
            return
        }
        
        
        if let cachedImage = cachedImage {
            completion?(success: true, image: cachedImage)
        }
        
        
        if let imageFile = self.objectForKeyedSubscript(DataKeys.Image) as? PFFile {
            
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        self.setCachedImage(image)
                        dispatch_async(dispatch_get_main_queue()) {
                            completion?(success: true, image: image)
                        }
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
    
    
    var hasImage: Bool {
        
        if let value = self.objectForKeyedSubscript(DataKeys.HasImage) as? Bool {
            return value
        }
        
        return false
    }
}