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
}