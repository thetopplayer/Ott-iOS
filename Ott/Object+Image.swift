//
//  Object+Image.swift
//  Ott
//
//  Created by Max on 8/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


let imageKey = "image"
let hasImageKey = "hasImage"

extension PFObject {
    
    func setImage(image: UIImage?, var quality: CGFloat = 0.8) {
        
        func archive(image: UIImage, quality: CGFloat) {
            
            if let imageRep = UIImageJPEGRepresentation(image, quality) {
                
                let filename = "image.jpeg"
                let imageFile = PFFile(name: filename, data:imageRep)
                self[imageKey] = imageFile
                self[hasImageKey] = true
            }
            else {
                self[imageKey] = nil
                self[hasImageKey] = false
            }
        }
        
        if image == nil {
            self[imageKey] = nil
            self[hasImageKey] = false
            return
        }
        
        archive(image!, quality: quality)
    }
    
    
    func getImage(completion: ((success: Bool, image: UIImage?) -> Void)?) {
        
        if hasImage == false {
            completion?(success: false, image: nil)
            return
        }
        
        if let imageFile = self[imageKey] as? PFFile {
            
            imageFile.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        
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
        
        if let value = self[hasImageKey] as? Bool {
            return value
        }
        
        return false
    }
}